import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/play_logo.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/api/api_client.dart';
import '../../../core/services/google_maps_service.dart';
import '../../../core/services/payment_service.dart';
import '../widgets/address_autocomplete_field.dart';
import '../widgets/payment_method_selector.dart';

class NewRequestRideScreen extends StatefulWidget {
  const NewRequestRideScreen({super.key});

  @override
  State<NewRequestRideScreen> createState() => _NewRequestRideScreenState();
}

class _NewRequestRideScreenState extends State<NewRequestRideScreen> {
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  String _selectedCategory = 'Play Econômico';
  bool _isLoading = false;

  List<Map<String, dynamic>> _vehicleCategories = [];
  bool _loadingCategories = true;
  
  // Geolocation and address data
  Position? _currentPosition;
  PlaceDetails? _originPlace;
  PlaceDetails? _destinationPlace;
  bool _loadingLocation = false;
  
  // Fare calculation
  Map<String, dynamic>? _fareEstimate;
  
  // Payment
  String _selectedPaymentMethod = 'card';
  
  // Driver status
  bool _isDriverOnline = true;

  @override
  void initState() {
    super.initState();
    _loadVehicleCategories();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _loadVehicleCategories() async {
    try {
      final apiClient = ApiClient.instance;
      final response = await apiClient.getVehicleCategories();
      
      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        final categories = (responseData['data'] ?? responseData) as List;
        setState(() {
          _vehicleCategories = categories.map((category) => {
            'id': category['id'],
            'name': category['name'],
            'price': 'R\$ ${(category['base_price'] ?? 8.50).toStringAsFixed(2)}',
            'time': '${(category['estimated_time'] ?? 3)} min',
            'icon': _getCategoryIcon(category['name']),
            'rating': 4.5, // Default rating
          }).toList();
          
          if (_vehicleCategories.isNotEmpty) {
            _selectedCategory = _vehicleCategories.first['name'];
          }
          _loadingCategories = false;
        });
      } else {
        // Fallback to default categories
        _setDefaultCategories();
      }
    } catch (e) {
      print('Erro ao carregar categorias: $e');
      _setDefaultCategories();
    }
  }

  void _setDefaultCategories() {
    setState(() {
      _vehicleCategories = [
        {
          'id': 1,
          'name': 'Play Econômico',
          'price': 'R\$ 8,50',
          'time': '3 min',
          'icon': Icons.directions_car,
          'rating': 4.5,
        },
        {
          'id': 2,
          'name': 'Play Confort',
          'price': 'R\$ 12,90',
          'time': '5 min',
          'icon': Icons.local_taxi,
          'rating': 4.7,
        },
        {
          'id': 3,
          'name': 'Play Premium',
          'price': 'R\$ 18,50',
          'time': '7 min',
          'icon': Icons.car_rental,
          'rating': 4.9,
        },
      ];
      _selectedCategory = 'Play Econômico';
      _loadingCategories = false;
    });
  }

  IconData _getCategoryIcon(String categoryName) {
    if (categoryName.toLowerCase().contains('premium')) {
      return Icons.car_rental;
    } else if (categoryName.toLowerCase().contains('confort')) {
      return Icons.local_taxi;
    } else {
      return Icons.directions_car;
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _loadingLocation = true;
    });

    try {
      // Check permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Serviços de localização estão desabilitados');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permissão de localização negada');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permissão de localização negada permanentemente');
      }

      // Get current position
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      final address = await GoogleMapsService.getReverseGeocode(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      if (address != null) {
        _originController.text = address;
        _originPlace = PlaceDetails(
          placeId: 'current_location',
          name: 'Localização Atual',
          formattedAddress: address,
          lat: _currentPosition!.latitude,
          lng: _currentPosition!.longitude,
        );
      }
    } catch (e) {
      print('❌ Erro ao obter localização: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao obter localização: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _loadingLocation = false;
      });
    }
  }

  void _onOriginSelected(PlaceDetails place) {
    setState(() {
      _originPlace = place;
      _originController.text = place.formattedAddress;
    });
    _calculateFareIfReady();
  }

  void _onDestinationSelected(PlaceDetails place) {
    setState(() {
      _destinationPlace = place;
      _destinationController.text = place.formattedAddress;
    });
    _calculateFareIfReady();
  }

  void _toggleDriverStatus() {
    setState(() {
      _isDriverOnline = !_isDriverOnline;
    });
    
    // Mostrar feedback visual
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isDriverOnline 
            ? '✅ Você está online e disponível para corridas' 
            : '⏸️ Você está offline - não receberá novas corridas',
        ),
        backgroundColor: _isDriverOnline ? AppTheme.primaryColor : Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
    
    print('🔄 Status do motorista alterado para: ${_isDriverOnline ? "ONLINE" : "OFFLINE"}');
  }

  Future<void> _calculateFareIfReady() async {
    if (_originPlace == null || _destinationPlace == null) return;

    try {
      final routeInfo = await GoogleMapsService.getRouteInfo(
        originLat: _originPlace!.lat,
        originLng: _originPlace!.lng,
        destLat: _destinationPlace!.lat,
        destLng: _destinationPlace!.lng,
      );

      if (routeInfo != null) {
        // Update vehicle categories with real pricing
        setState(() {
          _vehicleCategories = _vehicleCategories.map((category) {
            // Mapear nomes para categorias reconhecidas pelo serviço
            String categoryName = category['name'].toLowerCase();
            if (categoryName.contains('econômico') || categoryName.contains('economico')) {
              categoryName = 'economy';
            } else if (categoryName.contains('confort') || categoryName.contains('comfort')) {
              categoryName = 'comfort';
            } else if (categoryName.contains('premium')) {
              categoryName = 'premium';
            } else {
              categoryName = 'economy'; // fallback
            }
            
            final fare = GoogleMapsService.calculatePassengerFareEstimate(
              distanceMeters: routeInfo.distanceValue,
              durationSeconds: routeInfo.durationValue,
              vehicleCategory: categoryName,
            );
            
            return {
              ...category,
              'price': 'R\$ ${fare.toStringAsFixed(2)}',
              'time': routeInfo.duration,
              'distance': routeInfo.distance,
            };
          }).toList();

          _fareEstimate = {
            'distance': routeInfo.distance,
            'duration': routeInfo.duration,
            'distanceValue': routeInfo.distanceValue,
            'durationValue': routeInfo.durationValue,
          };
        });
      }
    } catch (e) {
      print('❌ Erro ao calcular tarifa: $e');
    }
  }

  Future<void> _requestRide() async {
    // Verificar se o motorista está online
    if (!_isDriverOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Você precisa estar online para solicitar corridas'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_originPlace == null || _destinationPlace == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione origem e destino válidos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final apiClient = ApiClient.instance;
      
      // Encontrar a categoria selecionada
      final selectedCategoryData = _vehicleCategories.firstWhere(
        (category) => category['name'] == _selectedCategory,
        orElse: () => _vehicleCategories.first,
      );

      // Calculate final fare estimate
      final categoryName = selectedCategoryData['name'].toLowerCase();
      final estimatedFare = GoogleMapsService.calculatePassengerFareEstimate(
        distanceMeters: _fareEstimate?['distanceValue'] ?? 5600,
        durationSeconds: _fareEstimate?['durationValue'] ?? 600,
        vehicleCategory: categoryName,
      );

      print('🚗 Solicitando corrida com categoria: ${selectedCategoryData['id']}');
      print('💰 Tarifa estimada: R\$ ${estimatedFare.toStringAsFixed(2)}');
      
      final response = await apiClient.requestRide(
        pickupAddress: _originPlace!.formattedAddress,
        pickupLatitude: _originPlace!.lat,
        pickupLongitude: _originPlace!.lng,
        destinationAddress: _destinationPlace!.formattedAddress,
        destinationLatitude: _destinationPlace!.lat,
        destinationLongitude: _destinationPlace!.lng,
        vehicleCategory: selectedCategoryData['id'],
        paymentMethod: _selectedPaymentMethod,
        estimatedFare: estimatedFare,
        estimatedDistance: _fareEstimate?['distance'] ?? '5.6 km',
        estimatedDuration: _fareEstimate?['duration'] ?? '10 min',
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data != null) {
          final responseData = response.data;
          final rideId = responseData['id'] ?? responseData['data']?['id'];
          print('✅ Corrida criada com ID: $rideId');
          
          if (mounted) {
            // Navegar para tela de aguardando motorista
            Navigator.pushReplacementNamed(context, '/ride-waiting', arguments: {'rideId': rideId});
          }
        } else {
          throw Exception('Resposta vazia do servidor');
        }
      } else {
        final errorMessage = response.data?['error'] ?? response.data?['message'] ?? 'Erro desconhecido (${response.statusCode})';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('❌ Erro ao solicitar corrida: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao solicitar corrida: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const PlayLogoHorizontal(height: 32),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 28),
            onPressed: () {
              // Implementar chat/suporte
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Mapa ocupando metade superior da tela - Conforme wireframe
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              color: Colors.grey[300],
              child: Stack(
                children: [
                  // Placeholder para o mapa
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.map,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  
                  // Status "Em serviço"/"Offline" clicável - Conforme wireframe
                  Positioned(
                    top: 20,
                    right: 20,
                    child: GestureDetector(
                      onTap: _toggleDriverStatus,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _isDriverOnline ? AppTheme.primaryColor : Colors.orange,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: (_isDriverOnline ? AppTheme.primaryColor : Colors.orange).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Icon(
                                _isDriverOnline ? Icons.circle : Icons.pause_circle_filled,
                                key: ValueKey(_isDriverOnline),
                                color: Colors.black,
                                size: _isDriverOnline ? 8 : 12,
                              ),
                            ),
                            const SizedBox(width: 6),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Text(
                                _isDriverOnline ? 'Em serviço' : 'Offline',
                                key: ValueKey(_isDriverOnline),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Card inferior com formulário - Conforme wireframe
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Campos de origem e destino com autocomplete
                    AddressAutocompleteField(
                      controller: _originController,
                      hintText: _loadingLocation ? 'Obtendo localização...' : 'De onde você está?',
                      prefixIcon: Icons.radio_button_checked,
                      prefixIconColor: AppTheme.primaryColor,
                      onPlaceSelected: _onOriginSelected,
                      enabled: !_loadingLocation,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    AddressAutocompleteField(
                      controller: _destinationController,
                      hintText: 'Para onde você vai?',
                      prefixIcon: Icons.location_on,
                      prefixIconColor: AppTheme.primaryColor,
                      onPlaceSelected: _onDestinationSelected,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Categorias de veículo - Conforme wireframe
                    const Text(
                      'Escolha sua categoria',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    if (_loadingCategories)
                      const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                        ),
                      )
                    else
                      ...(_vehicleCategories.map((category) => _buildVehicleCategory(category)).toList()),
                    
                    const SizedBox(height: 32),
                    
                    // Seletor de método de pagamento
                    PaymentMethodSelector(
                      selectedMethod: _selectedPaymentMethod,
                      onMethodSelected: (method) {
                        setState(() {
                          _selectedPaymentMethod = method;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Botão solicitar corrida - Conforme wireframe
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: (_isLoading || !_isDriverOnline) ? null : _requestRide,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isDriverOnline ? AppTheme.primaryColor : Colors.grey[400],
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _isDriverOnline ? 'Solicitar Corrida' : 'Você está Offline',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _isDriverOnline ? Colors.black : Colors.grey[600],
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildVehicleCategory(Map<String, dynamic> category) {
    final isSelected = _selectedCategory == category['name'];
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category['name'];
        });
        // Recalcular tarifas quando categoria for alterada
        _calculateFareIfReady();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              category['icon'],
              size: 32,
              color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category['name'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppTheme.primaryColor : Colors.black,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            category['price'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? AppTheme.primaryColor : Colors.black,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.star, color: Colors.orange, size: 16),
                          Text(
                            ' ${category['rating']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      if (_fareEstimate != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${category['time']} • ${category['distance'] ?? _fareEstimate!['distance']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 4),
                        Text(
                          category['time'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}