import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/play_logo.dart';
import '../../../shared/theme/app_theme.dart';

class PassengerHomeScreen extends StatelessWidget {
  const PassengerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final user = authProvider.currentUser;
            
            return Column(
              children: [
                // Header com logo - Conforme wireframe "Tela Inicial"
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  child: const PlayLogoHorizontal(height: 40),
                ),

                // Conteúdo principal conforme wireframe "Tela Inicial"
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),
                        
                        // Saudação - Conforme wireframe
                        Text(
                          'Olá, ${user?.name ?? 'Passageiro'}!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        const Text(
                          'Para onde vamos hoje?',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        
                        const SizedBox(height: 80),
                        
                        // Botão Solicitar Corrida - Conforme wireframe "Tela Inicial"
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/new-request-ride');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Solicitar Corrida',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Seção de navegação rápida
                        Row(
                          children: [
                            Expanded(
                              child: _buildServiceCard(
                                context,
                                'Corridas',
                                Icons.directions_car,
                                () {
                                  Navigator.pushNamed(context, '/passenger-rides');
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildServiceCard(
                                context,
                                'Carteira',
                                Icons.account_balance_wallet,
                                () {
                                  Navigator.pushNamed(context, '/passenger-wallet');
                                },
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        Row(
                          children: [
                            Expanded(
                              child: _buildServiceCard(
                                context,
                                'Perfil',
                                Icons.person,
                                () {
                                  Navigator.pushNamed(context, '/passenger-profile');
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildServiceCard(
                                context,
                                'Suporte',
                                Icons.help_outline,
                                () {
                                  Navigator.pushNamed(context, '/support');
                                },
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        Row(
                          children: [
                            Expanded(
                              child: _buildServiceCard(
                                context,
                                'WhatsApp',
                                Icons.message,
                                () {
                                  Navigator.pushNamed(context, '/whatsapp');
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(child: Container()), // Espaço vazio para manter o layout
                          ],
                        ),
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Card de serviço
  Widget _buildServiceCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryColor, width: 2),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}