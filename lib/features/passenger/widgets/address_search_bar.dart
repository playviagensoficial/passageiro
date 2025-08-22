import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../maps/providers/map_provider.dart';

class AddressSearchBar extends StatefulWidget {
  const AddressSearchBar({super.key});

  @override
  State<AddressSearchBar> createState() => _AddressSearchBarState();
}

class _AddressSearchBarState extends State<AddressSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _recentAddresses = [
    {
      'name': 'Casa',
      'address': 'Rua das Flores, 123 - Centro',
      'icon': Icons.home,
      'location': const LatLng(-23.5505, -46.6333),
    },
    {
      'name': 'Trabalho',
      'address': 'Av. Paulista, 1000 - Bela Vista',
      'icon': Icons.work,
      'location': const LatLng(-23.5618, -46.6565),
    },
  ];

  final List<Map<String, dynamic>> _popularDestinations = [
    {
      'name': 'Aeroporto Internacional de São Paulo',
      'address': 'Rodovia Hélio Smidt, s/n - Cumbica',
      'location': const LatLng(-23.4356, -46.4731),
    },
    {
      'name': 'Shopping Ibirapuera',
      'address': 'Av. Ibirapuera, 3103 - Indianópolis',
      'location': const LatLng(-23.6067, -46.6608),
    },
    {
      'name': 'Estádio do Morumbi',
      'address': 'Praça Roberto Gomes Pedrosa, 1 - Morumbi',
      'location': const LatLng(-23.6006, -46.7196),
    },
    {
      'name': 'Centro Histórico',
      'address': 'Praça da Sé - Centro',
      'location': const LatLng(-23.5489, -46.6388),
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectDestination(String name, String address, LatLng location) async {
    final mapProvider = context.read<MapProvider>();
    await mapProvider.setDestinationLocation(location);
    
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Destino definido: $name'),
        backgroundColor: const Color(0xFF00CC00),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
              ),
              const Expanded(
                child: Text(
                  'Para onde?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48), // Balance the back button
            ],
          ),
        ),

        // Search Input
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Buscar endereço ou local',
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 16),
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                // For demo, use a default location
                _selectDestination(
                  value,
                  value,
                  const LatLng(-23.5489, -46.6388),
                );
              }
            },
          ),
        ),

        const SizedBox(height: 24),

        // Recent Addresses
        if (_recentAddresses.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Endereços salvos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          ..._recentAddresses.map((address) {
            return ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  address['icon'] as IconData,
                  color: Colors.grey[600],
                ),
              ),
              title: Text(
                address['name'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                address['address'] as String,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              onTap: () => _selectDestination(
                address['name'] as String,
                address['address'] as String,
                address['location'] as LatLng,
              ),
            );
          }).toList(),
          
          const SizedBox(height: 24),
        ],

        // Popular Destinations
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Destinos populares',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        const SizedBox(height: 12),

        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: _popularDestinations.length,
            itemBuilder: (context, index) {
              final destination = _popularDestinations[index];
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                  ),
                ),
                title: Text(
                  destination['name'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  destination['address'] as String,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                onTap: () => _selectDestination(
                  destination['name'] as String,
                  destination['address'] as String,
                  destination['location'] as LatLng,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}