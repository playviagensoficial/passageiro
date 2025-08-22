import 'package:flutter/material.dart';
import '../../../shared/widgets/play_logo.dart';
import '../../../shared/theme/app_theme.dart';

class PassengerRidesScreen extends StatefulWidget {
  const PassengerRidesScreen({super.key});

  @override
  State<PassengerRidesScreen> createState() => _PassengerRidesScreenState();
}

class _PassengerRidesScreenState extends State<PassengerRidesScreen> {
  // Mock data para demonstrar
  final List<Map<String, dynamic>> _rides = [
    {
      'destination': 'Centro Shopping',
      'date': '05 de jan. 09:32AM',
      'price': 'R\$ 12,90',
      'status': 'completed',
    },
    {
      'destination': 'Centro Shopping',
      'date': '05 de jan. 09:32AM',
      'price': 'R\$ 12,90',
      'status': 'completed',
    },
    {
      'destination': 'Centro Shopping',
      'date': '05 de jan. 09:32AM',
      'price': 'R\$ 12,90',
      'status': 'completed',
    },
    {
      'destination': 'Centro Shopping',
      'date': '05 de jan. 09:32AM',
      'price': 'R\$ 12,90',
      'status': 'completed',
    },
  ];

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
            icon: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.waves,
                color: Colors.black,
                size: 24,
              ),
            ),
            onPressed: () {
              // Implementar filtros ou configurações
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Título - Conforme wireframe
            const Text(
              'Suas Corridas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Mapa da última corrida - Conforme wireframe
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryColor, width: 3),
              ),
              child: Stack(
                children: [
                  // Placeholder para o mapa
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.map,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  
                  // Overlay com texto - Conforme wireframe
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(13),
                          bottomRight: Radius.circular(13),
                        ),
                      ),
                      child: const Text(
                        'Mapa da ultima corrida feita',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Primeira corrida destacada - Conforme wireframe
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: AppTheme.primaryColor, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _rides[0]['destination'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    _rides[0]['date'],
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    _rides[0]['price'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Lista de outras corridas - Conforme wireframe
            ...(_rides.skip(1).map((ride) => _buildRideItem(ride)).toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildRideItem(Map<String, dynamic> ride) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // Ícone Play - Conforme wireframe
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.play_arrow,
              color: Colors.black54,
              size: 30,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Informações da corrida - Conforme wireframe
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ride['destination'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  ride['date'],
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  ride['price'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}