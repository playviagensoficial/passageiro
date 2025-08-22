import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../maps/providers/map_provider.dart';
import '../../ride/providers/ride_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/widgets/safe_consumer2.dart';

class TestProvidersScreen extends StatelessWidget {
  const TestProvidersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Test Providers'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Test AuthProvider
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return Card(
                  color: Colors.grey[900],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AuthProvider',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Status: ${authProvider.isLoggedIn ? "Logado" : "Não logado"}',
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          'Loading: ${authProvider.isLoading}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            SizedBox(height: 16),
            
            // Test MapProvider
            Consumer<MapProvider>(
              builder: (context, mapProvider, child) {
                return Card(
                  color: Colors.grey[900],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MapProvider',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Localização atual: ${mapProvider.currentLocation?.toString() ?? "Não definida"}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            SizedBox(height: 16),
            
            // Test RideProvider
            Consumer<RideProvider>(
              builder: (context, rideProvider, child) {
                return Card(
                  color: Colors.grey[900],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RideProvider',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Categorias: ${rideProvider.vehicleCategories.length}',
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          'Loading: ${rideProvider.isLoading}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            SizedBox(height: 16),
            
            // Test SafeConsumer2
            SafeConsumer2<MapProvider, RideProvider>(
              builder: (context, mapProvider, rideProvider, child) {
                return Card(
                  color: Colors.grey[900],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Consumer2<MapProvider, RideProvider>',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '✅ Consumer2 funcionando corretamente!',
                          style: TextStyle(color: Colors.green),
                        ),
                        Text(
                          'Map: ${mapProvider.runtimeType}',
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          'Ride: ${rideProvider.runtimeType}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}