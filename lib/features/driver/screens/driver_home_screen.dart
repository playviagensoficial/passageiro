import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../maps/providers/map_provider.dart';
import '../../maps/widgets/google_map_widget.dart';
import '../../ride/providers/ride_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/driver_provider.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocation();
    });
  }

  Future<void> _initializeLocation() async {
    final mapProvider = context.read<MapProvider>();
    await mapProvider.getCurrentLocation();
  }

  void _toggleOnlineStatus() async {
    final driverProvider = context.read<DriverProvider>();
    await driverProvider.toggleOnlineStatus();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(driverProvider.isOnline ? 'Você está ONLINE' : 'Você está OFFLINE'),
          backgroundColor: driverProvider.isOnline ? const Color(0xFF00CC00) : Colors.grey[700],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer4<MapProvider, RideProvider, AuthProvider, DriverProvider>(
        builder: (context, mapProvider, rideProvider, authProvider, driverProvider, child) {
          return Stack(
            children: [
              // Map
              if (mapProvider.currentLocation != null)
                GoogleMapWidget(
                  initialPosition: mapProvider.currentLocation!,
                  markers: mapProvider.markers,
                  polylines: mapProvider.polylines,
                ),

              // App Bar
              SafeArea(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Menu Button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: () {
                            // TODO: Open drawer
                          },
                        ),
                      ),
                      const Spacer(),
                      // Earnings
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.attach_money, color: Color(0xFF00CC00), size: 16),
                            Text(
                              'R\$ 0,00',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Content
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Driver Info
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundColor: const Color(0xFF00CC00),
                                    child: Text(
                                      authProvider.currentUser?.name.substring(0, 1).toUpperCase() ?? 'M',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          authProvider.currentUser?.name ?? 'Motorista',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.star,
                                              color: Colors.yellow[600],
                                              size: 16,
                                            ),
                                            const Text(
                                              ' 4.8 • 127 viagens',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: driverProvider.isOnline ? const Color(0xFF00CC00) : Colors.grey[700],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      driverProvider.isOnline ? 'ONLINE' : 'OFFLINE',
                                      style: TextStyle(
                                        color: driverProvider.isOnline ? Colors.black : Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Online/Offline Toggle
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: driverProvider.isLoading ? null : _toggleOnlineStatus,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: driverProvider.isOnline ? Colors.grey[700] : const Color(0xFF00CC00),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: driverProvider.isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            driverProvider.isOnline ? Icons.stop : Icons.play_arrow,
                                            color: driverProvider.isOnline ? Colors.white : Colors.black,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            driverProvider.isOnline ? 'FICAR OFFLINE' : 'FICAR ONLINE',
                                            style: TextStyle(
                                              color: driverProvider.isOnline ? Colors.white : Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Quick Stats
                            Row(
                              children: [
                                Expanded(
                                  child: _StatCard(
                                    icon: Icons.timer,
                                    label: 'Online hoje',
                                    value: '${driverProvider.onlineTime.inHours}h ${driverProvider.onlineTime.inMinutes % 60}m',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _StatCard(
                                    icon: Icons.directions_car,
                                    label: 'Viagens hoje',
                                    value: '${driverProvider.dailyRides}',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _StatCard(
                                    icon: Icons.attach_money,
                                    label: 'Ganhos hoje',
                                    value: 'R\$ ${driverProvider.dailyEarnings.toStringAsFixed(0)}',
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Quick Actions
                            Row(
                              children: [
                                Expanded(
                                  child: _QuickActionButton(
                                    icon: Icons.history,
                                    label: 'Histórico',
                                    onTap: () {
                                      // TODO: Navigate to ride history
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _QuickActionButton(
                                    icon: Icons.account_balance_wallet,
                                    label: 'Ganhos',
                                    onTap: () {
                                      // TODO: Navigate to earnings
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _QuickActionButton(
                                    icon: Icons.person,
                                    label: 'Perfil',
                                    onTap: () {
                                      // TODO: Navigate to profile
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF00CC00), size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF00CC00), size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}