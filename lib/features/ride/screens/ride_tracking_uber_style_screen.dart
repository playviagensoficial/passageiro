import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/ride_provider.dart';
import '../../../core/models/ride.dart';

class RideTrackingUberStyleScreen extends StatefulWidget {
  const RideTrackingUberStyleScreen({super.key});

  @override
  State<RideTrackingUberStyleScreen> createState() => _RideTrackingUberStyleScreenState();
}

class _RideTrackingUberStyleScreenState extends State<RideTrackingUberStyleScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  Timer? _etaTimer;
  int _estimatedArrivalMinutes = 5;

  @override
  void initState() {
    super.initState();
    
    // Set navigation context for automatic screen transitions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RideProvider>().setNavigationContext(context);
    });
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    
    _slideController.forward();
    
    // Simulate ETA countdown
    _startETATimer();
  }

  void _startETATimer() {
    _etaTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_estimatedArrivalMinutes > 1 && mounted) {
        setState(() {
          _estimatedArrivalMinutes--;
        });
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _etaTimer?.cancel();
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
              // Map placeholder (would be Google Maps in production)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.grey.shade800,
                      Colors.grey.shade900,
                      Colors.black,
                    ],
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map,
                        size: 80,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Mapa em Tempo Real',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Top status bar
              SafeArea(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: const Color(0xFF00FF00).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00FF00),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getStatusText(ride.status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Driver info card with slide animation
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Handle bar
                        Container(
                          margin: const EdgeInsets.only(top: 12),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade600,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              // ETA and status
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$_estimatedArrivalMinutes min',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        _getETAText(ride.status),
                                        style: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00FF00).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFF00FF00).withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      ride.vehicleCategory.toUpperCase(),
                                      style: const TextStyle(
                                        color: Color(0xFF00FF00),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Driver info - Official Play Viagens wireframe
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    // Header with Play Viagens branding
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: const BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF00CC00),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Icon(
                                              Icons.play_arrow,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                              Text(
                                                'play',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  height: 0.9,
                                                ),
                                              ),
                                              Text(
                                                'Viagens',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 9,
                                                  height: 0.9,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Spacer(),
                                          const Text(
                                            'Seu Motorista',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // Driver information
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(16),
                                          bottomRight: Radius.circular(16),
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          // Vehicle info
                                          Container(
                                            padding: const EdgeInsets.all(14),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[50],
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(color: Colors.grey[200]!),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 42,
                                                  height: 42,
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF00CC00).withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: const Icon(
                                                    Icons.directions_car,
                                                    color: Color(0xFF00CC00),
                                                    size: 24,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                const Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'Honda Civic Prata',
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                      SizedBox(height: 2),
                                                      Text(
                                                        'ABC-1234',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          
                                          const SizedBox(height: 12),
                                          
                                          // Rating
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Colors.amber.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: const Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.star, color: Colors.amber, size: 18),
                                                SizedBox(width: 6),
                                                Text(
                                                  '4.9',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  '(248 viagens)',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          
                                          const SizedBox(height: 16),
                                          
                                          // Action buttons
                                          Row(
                                            children: [
                                              Expanded(
                                                child: ElevatedButton.icon(
                                                  onPressed: () => _callDriver(),
                                                  icon: const Icon(Icons.phone, size: 16),
                                                  label: const Text(
                                                    'Ligar',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.green,
                                                    foregroundColor: Colors.white,
                                                    elevation: 0,
                                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: ElevatedButton.icon(
                                                  onPressed: () => _messageDriver(),
                                                  icon: const Icon(Icons.chat, size: 16),
                                                  label: const Text(
                                                    'Chat',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFF00CC00),
                                                    foregroundColor: Colors.black,
                                                    elevation: 0,
                                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Trip progress
                              _buildTripProgress(ride),
                              
                              const SizedBox(height: 20),
                              
                              // Action buttons based on status
                              if (ride.status == 'accepted') ...[
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
                              ] else if (ride.status == 'completed') ...[
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: () => _showRatingDialog(context, rideProvider),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF00FF00),
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Avaliar Viagem',
                                      style: TextStyle(fontWeight: FontWeight.bold),
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
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildTripProgress(Ride ride) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
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
          
          Container(
            margin: const EdgeInsets.only(left: 4),
            child: Column(
              children: List.generate(3, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  width: 1,
                  height: 6,
                  color: Colors.grey.shade600,
                );
              }),
            ),
          ),
          
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
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
          
          if (ride.fare != null) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Valor da viagem',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
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
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'accepted':
        return 'Motorista a caminho';
      case 'in_progress':
        return 'Em viagem';
      case 'completed':
        return 'Viagem concluída';
      default:
        return 'Acompanhando viagem';
    }
  }

  String _getETAText(String status) {
    switch (status) {
      case 'accepted':
        return 'Tempo estimado de chegada';
      case 'in_progress':
        return 'Tempo estimado para destino';
      case 'completed':
        return 'Viagem finalizada';
      default:
        return 'Calculando tempo...';
    }
  }

  void _callDriver() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📞 Ligando para o motorista...'),
        backgroundColor: Color(0xFF00FF00),
      ),
    );
  }

  void _messageDriver() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('💬 Abrindo chat com o motorista...'),
        backgroundColor: Colors.blue,
      ),
    );
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
            child: const Text('Não', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await rideProvider.cancelRide();
              if (success && context.mounted) {
                Navigator.popUntil(context, (route) => route.isFirst);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sim, cancelar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context, RideProvider rideProvider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const RatingDialog(),
    );
  }
}

// Rating Dialog Component
class RatingDialog extends StatefulWidget {
  const RatingDialog({super.key});

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double _rating = 5.0;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Driver info
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF00FF00),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FF00).withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                color: Colors.black,
                size: 40,
              ),
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              'Como foi sua viagem com João?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Star rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _rating = (index + 1).toDouble();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: const Color(0xFF00FF00),
                      size: 40,
                    ),
                  ),
                );
              }),
            ),
            
            const SizedBox(height: 24),
            
            // Comment field
            TextField(
              controller: _commentController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Deixe um comentário (opcional)',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade600),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF00FF00)),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Submit button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => _submitRating(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FF00),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Enviar Avaliação',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitRating() {
    Navigator.pop(context);
    Navigator.popUntil(context, (route) => route.isFirst);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Obrigado pela avaliação!'),
        backgroundColor: Color(0xFF00FF00),
      ),
    );
  }
}