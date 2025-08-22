import 'package:flutter/material.dart';
import '../../../shared/widgets/play_logo.dart';
import '../../../shared/theme/app_theme.dart';

class RideAcceptedScreen extends StatefulWidget {
  const RideAcceptedScreen({super.key});

  @override
  State<RideAcceptedScreen> createState() => _RideAcceptedScreenState();
}

class _RideAcceptedScreenState extends State<RideAcceptedScreen> {
  bool _isAccepted = false;

  void _acceptRide() {
    setState(() {
      _isAccepted = true;
    });
    
    // Navegar para próxima tela após aceitar
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/ride-in-progress');
      }
    });
  }

  void _cancelRide() {
    Navigator.pop(context);
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
              // Implementar chat
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Mapa ocupando a parte superior - Conforme wireframe
          Expanded(
            flex: 2,
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
                  
                  // Status "Em serviço" - Conforme wireframe
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: Colors.black, size: 8),
                          SizedBox(width: 6),
                          Text(
                            'Em serviço',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
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
          
          // Card inferior com detalhes da corrida - Conforme wireframe "Aceitar Corrida 5"
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
              child: Stack(
                children: [
                  // Botão X no canto superior direito
                  Positioned(
                    top: 20,
                    right: 20,
                    child: GestureDetector(
                      onTap: _cancelRide,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tag Play Econômico - Conforme wireframe
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.directions_car, color: Colors.black, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Play Econômico',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Preço - Conforme wireframe
                        const Text(
                          'R\$ 10,96',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Rating - Conforme wireframe
                        const Row(
                          children: [
                            Icon(Icons.star, color: Colors.black, size: 24),
                            SizedBox(width: 4),
                            Text(
                              '4,5',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Informações da viagem - Conforme wireframe
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Linha verde com pontos
                            Column(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Container(
                                  width: 2,
                                  height: 40,
                                  color: AppTheme.primaryColor,
                                ),
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    shape: BoxShape.rectangle,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(width: 16),
                            
                            // Textos da viagem
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '7 minutos (3.1 km) de distância',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Av. Lineul Machado, Henrique Jorge, Alto da Glória e arredores',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 24),
                                  
                                  const Text(
                                    'Viagem de 10 minutos (5,6 km)',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rua São Francisco, 763 - Centro - Palmas - PR, 89770-000',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const Spacer(),
                        
                        // Botão Aceitar - Conforme wireframe
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: _isAccepted ? null : _acceptRide,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isAccepted
                                ? const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check, color: Colors.black),
                                      SizedBox(width: 8),
                                      Text(
                                        'Corrida Aceita!',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  )
                                : const Text(
                                    'Aceitar',
                                    style: TextStyle(
                                      fontSize: 18,
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
            ),
          ),
        ],
      ),
    );
  }
}