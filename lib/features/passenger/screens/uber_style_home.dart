import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../maps/providers/map_provider.dart';
import '../../ride/providers/ride_provider.dart';
import '../widgets/ride_request_sheet.dart';
import '../widgets/address_search_bar.dart';
import '../widgets/uber_address_search_new.dart';
import '../widgets/simple_address_search.dart';
import '../widgets/bottom_navigation.dart';
import '../../ride/widgets/ride_confirmation_sheet.dart';

class UberStyleHome extends StatefulWidget {
  const UberStyleHome({super.key});

  @override
  State<UberStyleHome> createState() => _UberStyleHomeState();
}

class _UberStyleHomeState extends State<UberStyleHome> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set navigation context for automatic screen transitions
      context.read<RideProvider>().setNavigationContext(context);
      context.read<RideProvider>().loadVehicleCategories();
      
      // Auto-open address search on first load if no destination
      final mapProvider = context.read<MapProvider>();
      if (mapProvider.destinationLocation == null && mapProvider.pickupLocation != null) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted && mapProvider.destinationLocation == null) {
            _showAddressSearch();
          }
        });
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
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
    } catch (e) {
      debugPrint('Erro ao obter localização: $e');
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

  void _showAddressSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SimpleAddressSearch(),
    );
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentNavIndex = index;
    });
    
    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        Navigator.pushNamed(context, '/activity');
        break;
      case 2:
        Navigator.pushNamed(context, '/account');
        break;
    }
  }

  void _showVehicleSelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: const _VehicleSelectionSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        
        final mapProvider = context.read<MapProvider>();
        final rideProvider = context.read<RideProvider>();
        
        // If route is selected, clear it instead of popping
        if (mapProvider.destinationLocation != null) {
          mapProvider.clearRoute();
          rideProvider.clearSelection();
        } else {
          // If no route selected, actually pop
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: Consumer2<MapProvider, RideProvider>(
          builder: (context, mapProvider, rideProvider, child) {
          return Stack(
            children: [
              // Google Map
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _currentPosition != null 
                      ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                      : const LatLng(-23.5505, -46.6333), // São Paulo default
                  zoom: 15,
                ),
                markers: {
                  if (mapProvider.pickupLocation != null)
                    Marker(
                      markerId: const MarkerId('pickup'),
                      position: mapProvider.pickupLocation!,
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                      infoWindow: InfoWindow(
                        title: 'Origem',
                        snippet: mapProvider.pickupAddress,
                      ),
                    ),
                  if (mapProvider.destinationLocation != null)
                    Marker(
                      markerId: const MarkerId('destination'),
                      position: mapProvider.destinationLocation!,
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                      infoWindow: InfoWindow(
                        title: 'Destino',
                        snippet: mapProvider.destinationAddress,
                      ),
                    ),
                },
                polylines: mapProvider.polylines,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: false,
              ),

              // Top Search Bar (Uber Style - "Para onde?" with "Mais tarde" button)
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 12,
                right: 12,
                child: Column(
                  children: [
                    // Main search bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _showAddressSearch,
                          borderRadius: BorderRadius.circular(30),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    mapProvider.destinationAddress ?? 'Para onde?',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: mapProvider.destinationAddress != null 
                                          ? Colors.black87 
                                          : Colors.black54,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: GestureDetector(
                                    onTap: () => _showScheduleRide(),
                                    child: Row(
                                      children: [
                                        Icon(Icons.schedule, size: 16, color: Colors.grey[700]),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Mais tarde',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Address details (only show after destination is selected) - Clickable to edit
                    if (mapProvider.destinationLocation != null)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _showAddressSearch,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          mapProvider.pickupAddress ?? 'Localização atual',
                                          style: const TextStyle(
                                            fontSize: 12, 
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Icon(
                                        Icons.edit,
                                        size: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          mapProvider.destinationAddress ?? '',
                                          style: const TextStyle(
                                            fontSize: 12, 
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Vehicle Selection Bottom (Uber Style)
              if (mapProvider.destinationLocation != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
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
                        // Handle bar with close button
                        Padding(
                          padding: const EdgeInsets.only(top: 8, right: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Center(
                                  child: Container(
                                    width: 40,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // Clear route to return to initial state
                                  mapProvider.clearRoute();
                                  context.read<RideProvider>().clearSelection();
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.grey[600],
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Route info with duration
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          child: Column(
                            children: [
                              // Duration and distance info
                              if (mapProvider.routeDistance != null && mapProvider.routeDuration != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    '${mapProvider.routeDistance!.toStringAsFixed(1)} km • ${mapProvider.routeDuration} min',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              
                              // Route visualization
                              Row(
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF00CC00),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Container(
                                        width: 2,
                                        height: 20,
                                        color: Colors.grey[300],
                                      ),
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          mapProvider.pickupAddress ?? 'Origem',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          mapProvider.destinationAddress ?? 'Destino',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // Vehicle categories
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: rideProvider.vehicleCategories.length,
                            itemBuilder: (context, index) {
                              final category = rideProvider.vehicleCategories[index];
                              final isSelected = rideProvider.selectedCategory?.id == category.id;
                              final distance = mapProvider.calculateDistance();
                              final estimatedFare = distance != null && rideProvider.selectedCategory != null
                                  ? rideProvider.calculateEstimatedFare(distance)
                                  : category.baseFareValue;

                              return GestureDetector(
                                onTap: () => rideProvider.selectCategory(category),
                                child: Container(
                                  width: 100,
                                  margin: const EdgeInsets.only(right: 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.grey[100] : Colors.white,
                                    border: Border.all(
                                      color: isSelected ? Colors.black : Colors.grey[300]!,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _getVehicleIcon(category.name),
                                        size: 32,
                                        color: Colors.black,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        category.displayName ?? category.name,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'R\$ ${estimatedFare.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Request ride button
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: rideProvider.selectedCategory != null 
                                  ? () => _showRideRequest()
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Solicitar ${rideProvider.selectedCategory?.displayName ?? rideProvider.selectedCategory?.name ?? "Corrida"}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // My Location Button
              Positioned(
                bottom: mapProvider.destinationLocation != null ? 380 : 160,
                right: 16,
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: _getCurrentLocation,
                  child: const Icon(Icons.my_location, color: Colors.black),
                ),
              ),
            ],
          );
          },
        ),
        bottomNavigationBar: UberBottomNavigation(
          currentIndex: _currentNavIndex,
          onTap: _onBottomNavTap,
        ),
      ),
    );
  }

  void _showRideRequest() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RideConfirmationSheet(),
    );
  }
  
  void _showScheduleRide() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Agendar viagem',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            // Add date/time picker here
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.schedule, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Escolha data e hora da viagem',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Implement schedule logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Confirmar agendamento',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getVehicleIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'economy':
      case 'economica':
        return Icons.directions_car;
      case 'comfort':
      case 'confort':
        return Icons.car_rental;
      case 'premium':
        return Icons.directions_car;
      default:
        return Icons.directions_car;
    }
  }
  
  @override
  void dispose() {
    // Clear navigation context when widget is disposed
    if (mounted) {
      context.read<RideProvider>().clearNavigationContext();
    }
    super.dispose();
  }
}

class _VehicleSelectionSheet extends StatelessWidget {
  const _VehicleSelectionSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Escolha seu veículo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // Vehicle options will be added here
        ],
      ),
    );
  }
}