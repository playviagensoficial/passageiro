import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../maps/providers/map_provider.dart';
import '../../ride/providers/ride_provider.dart';

class UberAddressSearch extends StatefulWidget {
  const UberAddressSearch({super.key});

  @override
  State<UberAddressSearch> createState() => _UberAddressSearchState();
}

class _UberAddressSearchState extends State<UberAddressSearch> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final List<TextEditingController> _stopControllers = [];
  final FocusNode _pickupFocus = FocusNode();
  final FocusNode _destinationFocus = FocusNode();
  final List<FocusNode> _stopFocusNodes = [];
  
  String _focusedField = 'destination'; // 'pickup', 'destination', or 'stop_0', 'stop_1', etc.
  List<Map<String, dynamic>> _suggestions = [];
  
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
  }
  
  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    _pickupFocus.dispose();
    _destinationFocus.dispose();
    for (var controller in _stopControllers) {
      controller.dispose();
    }
    for (var focus in _stopFocusNodes) {
      focus.dispose();
    }
    super.dispose();
  }
  
  void _addStop() {
    setState(() {
      _stopControllers.add(TextEditingController());
      _stopFocusNodes.add(FocusNode());
    });
    
    // Focus the new stop field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _stopFocusNodes.last.requestFocus();
      _focusedField = 'stop_${_stopControllers.length - 1}';
    });
  }
  
  void _removeStop(int index) {
    setState(() {
      _stopControllers[index].dispose();
      _stopFocusNodes[index].dispose();
      _stopControllers.removeAt(index);
      _stopFocusNodes.removeAt(index);
    });
  }
  
  void _onFieldFocused(String field) {
    setState(() {
      _focusedField = field;
      _loadSuggestions();
    });
  }
  
  void _loadSuggestions() {
    // Load suggestions based on focused field
    setState(() {
      _suggestions = [
        {
          'type': 'current',
          'name': 'Localização atual',
          'address': 'Usar localização GPS',
          'location': const LatLng(-23.5505, -46.6333),
        },
        {
          'type': 'saved',
          'name': 'Casa',
          'address': 'Rua das Flores, 123 - Centro',
          'location': const LatLng(-23.5505, -46.6333),
        },
        {
          'type': 'saved',
          'name': 'Trabalho',
          'address': 'Av. Paulista, 1000 - Bela Vista',
          'location': const LatLng(-23.5618, -46.6565),
        },
        {
          'type': 'recent',
          'name': 'Aeroporto Internacional',
          'address': 'Rodovia Hélio Smidt, s/n - Cumbica',
          'location': const LatLng(-23.4356, -46.4731),
        },
        {
          'type': 'recent',
          'name': 'Shopping Ibirapuera',
          'address': 'Av. Ibirapuera, 3103 - Indianópolis',
          'location': const LatLng(-23.6067, -46.6608),
        },
      ];
    });
  }
  
  void _selectLocation(Map<String, dynamic> location) async {
    final mapProvider = context.read<MapProvider>();
    
    if (_focusedField == 'pickup') {
      _pickupController.text = location['name'];
      await mapProvider.setPickupLocation(location['location']);
      // Auto-focus destination
      _destinationFocus.requestFocus();
      _onFieldFocused('destination');
    } else if (_focusedField == 'destination') {
      _destinationController.text = location['name'];
      await mapProvider.setDestinationLocation(location['location']);
      
      // Calculate route when destination is set
      if (mapProvider.pickupLocation != null && mapProvider.destinationLocation != null) {
        await mapProvider.calculateRoute();
        
        // Ensure vehicle categories are loaded
        final rideProvider = context.read<RideProvider>();
        if (rideProvider.vehicleCategories.isEmpty) {
          await rideProvider.loadVehicleCategories();
        }
        
        // Auto close after route calculation to show vehicle options
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      }
    } else if (_focusedField.startsWith('stop_')) {
      int index = int.parse(_focusedField.split('_')[1]);
      _stopControllers[index].text = location['name'];
      
      // Focus next field or close
      if (index < _stopControllers.length - 1) {
        _stopFocusNodes[index + 1].requestFocus();
        _onFieldFocused('stop_${index + 1}');
      } else {
        Navigator.pop(context);
      }
    }
  }
  
  Widget _buildAddressField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String fieldId,
    required IconData icon,
    Color iconColor = Colors.black,
    bool showRemove = false,
    VoidCallback? onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: label,
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey[600]),
              ),
              onTap: () => _onFieldFocused(fieldId),
              onChanged: (value) {
                // In a real app, this would search for addresses
                _loadSuggestions();
              },
            ),
          ),
          if (showRemove && onRemove != null)
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
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
                    'Planejar viagem',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          
          // Address inputs section
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Column(
              children: [
                // Pickup field
                _buildAddressField(
                  label: 'De onde?',
                  controller: _pickupController,
                  focusNode: _pickupFocus,
                  fieldId: 'pickup',
                  icon: Icons.circle,
                  iconColor: Colors.green,
                ),
                
                Divider(height: 1, color: Colors.grey[300]),
                
                // Stop fields
                ..._stopControllers.asMap().entries.map((entry) {
                  return Column(
                    children: [
                      _buildAddressField(
                        label: 'Adicionar parada',
                        controller: entry.value,
                        focusNode: _stopFocusNodes[entry.key],
                        fieldId: 'stop_${entry.key}',
                        icon: Icons.add_circle_outline,
                        iconColor: Colors.blue,
                        showRemove: true,
                        onRemove: () => _removeStop(entry.key),
                      ),
                      Divider(height: 1, color: Colors.grey[300]),
                    ],
                  );
                }),
                
                // Destination field
                _buildAddressField(
                  label: 'Para onde?',
                  controller: _destinationController,
                  focusNode: _destinationFocus,
                  fieldId: 'destination',
                  icon: Icons.location_on,
                  iconColor: Colors.red,
                ),
              ],
            ),
          ),
          
          // Add stop button
          if (_stopControllers.length < 3) // Max 3 stops
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextButton.icon(
                onPressed: _addStop,
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Adicionar parada'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                ),
              ),
            ),
          
          Divider(height: 1, color: Colors.grey[300]),
          
          // Suggestions list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // Current location
                if (_focusedField == 'pickup' && _suggestions.any((s) => s['type'] == 'current'))
                  ..._suggestions.where((s) => s['type'] == 'current').map((suggestion) {
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.my_location, color: Colors.blue),
                      ),
                      title: Text(
                        suggestion['name'],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        suggestion['address'],
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      onTap: () => _selectLocation(suggestion),
                    );
                  }),
                
                // Saved places
                if (_suggestions.any((s) => s['type'] == 'saved')) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Lugares salvos',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  ..._suggestions.where((s) => s['type'] == 'saved').map((suggestion) {
                    IconData icon = Icons.home;
                    if (suggestion['name'] == 'Trabalho') {
                      icon = Icons.work;
                    }
                    
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: Colors.grey[700]),
                      ),
                      title: Text(
                        suggestion['name'],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        suggestion['address'],
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      onTap: () => _selectLocation(suggestion),
                    );
                  }),
                ],
                
                // Recent places
                if (_suggestions.any((s) => s['type'] == 'recent')) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Recentes',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  ..._suggestions.where((s) => s['type'] == 'recent').map((suggestion) {
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.history, color: Colors.grey[600]),
                      ),
                      title: Text(
                        suggestion['name'],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        suggestion['address'],
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      onTap: () => _selectLocation(suggestion),
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}