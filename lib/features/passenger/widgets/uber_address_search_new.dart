import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../maps/providers/map_provider.dart';
import '../../ride/providers/ride_provider.dart';
import '../../../core/services/places_service.dart';

class UberAddressSearchNew extends StatefulWidget {
  const UberAddressSearchNew({super.key});

  @override
  State<UberAddressSearchNew> createState() => _UberAddressSearchNewState();
}

class _UberAddressSearchNewState extends State<UberAddressSearchNew> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final FocusNode _pickupFocus = FocusNode();
  final FocusNode _destinationFocus = FocusNode();
  
  final PlacesService _placesService = PlacesService();
  Timer? _debounceTimer;
  
  String _focusedField = 'destination';
  List<PlacePrediction> _suggestions = [];
  bool _isLoading = false;
  
  // Saved places and recent searches
  final List<Map<String, dynamic>> _savedPlaces = [
    {
      'type': 'current',
      'name': 'Localização atual',
      'address': 'Usar localização GPS',
      'icon': Icons.my_location,
      'color': Colors.blue,
    },
    {
      'type': 'saved',
      'name': 'Casa',
      'address': 'Rua das Flores, 123 - Centro',
      'icon': Icons.home,
      'color': Colors.grey,
    },
    {
      'type': 'saved',
      'name': 'Trabalho',
      'address': 'Av. Paulista, 1000 - Bela Vista',
      'icon': Icons.work,
      'color': Colors.grey,
    },
  ];
  
  final List<Map<String, dynamic>> _recentPlaces = [
    {
      'name': 'Aeroporto Internacional',
      'address': 'Rodovia Hélio Smidt, s/n - Cumbica',
      'icon': Icons.flight,
    },
    {
      'name': 'Shopping Ibirapuera',
      'address': 'Av. Ibirapuera, 3103 - Indianópolis',
      'icon': Icons.shopping_bag,
    },
    {
      'name': 'Estação da Sé',
      'address': 'Praça da Sé - Centro',
      'icon': Icons.train,
    },
  ];

  @override
  void initState() {
    super.initState();
    print('🚀 UberAddressSearchNew initState called');
    
    final mapProvider = context.read<MapProvider>();
    
    // Set pickup from current location
    if (mapProvider.pickupAddress != null) {
      _pickupController.text = mapProvider.pickupAddress!;
      print('📍 Set pickup from MapProvider: ${mapProvider.pickupAddress}');
    } else {
      _pickupController.text = 'Localização atual';
      print('📍 Set pickup to default: Localização atual');
    }
    
    // Set destination if already selected
    if (mapProvider.destinationAddress != null) {
      _destinationController.text = mapProvider.destinationAddress!;
      print('🎯 Set destination from MapProvider: ${mapProvider.destinationAddress}');
    }
    
    // Auto-focus destination field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🎯 Auto-focusing destination field');
      _destinationFocus.requestFocus();
    });
    
    // Add listeners for real-time search
    print('👂 Adding text listeners');
    _pickupController.addListener(() {
      print('🔵 Pickup text changed: "${_pickupController.text}"');
      _onSearchChanged('pickup');
    });
    _destinationController.addListener(() {
      print('🔴 Destination text changed: "${_destinationController.text}"');
      _onSearchChanged('destination');
    });
    
    // Test API immediately
    _testAPI();
  }
  
  void _testAPI() async {
    print('🧪 Testing API with hardcoded query...');
    try {
      final results = await _placesService.getAutocompletePredictions('São Paulo');
      print('🧪 Test API results: ${results.length} items');
    } catch (e) {
      print('🧪 Test API error: $e');
    }
  }
  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    _pickupController.dispose();
    _destinationController.dispose();
    _pickupFocus.dispose();
    _destinationFocus.dispose();
    super.dispose();
  }
  
  void _onFieldFocused(String field) {
    setState(() {
      _focusedField = field;
    });
    _performSearch(_getCurrentQuery());
  }
  
  void _onSearchChanged(String field) {
    print('📝 _onSearchChanged called for field: $field');
    print('🎯 Current focused field: $_focusedField');
    print('📄 Current query: "${_getCurrentQuery()}"');
    
    if (_focusedField != field) {
      print('❌ Field mismatch, ignoring');
      return;
    }
    
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      print('⏰ Debounce timer triggered, calling _performSearch');
      _performSearch(_getCurrentQuery());
    });
  }
  
  String _getCurrentQuery() {
    return _focusedField == 'pickup' 
        ? _pickupController.text 
        : _destinationController.text;
  }
  
  Future<void> _performSearch(String query) async {
    print('🔍 _performSearch called with query: "$query"');
    
    if (query.length < 2) {
      print('❌ Query too short, returning empty');
      setState(() {
        _suggestions = [];
        _isLoading = false;
      });
      return;
    }
    
    print('⏳ Setting loading state to true');
    setState(() {
      _isLoading = true;
    });
    
    try {
      final mapProvider = context.read<MapProvider>();
      print('📍 Current pickup location: ${mapProvider.pickupLocation}');
      
      print('🚀 Calling getAutocompletePredictions...');
      final suggestions = await _placesService.getAutocompletePredictions(
        query,
        location: mapProvider.pickupLocation,
      );
      
      print('📋 Received ${suggestions.length} suggestions');
      for (var suggestion in suggestions) {
        print('   - ${suggestion.mainText} (${suggestion.secondaryText})');
      }
      
      setState(() {
        _suggestions = suggestions;
        _isLoading = false;
      });
    } catch (e) {
      print('💥 Error in _performSearch: $e');
      setState(() {
        _suggestions = [];
        _isLoading = false;
      });
    }
  }
  
  Future<void> _selectPlace(PlacePrediction prediction) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final placeDetails = await _placesService.getPlaceDetails(prediction.placeId);
      if (placeDetails != null) {
        await _setLocationFromDetails(placeDetails, prediction.description);
      }
    } catch (e) {
      // Fallback to prediction data
      await _setLocationFromPrediction(prediction);
    }
    
    setState(() {
      _isLoading = false;
    });
  }
  
  Future<void> _setLocationFromDetails(PlaceDetails details, String description) async {
    final mapProvider = context.read<MapProvider>();
    
    if (_focusedField == 'pickup') {
      _pickupController.text = details.name.isNotEmpty ? details.name : description;
      await mapProvider.setPickupLocation(details.location);
      // Auto-focus destination
      _destinationFocus.requestFocus();
      _onFieldFocused('destination');
    } else {
      _destinationController.text = details.name.isNotEmpty ? details.name : description;
      await mapProvider.setDestinationLocation(details.location);
      await _completeAddressSelection();
    }
  }
  
  Future<void> _setLocationFromPrediction(PlacePrediction prediction) async {
    if (_focusedField == 'pickup') {
      _pickupController.text = prediction.mainText;
      // For pickup, we'd need to geocode or use a default location
      _destinationFocus.requestFocus();
      _onFieldFocused('destination');
    } else {
      _destinationController.text = prediction.mainText;
      await _completeAddressSelection();
    }
  }
  
  Future<void> _selectSavedPlace(Map<String, dynamic> place) async {
    if (place['type'] == 'current') {
      await _useCurrentLocation();
      return;
    }
    
    if (_focusedField == 'pickup') {
      _pickupController.text = place['name'];
      _destinationFocus.requestFocus();
      _onFieldFocused('destination');
    } else {
      _destinationController.text = place['name'];
      await _completeAddressSelection();
    }
  }
  
  Future<void> _useCurrentLocation() async {
    final mapProvider = context.read<MapProvider>();
    if (_focusedField == 'pickup') {
      _pickupController.text = 'Localização atual';
      // Use current location from mapProvider
      _destinationFocus.requestFocus();
      _onFieldFocused('destination');
    }
  }
  
  Future<void> _completeAddressSelection() async {
    final mapProvider = context.read<MapProvider>();
    
    // Calculate route when both addresses are set
    if (mapProvider.pickupLocation != null && mapProvider.destinationLocation != null) {
      await mapProvider.calculateRoute();
      
      // Ensure vehicle categories are loaded
      final rideProvider = context.read<RideProvider>();
      if (rideProvider.vehicleCategories.isEmpty) {
        await rideProvider.loadVehicleCategories();
      }
      
      // Close modal and return to map view
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
  
  Widget _buildSearchField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String fieldId,
    required IconData icon,
    Color iconColor = Colors.grey,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: label,
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintStyle: TextStyle(color: Colors.grey[600]),
              ),
              onTap: () => _onFieldFocused(fieldId),
              onChanged: (value) {
                // Search is handled by listener
              },
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller.clear();
                _onFieldFocused(fieldId);
              },
              child: Icon(Icons.clear, color: Colors.grey[600], size: 20),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _getCurrentQuery();
    final showSuggestions = query.length < 2;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    'Para onde?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Search fields
          _buildSearchField(
            label: 'De onde?',
            controller: _pickupController,
            focusNode: _pickupFocus,
            fieldId: 'pickup',
            icon: Icons.circle,
            iconColor: Colors.green,
          ),
          
          _buildSearchField(
            label: 'Para onde?',
            controller: _destinationController,
            focusNode: _destinationFocus,
            fieldId: 'destination',
            icon: Icons.location_on,
            iconColor: Colors.red,
          ),
          
          const SizedBox(height: 8),
          
          // Results
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : showSuggestions 
                ? _buildSavedAndRecent()
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSavedAndRecent() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // Saved places
        if (_savedPlaces.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'Lugares salvos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          ..._savedPlaces.map((place) => _buildPlaceItem(
            icon: place['icon'],
            iconColor: place['color'],
            title: place['name'],
            subtitle: place['address'],
            onTap: () => _selectSavedPlace(place),
          )),
        ],
        
        // Recent places
        if (_recentPlaces.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Text(
              'Recentes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          ..._recentPlaces.map((place) => _buildPlaceItem(
            icon: place['icon'],
            iconColor: Colors.grey[600]!,
            title: place['name'],
            subtitle: place['address'],
            onTap: () => _selectSavedPlace(place),
          )),
        ],
      ],
    );
  }
  
  Widget _buildSearchResults() {
    if (_suggestions.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Nenhum resultado encontrado',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Query atual: "${_getCurrentQuery()}"',
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        ],
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = _suggestions[index];
        return _buildPlaceItem(
          icon: Icons.location_on,
          iconColor: Colors.grey[600]!,
          title: suggestion.mainText,
          subtitle: suggestion.secondaryText,
          onTap: () => _selectPlace(suggestion),
        );
      },
    );
  }
  
  Widget _buildPlaceItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
}