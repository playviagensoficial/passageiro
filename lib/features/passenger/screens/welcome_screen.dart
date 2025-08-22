import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/widgets/app_bottom_navigation.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Logo Play Viagens
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FF00),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.black,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'play',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          height: 0.9,
                        ),
                      ),
                      Text(
                        'Viagens',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 40),

              // Campo de busca com botão "Mais tarde"
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF00FF00), width: 2),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(
                        Icons.search,
                        color: Colors.grey,
                        size: 24,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Eii, Para onde vamos hoje ?',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/request-ride');
                        },
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 4),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/schedule-ride');
                        },
                        icon: const Icon(Icons.schedule, size: 18),
                        label: const Text(
                          'Mais tarde',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00FF00),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Histórico de viagens
              Expanded(
                child: Column(
                  children: [
                    // Terminal Rodoviário de Chapecó
                    _buildTripHistoryItem(
                      icon: Icons.play_arrow,
                      title: 'Terminal Rodoviário de Chapecó',
                      subtitle: 'Rua Líbano - Passo dos Fortes - Chapecó - SC',
                      time: '05 de jan. 09:32AM',
                      price: 'R\$ 12,90',
                    ),

                    const SizedBox(height: 16),

                    // Shopping Pátio Chapecó
                    _buildTripHistoryItem(
                      icon: Icons.play_arrow,
                      title: 'Shopping Pátio Chapecó',
                      subtitle: 'Av. Fernando Machado - D.400 - Chapecó - SC',
                      time: '05 de jan. 20:45PM',
                      price: 'R\$ 19,90',
                    ),

                    const SizedBox(height: 16),

                    // Magazine Luiza Curitiba
                    _buildTripHistoryItem(
                      icon: Icons.play_arrow,
                      title: 'Magazine e Luiza Curitiba',
                      subtitle: 'Av. Trindade Centro - Curitiba - PR',
                      time: '16 de dez. 13:23PM',
                      price: 'R\$ 11,90',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Formas para usar o App
              const Text(
                'Formas para usar o App',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // Cards Envios e Viagens
              Row(
                children: [
                  Expanded(
                    child: _buildServiceCard(
                      title: 'Envios!',
                      subtitle: 'Solicite e acompanhe suas entregas em tempo real com praticidade e segurança.',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Funcionalidade de Envios em desenvolvimento'),
                            backgroundColor: Color(0xFF00FF00),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildServiceCard(
                      title: 'Viagens!',
                      subtitle: 'Solicite e acompanhe suas entregas em tempo real com praticidade e segurança.',
                      onTap: () {
                        Navigator.pushNamed(context, '/request-ride');
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      
      // Bottom Navigation
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 0),
    );
  }

  Widget _buildTripHistoryItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required String price,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00FF00), width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.black,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(
                  color: Color(0xFF00FF00),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                price,
                style: const TextStyle(
                  color: Color(0xFF00FF00),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF00FF00), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}