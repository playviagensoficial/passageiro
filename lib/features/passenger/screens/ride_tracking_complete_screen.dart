import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ride/providers/ride_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/services/google_maps_service.dart';

class RideTrackingCompleteScreen extends StatefulWidget {
  const RideTrackingCompleteScreen({super.key});

  @override
  State<RideTrackingCompleteScreen> createState() => _RideTrackingCompleteScreenState();
}

class _RideTrackingCompleteScreenState extends State<RideTrackingCompleteScreen> {
  bool _showRatingDialog = false;
  double _selectedRating = 5.0;
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Listen for ride completion to show rating dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rideProvider = context.read<RideProvider>();
      rideProvider.addListener(_onRideStateChanged);
    });
  }

  void _onRideStateChanged() {
    final rideProvider = context.read<RideProvider>();
    if (rideProvider.currentRide?.isCompleted == true && !_showRatingDialog) {
      setState(() {
        _showRatingDialog = true;
      });
      _showDriverRatingDialog();
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _showDriverRatingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Avalie sua experiência',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Como foi a sua viagem?',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 20),
            // Star rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRating = (index + 1).toDouble();
                    });
                  },
                  child: Icon(
                    index < _selectedRating ? Icons.star : Icons.star_border,
                    color: const Color(0xFF00FF00),
                    size: 40,
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            // Comment field
            TextField(
              controller: _commentController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Deixe um comentário (opcional)',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF333333)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF00FF00)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _submitRating(),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF00FF00),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Enviar Avaliação', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _submitRating() async {
    final rideProvider = context.read<RideProvider>();
    if (rideProvider.currentRide != null) {
      final success = await rideProvider.rateRide(
        rideProvider.currentRide!.id,
        _selectedRating,
        comment: _commentController.text.isNotEmpty ? _commentController.text : null,
      );

      if (success && mounted) {
        Navigator.of(context).pop(); // Close dialog
        Navigator.of(context).pop(); // Return to home
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Obrigado pela avaliação!'),
            backgroundColor: Color(0xFF00FF00),
          ),
        );
      }
    }
  }

  Future<void> _cancelRide() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Cancelar Corrida', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Tem certeza que deseja cancelar esta corrida?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Não', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sim, Cancelar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final rideProvider = context.read<RideProvider>();
      final success = await rideProvider.cancelRide();
      
      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Corrida cancelada'),
            backgroundColor: Colors.orange,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Acompanhar Corrida',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<RideProvider>(
        builder: (context, rideProvider, child) {
          final ride = rideProvider.currentRide;
          
          if (ride == null) {
            return const Center(
              child: Text(
                'Nenhuma corrida ativa',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Trip status header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF00FF00), width: 2),
                  ),
                  child: Column(
                    children: [
                      // Status indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _getStatusColor(ride.status),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getStatusText(ride.status),
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Trip progress
                      _buildTripProgress(ride.status),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Driver info (if assigned)
                if (ride.driverId != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: const Color(0xFF00FF00),
                          child: const Icon(Icons.person, color: Colors.black, size: 30),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Seu Motorista',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              const Text(
                                'João Silva', // Would come from driver data
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Color(0xFF00FF00), size: 16),
                                  const SizedBox(width: 4),
                                  const Text(
                                    '4.9 • Honda Civic Prata',
                                    style: TextStyle(color: Colors.grey, fontSize: 14),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              onPressed: () {
                                // Call driver
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('📞 Ligando para o motorista...')),
                                );
                              },
                              icon: const Icon(Icons.call, color: Color(0xFF00FF00)),
                            ),
                            IconButton(
                              onPressed: () {
                                // Message driver
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('💬 Abrindo chat...')),
                                );
                              },
                              icon: const Icon(Icons.message, color: Color(0xFF00FF00)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Trip details
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detalhes da Viagem',
                        style: TextStyle(
                          color: Color(0xFF00FF00),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Origin
                      Row(
                        children: [
                          const Icon(Icons.radio_button_checked, color: Color(0xFF00FF00), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Origem',
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                                Text(
                                  ride.pickupAddress,
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Destination
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.red, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Destino',
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                                Text(
                                  ride.destinationAddress,
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Fare
                      if (rideProvider.estimatedFare > 0) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Valor Estimado',
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                            Text(
                              'R\$ ${rideProvider.estimatedFare.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Color(0xFF00FF00),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Action buttons
                if (ride.status == 'requested' || ride.status == 'accepted') ...[
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: rideProvider.isLoading ? null : _cancelRide,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: rideProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          : const Text('Cancelar Corrida', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],

                // Show arrival/completion info
                if (ride.status == 'in_progress') ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FF00).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF00FF00)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.directions_car, color: Color(0xFF00FF00), size: 40),
                        const SizedBox(height: 8),
                        const Text(
                          'Viagem em Andamento',
                          style: TextStyle(
                            color: Color(0xFF00FF00),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Relaxe e aproveite a viagem!',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTripProgress(String status) {
    final steps = ['requested', 'accepted', 'in_progress', 'completed'];
    final currentStep = steps.indexOf(status);
    
    return Row(
      children: List.generate(steps.length, (index) {
        final isCompleted = index <= currentStep;
        final isLast = index == steps.length - 1;
        
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isCompleted ? const Color(0xFF00FF00) : const Color(0xFF333333),
                  shape: BoxShape.circle,
                ),
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.black, size: 14)
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isCompleted ? const Color(0xFF00FF00) : const Color(0xFF333333),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'requested':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'in_progress':
        return const Color(0xFF00FF00);
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'requested':
        return 'Procurando Motorista';
      case 'accepted':
        return 'Motorista a Caminho';
      case 'in_progress':
        return 'Em Viagem';
      case 'completed':
        return 'Viagem Concluída';
      case 'cancelled':
        return 'Cancelada';
      default:
        return 'Desconhecido';
    }
  }
}