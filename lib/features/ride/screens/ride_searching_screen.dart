import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/ride_provider.dart';
import '../../../core/models/ride.dart';

class RideSearchingScreen extends StatefulWidget {
  const RideSearchingScreen({super.key});

  @override
  State<RideSearchingScreen> createState() => _RideSearchingScreenState();
}

class _RideSearchingScreenState extends State<RideSearchingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Set navigation context for automatic screen transitions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RideProvider>().setNavigationContext(context);
    });
    
    // Pulse animation for the center circle
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Ripple animation for expanding circles
    _rippleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rippleController.dispose();
    // Clear navigation context when widget is disposed
    if (mounted) {
      context.read<RideProvider>().clearNavigationContext();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<RideProvider>(
        builder: (context, rideProvider, child) {
          final ride = rideProvider.currentRide;
          
          if (ride == null) {
            return const Center(
              child: Text(
                'Erro: Nenhuma corrida encontrada',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return Stack(
            children: [
              // Background with subtle gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black,
                      Colors.grey.shade900,
                      Colors.black,
                    ],
                  ),
                ),
              ),
              
              // Main content
              SafeArea(
                child: Column(
                  children: [
                    // Top header
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Expanded(
                            child: Text(
                              'Procurando motorista',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                    
                    // Animated search area
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Animated ripple circles
                            SizedBox(
                              width: 300,
                              height: 300,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Ripple circles
                                  ...List.generate(3, (index) {
                                    return AnimatedBuilder(
                                      animation: _rippleAnimation,
                                      builder: (context, child) {
                                        final delay = index * 0.3;
                                        final animationValue = (_rippleAnimation.value - delay).clamp(0.0, 1.0);
                                        
                                        return Container(
                                          width: 300 * animationValue,
                                          height: 300 * animationValue,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: const Color(0xFF00FF00).withOpacity(
                                                (1 - animationValue) * 0.5
                                              ),
                                              width: 2,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }),
                                  
                                  // Center pulsing circle
                                  AnimatedBuilder(
                                    animation: _pulseAnimation,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _pulseAnimation.value,
                                        child: Container(
                                          width: 120,
                                          height: 120,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: const Color(0xFF00FF00),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF00FF00).withOpacity(0.3),
                                                blurRadius: 20,
                                                spreadRadius: 10,
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.directions_car,
                                            color: Colors.black,
                                            size: 50,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 40),
                            
                            // Status text
                            Text(
                              _getSearchStatusText(ride.status),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 12),
                            
                            Text(
                              _getSearchSubtitle(ride.status),
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 40),
                            
                            // Loading dots
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(3, (index) {
                                return AnimatedBuilder(
                                  animation: _rippleController,
                                  builder: (context, child) {
                                    final delay = index * 0.2;
                                    final animationValue = ((_rippleController.value - delay) % 1.0);
                                    final opacity = animationValue < 0.5 
                                        ? animationValue * 2 
                                        : (1 - animationValue) * 2;
                                    
                                    return Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFF00FF00).withOpacity(opacity),
                                      ),
                                    );
                                  },
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Bottom ride info card
                    Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF00FF00).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF00FF00),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  ride.pickupAddress,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  ride.destinationAddress,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 20),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Categoria',
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    ride.vehicleCategory.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              if (ride.fare != null)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Valor',
                                      style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      'R\$ ${ride.fare!.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Color(0xFF00FF00),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Cancel button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () => _showCancelDialog(context, rideProvider),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Cancelar Corrida',
                                style: TextStyle(
                                  color: Colors.red,
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
            ],
          );
        },
      ),
    );
  }

  String _getSearchStatusText(String status) {
    switch (status) {
      case 'requested':
        return 'Procurando motorista';
      case 'accepted':
        return 'Motorista encontrado!';
      default:
        return 'Processando solicitação';
    }
  }

  String _getSearchSubtitle(String status) {
    switch (status) {
      case 'requested':
        return 'Estamos encontrando o melhor motorista para você';
      case 'accepted':
        return 'Seu motorista está a caminho';
      default:
        return 'Aguarde um momento...';
    }
  }

  void _showCancelDialog(BuildContext context, RideProvider rideProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Cancelar corrida?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Tem certeza que deseja cancelar esta corrida?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Não',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await rideProvider.cancelRide();
              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Corrida cancelada com sucesso'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(
              'Sim, cancelar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}