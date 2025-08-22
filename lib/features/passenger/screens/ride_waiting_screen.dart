import 'package:flutter/material.dart';
import 'dart:async';
import '../../../shared/widgets/play_logo.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/api/api_client.dart';

class RideWaitingScreen extends StatefulWidget {
  const RideWaitingScreen({super.key});

  @override
  State<RideWaitingScreen> createState() => _RideWaitingScreenState();
}

class _RideWaitingScreenState extends State<RideWaitingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _carController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _carAnimation;
  
  Map<String, dynamic>? _rideData;
  Timer? _statusCheckTimer;
  String _currentStatus = 'pending';
  int _rideId = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    // Animation controllers
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _carController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _carAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _carController,
      curve: Curves.elasticOut,
    ));
    
    // Start animations
    _pulseController.repeat(reverse: true);
    _carController.forward();
    
    // Get ride data from arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['rideId'] != null) {
        _rideId = args['rideId'];
        _startStatusCheck();
      } else {
        _handleError('ID da corrida não encontrado');
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _carController.dispose();
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  void _startStatusCheck() {
    _checkRideStatus();
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _checkRideStatus();
    });
  }

  Future<void> _checkRideStatus() async {
    try {
      final apiClient = ApiClient.instance;
      final response = await apiClient.getRideDetails(_rideId);
      
      if (response.statusCode == 200 && response.data != null) {
        final rideData = response.data;
        setState(() {
          _rideData = rideData;
          _currentStatus = rideData['status'] ?? 'pending';
          _isLoading = false;
        });
        
        print('🔄 Status da corrida $_rideId: $_currentStatus');
        
        // Handle status changes
        switch (_currentStatus) {
          case 'accepted':
            _navigateToAccepted();
            break;
          case 'in_progress':
            _navigateToInProgress();
            break;
          case 'completed':
            _navigateToPayment();
            break;
          case 'cancelled':
            _navigateToHome('Corrida cancelada');
            break;
        }
      }
    } catch (e) {
      print('❌ Erro ao verificar status da corrida: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToAccepted() {
    if (mounted) {
      Navigator.pushReplacementNamed(
        context, 
        '/ride-accepted',
        arguments: {'rideId': _rideId, 'rideData': _rideData},
      );
    }
  }

  void _navigateToInProgress() {
    if (mounted) {
      Navigator.pushReplacementNamed(
        context, 
        '/ride-in-progress',
        arguments: {'rideId': _rideId, 'rideData': _rideData},
      );
    }
  }

  void _navigateToPayment() {
    if (mounted) {
      Navigator.pushReplacementNamed(
        context, 
        '/ride-payment',
        arguments: {
          'rideId': _rideId,
          'rideAmount': _rideData?['fare'] ?? '0.00',
          'driverId': _rideData?['driverId'],
          'driverName': _rideData?['driverName'] ?? 'Motorista',
        },
      );
    }
  }

  void _navigateToHome(String message) {
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/passenger-home',
        (route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _handleError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ $message'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _cancelRide() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'Cancelar Corrida',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Deseja realmente cancelar esta corrida?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Não', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Sim, Cancelar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final apiClient = ApiClient.instance;
        await apiClient.cancelRide(_rideId);
        _navigateToHome('Corrida cancelada com sucesso');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cancelar corrida: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Animation and status
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated car icon
                    ScaleTransition(
                      scale: _carAnimation,
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.primaryColor,
                                  width: 3,
                                ),
                              ),
                              child: const Icon(
                                Icons.directions_car,
                                size: 60,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Status text
                    Text(
                      _getStatusMessage(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      _getStatusDescription(),
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Loading indicator
                    if (_isLoading)
                      const CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                      ),
                    
                    // Ride details
                    if (_rideData != null) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow('Origem:', _rideData!['pickupAddress'] ?? 'Não informado'),
                            const SizedBox(height: 8),
                            _buildDetailRow('Destino:', _rideData!['destinationAddress'] ?? 'Não informado'),
                            const SizedBox(height: 8),
                            _buildDetailRow('Valor estimado:', 'R\$ ${_rideData!['fare'] ?? '0,00'}'),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Cancel button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _cancelRide,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancelar Corrida',
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
      ),
    );
  }

  String _getStatusMessage() {
    switch (_currentStatus) {
      case 'pending':
        return 'Procurando Motorista...';
      case 'accepted':
        return 'Motorista Encontrado!';
      case 'in_progress':
        return 'Viagem em Andamento';
      case 'completed':
        return 'Viagem Concluída';
      case 'cancelled':
        return 'Corrida Cancelada';
      default:
        return 'Aguardando...';
    }
  }

  String _getStatusDescription() {
    switch (_currentStatus) {
      case 'pending':
        return 'Estamos procurando um motorista próximo para você';
      case 'accepted':
        return 'Um motorista aceitou sua corrida e está a caminho';
      case 'in_progress':
        return 'Sua viagem está em andamento';
      case 'completed':
        return 'Obrigado por viajar conosco!';
      case 'cancelled':
        return 'A corrida foi cancelada';
      default:
        return 'Aguarde um momento...';
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}