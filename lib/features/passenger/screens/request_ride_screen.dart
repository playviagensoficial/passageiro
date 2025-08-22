import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../maps/providers/map_provider.dart';
import '../../ride/providers/ride_provider.dart';
import '../widgets/ride_request_sheet.dart';
import '../widgets/vehicle_category_selector.dart';

class RequestRideScreen extends StatefulWidget {
  const RequestRideScreen({super.key});

  @override
  State<RequestRideScreen> createState() => _RequestRideScreenState();
}

class _RequestRideScreenState extends State<RequestRideScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RideProvider>().loadVehicleCategories();
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

      // Buscar endereço real usando geocoding reverso
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

  void _showRideRequestSheet() {
    if (context.read<MapProvider>().pickupLocation == null || 
        context.read<MapProvider>().destinationLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Defina origem e destino primeiro'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RideRequestSheet(),
    );
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
      body: Consumer2<MapProvider, RideProvider>(
        builder: (context, mapProvider, rideProvider, child) {
          return Column(
            children: [
              // Address Input Section
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[900],
                child: Column(
                  children: [
                    // Pickup Input
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _pickupController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.radio_button_checked, color: Color(0xFF00CC00)),
                          hintText: 'De onde?',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        readOnly: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Destination Input
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _destinationController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.location_on, color: Colors.red),
                          hintText: 'Para onde?',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search, color: Colors.grey),
                            onPressed: () {
                              // TODO: Implement address search
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Busca de endereços em desenvolvimento'),
                                  backgroundColor: Color(0xFF00CC00),
                                ),
                              );
                            },
                          ),
                        ),
                        onTap: () async {
                          // Demo: Set a sample destination
                          const sampleDestination = LatLng(-23.5489, -46.6388);
                          await mapProvider.setDestinationLocation(sampleDestination);
                          _destinationController.text = 'Aeroporto Internacional de São Paulo';
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Map Section
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
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
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: false,
                    ),
                    
                    // Current Location Button
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: FloatingActionButton(
                        mini: true,
                        backgroundColor: Colors.white,
                        onPressed: _getCurrentLocation,
                        child: const Icon(Icons.my_location, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),

              // Vehicle Category Selector
              const VehicleCategorySelector(),

              // Request Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _showRideRequestSheet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00CC00),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'CONFIRMAR LOCALIZAÇÃO',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }
}