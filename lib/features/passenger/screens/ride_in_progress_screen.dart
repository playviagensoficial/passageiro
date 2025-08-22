import 'package:flutter/material.dart';
import '../../../shared/widgets/play_logo.dart';
import '../../../shared/theme/app_theme.dart';

class RideInProgressScreen extends StatefulWidget {
  const RideInProgressScreen({super.key});

  @override
  State<RideInProgressScreen> createState() => _RideInProgressScreenState();
}

class _RideInProgressScreenState extends State<RideInProgressScreen> {
  String _rideStatus = 'driver_coming'; // driver_coming, trip_started, trip_completed
  int _timeRemaining = 420; // 7 minutos em segundos
  double _distanceRemaining = 3.1; // km
  
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
          if (_timeRemaining <= 0) {
            _rideStatus = 'trip_started';
          }
        });
        _startTimer();
      }
    });
  }

  void _completeRide() {
    setState(() {
      _rideStatus = 'trip_completed';
    });
    
    // Navegar para tela de pagamento após 2 segundos
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/ride-payment', arguments: {
          'rideId': 1, // Replace with actual ride ID
          'rideAmount': 12.50, // Replace with actual ride amount
          'driverId': 'driver_123', // Replace with actual driver ID
          'driverName': 'João Silva', // Replace with actual driver name
        });
      }
    });
  }

  void _cancelRide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Corrida'),
        content: const Text('Tem certeza que deseja cancelar esta corrida?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/passenger-home');
            },
            child: const Text('Sim'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
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
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 28),
            onPressed: () {
              // Implementar chat com motorista
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Mapa ocupando a parte superior
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
                  
                  // Status da corrida
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: Colors.black, size: 8),
                          const SizedBox(width: 6),
                          Text(
                            _getStatusText(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Informações do motorista (quando a viagem começar)
                  if (_rideStatus == 'trip_started')
                    Positioned(
                      top: 70,
                      left: 20,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey[300],
                              child: const Icon(Icons.person, color: Colors.grey),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'João Silva',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'VW Gol • ABC-1234',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.orange, size: 12),
                                    const Text(
                                      ' 4,5',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Card inferior com informações da corrida
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
                  // Botão de cancelar/fechar
                  Positioned(
                    top: 20,
                    right: 20,
                    child: GestureDetector(
                      onTap: _rideStatus == 'trip_completed' ? null : _cancelRide,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _rideStatus == 'trip_completed' ? Icons.check : Icons.close,
                          color: _rideStatus == 'trip_completed' ? AppTheme.primaryColor : Colors.black,
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
                        // Título baseado no status
                        Text(
                          _getTitleText(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Informações de tempo/distância
                        if (_rideStatus == 'driver_coming') ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.primaryColor),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.access_time, color: AppTheme.primaryColor),
                                const SizedBox(width: 12),
                                Text(
                                  'Chegada em ${_formatTime(_timeRemaining)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          Text(
                            'Distância: ${_distanceRemaining.toStringAsFixed(1)} km',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                        
                        if (_rideStatus == 'trip_started') ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.navigation, color: Colors.blue),
                                const SizedBox(width: 12),
                                const Text(
                                  'Viagem em andamento',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          Text(
                            'Tempo estimado: 10 min',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                        
                        if (_rideStatus == 'trip_completed') ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.primaryColor),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: AppTheme.primaryColor),
                                const SizedBox(width: 12),
                                Text(
                                  'Viagem concluída!',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 24),
                        
                        // Informações da rota
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
                            
                            // Textos da rota
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Av. Lineul Machado, Henrique Jorge',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    'Alto da Glória e arredores',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 24),
                                  
                                  Text(
                                    'Rua São Francisco, 763',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    'Centro - Palmas - PR, 89770-000',
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
                        
                        // Botões de ação
                        if (_rideStatus == 'driver_coming') ...[
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Implementar chamada para motorista
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[200],
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.phone),
                                      SizedBox(width: 8),
                                      Text('Ligar'),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Implementar mensagem para motorista
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.message),
                                      SizedBox(width: 8),
                                      Text('Mensagem'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        
                        if (_rideStatus == 'trip_started') ...[
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: _completeRide,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Finalizar Viagem',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
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

  Color _getStatusColor() {
    switch (_rideStatus) {
      case 'driver_coming':
        return AppTheme.primaryColor;
      case 'trip_started':
        return Colors.blue;
      case 'trip_completed':
        return AppTheme.primaryColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  String _getStatusText() {
    switch (_rideStatus) {
      case 'driver_coming':
        return 'Motorista a caminho';
      case 'trip_started':
        return 'Em viagem';
      case 'trip_completed':
        return 'Viagem concluída';
      default:
        return 'Em serviço';
    }
  }

  String _getTitleText() {
    switch (_rideStatus) {
      case 'driver_coming':
        return 'Motorista a caminho';
      case 'trip_started':
        return 'Viagem em andamento';
      case 'trip_completed':
        return 'Chegamos ao destino!';
      default:
        return 'Aguardando...';
    }
  }
}