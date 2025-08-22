import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../maps/providers/map_provider.dart';
import '../../ride/providers/ride_provider.dart';

class UberRideRequestScreen extends StatefulWidget {
  const UberRideRequestScreen({super.key});

  @override
  State<UberRideRequestScreen> createState() => _UberRideRequestScreenState();
}

class _UberRideRequestScreenState extends State<UberRideRequestScreen>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  Position? _currentPosition;
  String _selectedVehicleType = 'economy';
  String _selectedPayment = 'pix';
  
  // Animation controllers
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  
  // Ride status
  RideStatus _rideStatus = RideStatus.inputDestination;
  Map<String, dynamic>? _currentRide;
  Duration _estimatedTime = Duration.zero;
  double _estimatedPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _getCurrentLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RideProvider>().loadVehicleCategories();
    });
  }

  void _initAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeInOut));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Serviço de localização desabilitado'),
            backgroundColor: Colors.red,
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

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
      });

      final mapProvider = context.read<MapProvider>();
      await mapProvider.setPickupLocation(
        LatLng(position.latitude, position.longitude),
      );

      // Auto-fill pickup address
      try {
        _pickupController.text = 'Obtendo endereço...';
        final address = await mapProvider.getAddressFromCoordinates(
          position.latitude, 
          position.longitude
        );
        if (address != null) {
          _pickupController.text = address;
        } else {
          _pickupController.text = 'Localização atual';
        }
      } catch (e) {
        _pickupController.text = 'Localização atual';
      }

      // Move camera to current location
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 15,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Erro ao obter localização: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao obter localização: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentPosition != null) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            zoom: 15,
          ),
        ),
      );
    }
  }

  Future<void> _requestRide() async {
    if (_destinationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, informe o destino'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _rideStatus = RideStatus.searching;
    });

    _slideController.forward();
    _pulseController.repeat(reverse: true);

    try {
      // Simulate ride request
      await Future.delayed(const Duration(seconds: 3));
      
      setState(() {
        _rideStatus = RideStatus.driverFound;
        _currentRide = {
          'driver': {
            'name': 'João Silva',
            'rating': 4.8,
            'vehicle': 'Honda Civic - ABC-1234',
            'photo': null,
          },
          'estimated_arrival': 5,
        };
      });

      _pulseController.stop();
      _pulseController.reset();

      // Wait for driver
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _rideStatus = RideStatus.driverArriving;
      });

      // Simulate ride progress
      await Future.delayed(const Duration(seconds: 10));
      
      setState(() {
        _rideStatus = RideStatus.inRide;
      });

      // Simulate ride completion
      await Future.delayed(const Duration(seconds: 15));
      
      setState(() {
        _rideStatus = RideStatus.completed;
      });

      // Show rating dialog
      await Future.delayed(const Duration(seconds: 2));
      _showRatingDialog();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao solicitar corrida: $e'),
          backgroundColor: Colors.red,
        ),
      );
      
      setState(() {
        _rideStatus = RideStatus.inputDestination;
      });
      
      _slideController.reverse();
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  void _cancelRide() {
    setState(() {
      _rideStatus = RideStatus.inputDestination;
      _currentRide = null;
    });
    
    _slideController.reverse();
    _pulseController.stop();
    _pulseController.reset();
  }

  void _showRatingDialog() {
    int rating = 5;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Como foi sua viagem?',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFF00FF00),
              child: const Icon(Icons.person, color: Colors.black, size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              _currentRide?['driver']['name'] ?? 'Motorista',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    setState(() {
                      rating = index + 1;
                    });
                  },
                  icon: Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                );
              }),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Return to main screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00FF00),
            ),
            child: const Text(
              'Enviar Avaliação',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Map
          Consumer<MapProvider>(
            builder: (context, mapProvider, child) {
              return GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _currentPosition != null
                      ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                      : const LatLng(-23.5505, -46.6333), // São Paulo
                  zoom: 15,
                ),
                markers: Set<Marker>.from([
                  if (mapProvider.pickupLocation != null)
                    Marker(
                      markerId: const MarkerId('pickup'),
                      position: mapProvider.pickupLocation!,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen,
                      ),
                      infoWindow: const InfoWindow(title: 'Origem'),
                    ),
                  if (mapProvider.destinationLocation != null)
                    Marker(
                      markerId: const MarkerId('destination'),
                      position: mapProvider.destinationLocation!,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed,
                      ),
                      infoWindow: const InfoWindow(title: 'Destino'),
                    ),
                ]),
                polylines: mapProvider.polylines,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                mapType: MapType.normal,
                zoomControlsEnabled: false,
              );
            },
          ),

          // Top Address Input
          if (_rideStatus == RideStatus.inputDestination)
            Positioned(
              top: MediaQuery.of(context).padding.top,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Pickup Address (read-only)
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Color(0xFF00FF00),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _pickupController,
                              enabled: false,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Onde você está?',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    Container(
                      height: 1,
                      color: Colors.grey[300],
                      margin: const EdgeInsets.only(left: 44),
                    ),

                    // Destination Input
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _destinationController,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Para onde vamos?',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (value) {
                                // TODO: Implement address autocomplete
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom Sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, (1 - _slideAnimation.value) * 400),
                  child: _buildBottomSheet(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet() {
    switch (_rideStatus) {
      case RideStatus.inputDestination:
        return _buildDestinationSheet();
      case RideStatus.searching:
        return _buildSearchingSheet();
      case RideStatus.driverFound:
        return _buildDriverFoundSheet();
      case RideStatus.driverArriving:
        return _buildDriverArrivingSheet();
      case RideStatus.inRide:
        return _buildInRideSheet();
      case RideStatus.completed:
        return _buildCompletedSheet();
    }
  }

  Widget _buildDestinationSheet() {
    if (_destinationController.text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Escolha uma opção',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Vehicle options
                Consumer<RideProvider>(
                  builder: (context, rideProvider, child) {
                    return Column(
                      children: rideProvider.vehicleCategories.map((category) {
                        return _buildVehicleOption(
                          category.name,
                          category.displayName ?? category.name,
                          'R\$ ${category.baseFareValue.toStringAsFixed(2)}',
                          _getVehicleIcon(category.name),
                          category.name == _selectedVehicleType,
                        );
                      }).toList(),
                    );
                  },
                ),
                
                const SizedBox(height: 20),
                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _requestRide,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Confirmar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleOption(String id, String name, String price, IconData icon, bool selected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedVehicleType = id;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: selected ? Colors.black : Colors.grey[300]!,
                width: selected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, size: 30, color: Colors.black),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '5 min • $price',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  const Icon(Icons.check_circle, color: Colors.black),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchingSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.directions_car,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              'Procurando motorista...',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Aguarde um momento',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 20),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: _cancelRide,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverFoundSheet() {
    final driver = _currentRide?['driver'];
    
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Motorista encontrado!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            
            const SizedBox(height: 20),
            
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[300],
                  child: const Icon(Icons.person, size: 30, color: Colors.grey),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver?['name'] ?? 'Motorista',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${driver?['rating'] ?? 4.8}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      
                      Text(
                        driver?['vehicle'] ?? 'Veículo',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Column(
                  children: [
                    const Icon(Icons.access_time, color: Colors.green),
                    Text(
                      '${_currentRide?['estimated_arrival'] ?? 5} min',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement call driver
                    },
                    icon: const Icon(Icons.phone, color: Colors.green),
                    label: const Text(
                      'Ligar',
                      style: TextStyle(color: Colors.green),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.green),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                Expanded(
                  child: OutlinedButton(
                    onPressed: _cancelRide,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverArrivingSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Motorista a caminho',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'O motorista está chegando no local de embarque',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green),
              ),
              child: const Row(
                children: [
                  Icon(Icons.location_on, color: Colors.green),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Aguarde no local de embarque',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInRideSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Em viagem',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Chegando ao destino em aproximadamente 15 minutos',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement emergency contact
                    },
                    icon: const Icon(Icons.emergency, color: Colors.red),
                    label: const Text(
                      'Emergência',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement share trip
                    },
                    icon: const Icon(Icons.share, color: Colors.blue),
                    label: const Text(
                      'Compartilhar',
                      style: TextStyle(color: Colors.blue),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 80,
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              'Viagem concluída!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Obrigado por usar o Play Viagens',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getVehicleIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'economy':
        return Icons.directions_car;
      case 'comfort':
        return Icons.car_rental;
      case 'premium':
        return Icons.local_taxi;
      case 'moto':
        return Icons.two_wheeler;
      default:
        return Icons.directions_car;
    }
  }
}

enum RideStatus {
  inputDestination,
  searching,
  driverFound,
  driverArriving,
  inRide,
  completed,
}