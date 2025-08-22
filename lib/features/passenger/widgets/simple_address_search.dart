import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../maps/providers/map_provider.dart';
import '../../ride/providers/ride_provider.dart';

class SimpleAddressSearch extends StatefulWidget {
  const SimpleAddressSearch({super.key});

  @override
  State<SimpleAddressSearch> createState() => _SimpleAddressSearchState();
}

class _SimpleAddressSearchState extends State<SimpleAddressSearch> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final FocusNode _pickupFocus = FocusNode();
  final FocusNode _destinationFocus = FocusNode();
  
  String _focusedField = 'destination';
  
  // Mock suggestions for testing
  final List<Map<String, dynamic>> _mockSuggestions = [
    {
      'title': 'Avenida Paulista',
      'subtitle': 'São Paulo, SP, Brasil',
      'location': const LatLng(-23.5618, -46.6565),
    },
    {
      'title': 'Shopping Ibirapuera',
      'subtitle': 'Av. Ibirapuera, 3103 - Indianópolis, São Paulo',
      'location': const LatLng(-23.6067, -46.6608),
    },
    {
      'title': 'Aeroporto de Guarulhos',
      'subtitle': 'Rodovia Hélio Smidt, s/n - Cumbica, Guarulhos',
      'location': const LatLng(-23.4356, -46.4731),
    },
    {
      'title': 'Estação da Sé',
      'subtitle': 'Praça da Sé - Centro, São Paulo',
      'location': const LatLng(-23.5505, -46.6333),
    },
    {
      'title': 'Parque Ibirapuera',
      'subtitle': 'Av. Pedro Álvares Cabral - Vila Mariana, São Paulo',
      'location': const LatLng(-23.5873, -46.6578),
    },
  ];
  
  List<Map<String, dynamic>> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    final mapProvider = context.read<MapProvider>();
    
    // Set pickup from current location
    if (mapProvider.pickupAddress != null) {
      _pickupController.text = mapProvider.pickupAddress!;
    } else {
      _pickupController.text = 'Localização atual';
    }
    
    // Set destination if already selected
    if (mapProvider.destinationAddress != null) {
      _destinationController.text = mapProvider.destinationAddress!;
    }
    
    // Auto-focus destination field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _destinationFocus.requestFocus();
    });
    
    // Add listeners for search
    _pickupController.addListener(_onSearchChanged);
    _destinationController.addListener(_onSearchChanged);
  }
  
  @override
  void dispose() {
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
    _onSearchChanged();
  }
  
  void _onSearchChanged() {
    final query = _focusedField == 'pickup' 
        ? _pickupController.text 
        : _destinationController.text;
        
    if (query.length < 2) {
      setState(() {
        _filteredSuggestions = [];
      });
      return;
    }
    
    // Filter mock suggestions based on query
    setState(() {
      _filteredSuggestions = _mockSuggestions.where((suggestion) {
        final title = suggestion['title'].toString().toLowerCase();
        final subtitle = suggestion['subtitle'].toString().toLowerCase();
        final queryLower = query.toLowerCase();
        return title.contains(queryLower) || subtitle.contains(queryLower);
      }).toList();
    });
  }
  
  Future<void> _selectPlace(Map<String, dynamic> place) async {
    final mapProvider = context.read<MapProvider>();
    
    if (_focusedField == 'pickup') {
      _pickupController.text = place['title'];
      await mapProvider.setPickupLocation(place['location']);
      // Auto-focus destination
      _destinationFocus.requestFocus();
      _onFieldFocused('destination');
    } else {
      _destinationController.text = place['title'];
      await mapProvider.setDestinationLocation(place['location']);
      await _completeAddressSelection();
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

  @override
  Widget build(BuildContext context) {
    final showSuggestions = _filteredSuggestions.isNotEmpty;
    
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
          
          const SizedBox(height: 16),
          
          // Results
          Expanded(
            child: showSuggestions 
              ? _buildSuggestionsList()
              : _buildDefaultSuggestions(),
          ),
        ],
      ),
    );
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
  
  Widget _buildSuggestionsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _filteredSuggestions.length,
      itemBuilder: (context, index) {
        final suggestion = _filteredSuggestions[index];
        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.location_on, color: Colors.grey[600], size: 20),
          ),
          title: Text(
            suggestion['title'],
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            suggestion['subtitle'],
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          onTap: () => _selectPlace(suggestion),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        );
      },
    );
  }
  
  Widget _buildDefaultSuggestions() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _mockSuggestions.length,
      itemBuilder: (context, index) {
        final suggestion = _mockSuggestions[index];
        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.location_on, color: Colors.grey[600], size: 20),
          ),
          title: Text(
            suggestion['title'],
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            suggestion['subtitle'],
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          onTap: () => _selectPlace(suggestion),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        );
      },
    );
  }
}