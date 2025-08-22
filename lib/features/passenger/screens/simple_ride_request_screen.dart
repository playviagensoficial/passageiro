import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../ride/providers/ride_provider.dart';
import '../../../core/widgets/app_bottom_navigation.dart';
import '../../maps/providers/map_provider.dart';
import 'ride_tracking_complete_screen.dart';
import '../widgets/address_autocomplete_field.dart';
import '../../../core/services/google_maps_service.dart';

class SimpleRideRequestScreen extends StatefulWidget {
  const SimpleRideRequestScreen({super.key});

  @override
  State<SimpleRideRequestScreen> createState() => _SimpleRideRequestScreenState();
}

class _SimpleRideRequestScreenState extends State<SimpleRideRequestScreen> {
  final _pickupController = TextEditingController();
  final _destinationController = TextEditingController();
  String _selectedVehicleCategory = 'Economy';
  bool _isRequestingRide = false;
  bool _isLoadingLocation = false;
  
  // Coordenadas dos locais selecionados
  PlaceDetails? _pickupPlace;
  PlaceDetails? _destinationPlace;

  // Now we use the actual vehicle categories from the provider
  void _onAddressChanged() {
    final rideProvider = context.read<RideProvider>();
    
    // Se ambos os locais foram selecionados, calcular rota e tarifa
    if (_pickupPlace != null && 
        _destinationPlace != null &&
        rideProvider.selectedCategory != null) {
      
      rideProvider.calculateRouteAndFare(
        pickupLatitude: _pickupPlace!.lat,
        pickupLongitude: _pickupPlace!.lng,
        destinationLatitude: _destinationPlace!.lat,
        destinationLongitude: _destinationPlace!.lng,
      );
    }
  }

  void _onPickupPlaceSelected(PlaceDetails place) {
    setState(() {
      _pickupPlace = place;
    });
    _onAddressChanged();
  }

  void _onDestinationPlaceSelected(PlaceDetails place) {
    setState(() {
      _destinationPlace = place;
    });
    _onAddressChanged();
  }

  IconData _getIconForCategory(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'economy':
        return Icons.directions_car;
      case 'comfort':
        return Icons.car_rental;
      case 'premium':
        return Icons.star;
      default:
        return Icons.directions_car;
    }
  }

  Widget _buildFareRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? Colors.white : Colors.grey,
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isTotal ? const Color(0xFF00FF00) : Colors.white,
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Initialize the ride provider and get current location
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final rideProvider = context.read<RideProvider>();
      if (rideProvider.vehicleCategories.isEmpty) {
        await rideProvider.loadVehicleCategories();
      }
      // Select first category by default
      if (rideProvider.vehicleCategories.isNotEmpty) {
        final firstCategory = rideProvider.vehicleCategories.first;
        rideProvider.selectVehicleCategory(firstCategory);
        setState(() {
          _selectedVehicleCategory = firstCategory.name;
        });
      }
      
      // Auto-fill pickup location with current location
      await _getCurrentLocationAndFillPickup();
    });
    
    // Listeners are now handled by the AddressAutocompleteField widgets
  }

  Future<void> _getCurrentLocationAndFillPickup() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Serviço de localização desabilitado'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permissão de localização negada'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permissão de localização negada permanentemente'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates using MapProvider
      final mapProvider = context.read<MapProvider>();
      final address = await mapProvider.getAddressFromCoordinates(
        position.latitude, 
        position.longitude
      );

      if (address != null && address.isNotEmpty) {
        setState(() {
          _pickupController.text = address;
          _pickupPlace = PlaceDetails(
            placeId: 'current_location',
            name: address,
            lat: position.latitude,
            lng: position.longitude,
            formattedAddress: address,
          );
        });
        _onAddressChanged();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📍 Localização detectada automaticamente'),
            backgroundColor: Color(0xFF00FF00),
          ),
        );
      } else {
        // Fallback: tentar novamente com um delay
        await Future.delayed(const Duration(seconds: 1));
        final retryAddress = await mapProvider.getAddressFromCoordinates(
          position.latitude, 
          position.longitude
        );
        
        if (retryAddress != null && retryAddress.isNotEmpty) {
          setState(() {
            _pickupController.text = retryAddress;
            _pickupPlace = PlaceDetails(
              placeId: 'current_location',
              name: retryAddress,
              lat: position.latitude,
              lng: position.longitude,
              formattedAddress: retryAddress,
            );
          });
          _onAddressChanged();
        } else {
          // Se ainda não conseguir, mostre uma mensagem genérica mas válida
          final fallbackAddress = 'Sua localização atual (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';
          setState(() {
            _pickupController.text = fallbackAddress;
            _pickupPlace = PlaceDetails(
              placeId: 'current_location',
              name: fallbackAddress,
              lat: position.latitude,
              lng: position.longitude,
              formattedAddress: fallbackAddress,
            );
          });
          _onAddressChanged();
        }
      }
    } catch (e) {
      debugPrint('Erro ao obter localização: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao obter localização: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _requestRide() async {
    if (_pickupController.text.isEmpty || _destinationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha origem e destino'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_pickupPlace == null || _destinationPlace == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione os endereços da lista de sugestões'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Primeiro, carregue e selecione a categoria de veículo
    final rideProvider = context.read<RideProvider>();
    
    // Certifique-se que o provider está inicializado e tem categorias
    if (rideProvider.vehicleCategories.isEmpty) {
      await rideProvider.loadVehicleCategories();
    }
    
    // Encontre a categoria selecionada nos dados do provider
    final selectedCategory = rideProvider.vehicleCategories.firstWhere(
      (category) => category.name == _selectedVehicleCategory,
      orElse: () => rideProvider.vehicleCategories.first,
    );
    
    // Selecione a categoria no provider
    rideProvider.selectVehicleCategory(selectedCategory);

    setState(() {
      _isRequestingRide = true;
    });

    final success = await rideProvider.requestRide(
      pickupAddress: _pickupPlace!.formattedAddress,
      pickupLatitude: _pickupPlace!.lat,
      pickupLongitude: _pickupPlace!.lng,
      destinationAddress: _destinationPlace!.formattedAddress,
      destinationLatitude: _destinationPlace!.lat,
      destinationLongitude: _destinationPlace!.lng,
      paymentMethod: 'card',
    );

    setState(() {
      _isRequestingRide = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🚗 Corrida solicitada! Procurando motorista...'),
          backgroundColor: Color(0xFF00FF00),
          duration: Duration(seconds: 2),
        ),
      );
      
      // Navigate to ride tracking screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const RideTrackingCompleteScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(rideProvider.errorMessage ?? 'Erro ao solicitar corrida'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Solicitar Corrida',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<RideProvider>(
        builder: (context, rideProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo Play Viagens
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00FF00),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'play',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 0.9,
                          ),
                        ),
                        Text(
                          'Viagens',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),

                // Address inputs
                const Text(
                  'Onde você está?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                AddressAutocompleteField(
                  controller: _pickupController,
                  hintText: 'Onde você está?',
                  prefixIcon: Icons.my_location,
                  prefixIconColor: const Color(0xFF00FF00),
                  onPlaceSelected: _onPickupPlaceSelected,
                  onChanged: _onAddressChanged,
                  enabled: true, // Autocomplete habilitado
                ),

                const SizedBox(height: 24),

                const Text(
                  'Para onde vamos?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                AddressAutocompleteField(
                  controller: _destinationController,
                  hintText: 'Digite o endereço de destino',
                  prefixIcon: Icons.location_on,
                  prefixIconColor: Colors.red,
                  onPlaceSelected: _onDestinationPlaceSelected,
                  onChanged: _onAddressChanged,
                ),

                const SizedBox(height: 32),

                // Vehicle category selection
                const Text(
                  'Escolha seu veículo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Dynamic vehicle categories with real-time pricing
                Consumer<RideProvider>(
                  builder: (context, rideProvider, child) {
                    if (rideProvider.vehicleCategories.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(color: Color(0xFF00FF00)),
                      );
                    }
                    
                    return Column(
                      children: rideProvider.vehicleCategories.map((category) {
                        final isSelected = _selectedVehicleCategory == category.name;
                        
                        // Calculate fare for this category
                        String priceText = 'R\$ ${category.minimumFare}';
                        String timeText = '3-8 min';
                        
                        // Show calculated fare if route is available and this category is selected
                        if (rideProvider.currentRoute != null && isSelected) {
                          // The fare is already calculated for the selected category
                          final fare = rideProvider.estimatedFare;
                          if (fare > 0) {
                            priceText = 'R\$ ${fare.toStringAsFixed(2)}';
                            timeText = rideProvider.currentRoute!.duration;
                          }
                        } else if (rideProvider.currentRoute != null && !isSelected) {
                          // Calculate fare for non-selected categories for preview
                          final previewFare = GoogleMapsService.calculatePassengerFareEstimate(
                            distanceMeters: rideProvider.currentRoute!.distanceValue,
                            durationSeconds: rideProvider.currentRoute!.durationValue,
                            vehicleCategory: category.name.toLowerCase(),
                            surgePricing: 1.0,
                          );
                          priceText = 'R\$ ${previewFare.toStringAsFixed(2)}';
                          timeText = rideProvider.currentRoute!.duration;
                        }
                        
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedVehicleCategory = category.name;
                            });
                            rideProvider.selectVehicleCategory(category);
                            _onAddressChanged(); // Recalculate fare for new category
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF00FF00).withOpacity(0.1) : const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF00FF00) : const Color(0xFF333333),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFF00FF00) : const Color(0xFF333333),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Icon(
                                    _getIconForCategory(category.name),
                                    color: isSelected ? Colors.black : Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        category.displayName ?? category.name,
                                        style: TextStyle(
                                          color: isSelected ? const Color(0xFF00FF00) : Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        category.description,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      priceText,
                                      style: TextStyle(
                                        color: isSelected ? const Color(0xFF00FF00) : Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      timeText,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),

                // Fare breakdown section
                Consumer<RideProvider>(
                  builder: (context, rideProvider, child) {
                    if (rideProvider.fareBreakdown != null && rideProvider.currentRoute != null) {
                      final breakdown = rideProvider.fareBreakdown!;
                      return Container(
                        margin: const EdgeInsets.only(top: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF333333)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.receipt, color: Color(0xFF00FF00), size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'Detalhamento do Preço',
                                  style: TextStyle(
                                    color: Color(0xFF00FF00),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildFareRow('Tarifa base', 'R\$ ${breakdown['baseFare'].toStringAsFixed(2)}'),
                            _buildFareRow('Distância (${breakdown['distanceKm']} km)', 'R\$ ${breakdown['distanceFare'].toStringAsFixed(2)}'),
                            _buildFareRow('Tempo (${breakdown['durationMinutes']} min)', 'R\$ ${breakdown['timeFare'].toStringAsFixed(2)}'),
                            if (breakdown['surgeAmount'] > 0)
                              _buildFareRow('Taxa de demanda', 'R\$ ${breakdown['surgeAmount'].toStringAsFixed(2)}'),
                            const Divider(color: Color(0xFF333333)),
                            _buildFareRow(
                              'Total estimado',
                              'R\$ ${breakdown['subtotal'].toStringAsFixed(2)}',
                              isTotal: true,
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                const SizedBox(height: 40),

                // Request button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isRequestingRide ? null : _requestRide,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00FF00),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isRequestingRide
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            'SOLICITAR CORRIDA',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // Demo addresses buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🧪 Endereços de Teste',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () async {
                                // Aeroporto de Guarulhos (GRU)
                                _pickupController.text = 'Aeroporto Internacional de São Paulo';
                                _pickupPlace = PlaceDetails(
                                  placeId: 'ChIJ5w_NdxdXzpQRJk0xRQJgE7E',
                                  name: 'Aeroporto Internacional de São Paulo',
                                  formattedAddress: 'Rod. Hélio Smidt, s/n - Cumbica, Guarulhos - SP, Brasil',
                                  lat: -23.4356,
                                  lng: -46.4731,
                                );
                                
                                // Shopping Iguatemi São Paulo
                                _destinationController.text = 'Shopping Iguatemi São Paulo';
                                _destinationPlace = PlaceDetails(
                                  placeId: 'ChIJH5wKoNNXzpQRpV0IVV0VJAQ',
                                  name: 'Shopping Iguatemi São Paulo',
                                  formattedAddress: 'Av. Brg. Faria Lima, 2232 - Jardim Paulistano, São Paulo - SP, Brasil',
                                  lat: -23.5686,
                                  lng: -46.6850,
                                );
                                
                                setState(() {});
                                _onAddressChanged();
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.blue.withOpacity(0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Aeroporto → Shopping',
                                style: TextStyle(color: Colors.blue, fontSize: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextButton(
                              onPressed: () async {
                                // Centro de São Paulo (Sé)
                                _pickupController.text = 'Catedral da Sé';
                                _pickupPlace = PlaceDetails(
                                  placeId: 'ChIJleh_xFNYzpQRNRPgIlYPjwE',
                                  name: 'Catedral da Sé',
                                  formattedAddress: 'Praça da Sé - Sé, São Paulo - SP, Brasil',
                                  lat: -23.5507,
                                  lng: -46.6355,
                                );
                                
                                // Estádio do Morumbi
                                _destinationController.text = 'Estádio do Morumbi';
                                _destinationPlace = PlaceDetails(
                                  placeId: 'ChIJZzN8e4JZzpQR8z5BXY4HRVA',
                                  name: 'Estádio do Morumbi',
                                  formattedAddress: 'Praça Roberto Gomes Pedrosa, 1 - Morumbi, São Paulo - SP, Brasil',
                                  lat: -23.6009,
                                  lng: -46.7217,
                                );
                                
                                setState(() {});
                                _onAddressChanged();
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.blue.withOpacity(0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Centro → Morumbi',
                                style: TextStyle(color: Colors.blue, fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 2), // Corridas
    );
  }
}