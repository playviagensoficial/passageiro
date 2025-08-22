import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/ride.dart';
import '../../ride/providers/ride_provider.dart';

class RideStatusCard extends StatelessWidget {
  final Ride ride;

  const RideStatusCard({
    super.key,
    required this.ride,
  });

  String _getStatusText() {
    switch (ride.status) {
      case 'pending':
        return 'Procurando motorista...';
      case 'accepted':
        return 'Motorista a caminho';
      case 'in_progress':
        return 'Em viagem';
      case 'completed':
        return 'Viagem concluída';
      case 'cancelled':
        return 'Viagem cancelada';
      default:
        return 'Status desconhecido';
    }
  }

  Color _getStatusColor() {
    switch (ride.status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return const Color(0xFF00CC00);
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return const Color(0xFF00CC00);
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (ride.status) {
      case 'pending':
        return Icons.search;
      case 'accepted':
        return Icons.directions_car;
      case 'in_progress':
        return Icons.navigation;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getStatusColor(), width: 2),
      ),
      child: Column(
        children: [
          // Status Header
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getStatusColor(),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  _getStatusIcon(),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStatusText(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (ride.status == 'pending') ...[
                      const SizedBox(height: 4),
                      Text(
                        'Tempo de espera: ~3 min',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (ride.status == 'pending' || ride.status == 'accepted')
                TextButton(
                  onPressed: () => _showCancelConfirmation(context),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: Colors.grey),
          const SizedBox(height: 16),

          // Route Info
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.radio_button_checked, 
                               color: Color(0xFF00CC00), size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ride.pickupAddress,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ride.destinationAddress,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (ride.fare != null) ...[
                const SizedBox(width: 16),
                Column(
                  children: [
                    const Text(
                      'Tarifa',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      'R\$ ${ride.fare!.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFF00CC00),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),

          // Driver Info (when accepted) - Official Play Viagens wireframe
          if (ride.status == 'accepted' || ride.status == 'in_progress') ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.grey),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
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
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00CC00),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 14,
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
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                height: 0.9,
                              ),
                            ),
                            Text(
                              'Viagens',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
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
                            fontSize: 12,
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
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00CC00).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.directions_car,
                                  color: Color(0xFF00CC00),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Honda Civic',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      'ABC-1234',
                                      style: TextStyle(
                                        fontSize: 12,
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
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 16),
                              SizedBox(width: 4),
                              Text(
                                '4.9',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(width: 4),
                              Text(
                                '(125 viagens)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // TODO: Call driver
                                },
                                icon: const Icon(Icons.phone, size: 14),
                                label: const Text(
                                  'Ligar',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // TODO: Chat with driver
                                },
                                icon: const Icon(Icons.chat, size: 14),
                                label: const Text(
                                  'Chat',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00CC00),
                                  foregroundColor: Colors.black,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
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
          ],

          // Progress indicators
          if (ride.status == 'pending') ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(
              color: Color(0xFF00CC00),
              backgroundColor: Colors.grey,
            ),
          ],
        ],
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Cancelar corrida?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Tem certeza que deseja cancelar esta corrida?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Não', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final rideProvider = context.read<RideProvider>();
              await rideProvider.cancelRide();
            },
            child: const Text('Sim, cancelar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}