import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduledRidesScreen extends StatefulWidget {
  const ScheduledRidesScreen({super.key});

  @override
  State<ScheduledRidesScreen> createState() => _ScheduledRidesScreenState();
}

class _ScheduledRidesScreenState extends State<ScheduledRidesScreen> {
  // Demo data - replace with actual API data
  final List<Map<String, dynamic>> _scheduledRides = [
    {
      'id': '1',
      'from': 'Casa - Rua das Flores, 123',
      'to': 'Aeroporto Internacional',
      'scheduledDate': DateTime(2024, 1, 20, 6, 0),
      'estimatedFare': 28.50,
      'category': 'Economy',
      'status': 'agendada',
      'recurring': false,
    },
    {
      'id': '2',
      'from': 'Hotel Central Plaza',
      'to': 'Centro de Convenções',
      'scheduledDate': DateTime(2024, 1, 22, 8, 30),
      'estimatedFare': 15.75,
      'category': 'Comfort',
      'status': 'agendada',
      'recurring': false,
    },
    {
      'id': '3',
      'from': 'Escritório - Av. Paulista',
      'to': 'Casa - Rua das Flores, 123',
      'scheduledDate': DateTime(2024, 1, 18, 18, 0),
      'estimatedFare': 22.00,
      'category': 'Economy',
      'status': 'agendada',
      'recurring': true,
      'recurringDays': ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta'],
    },
  ];

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
          'Viagens Agendadas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF00CC00)),
            onPressed: _scheduleNewRide,
          ),
        ],
      ),
      body: _scheduledRides.isEmpty ? _buildEmptyState() : _buildRidesList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.schedule,
            size: 80,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma viagem agendada',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Suas viagens futuras aparecerão aqui',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _scheduleNewRide,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00CC00),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Agendar Viagem',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRidesList() {
    // Sort rides by date
    final sortedRides = List<Map<String, dynamic>>.from(_scheduledRides);
    sortedRides.sort((a, b) => (a['scheduledDate'] as DateTime)
        .compareTo(b['scheduledDate'] as DateTime));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedRides.length,
      itemBuilder: (context, index) {
        final ride = sortedRides[index];
        return _buildRideItem(ride);
      },
    );
  }

  Widget _buildRideItem(Map<String, dynamic> ride) {
    final scheduledDate = ride['scheduledDate'] as DateTime;
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');
    final isRecurring = ride['recurring'] ?? false;
    final isUpcoming = scheduledDate.isAfter(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showRideDetails(ride),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with date and time
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isUpcoming ? const Color(0xFF00CC00).withOpacity(0.2) : Colors.grey[800],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isUpcoming ? const Color(0xFF00CC00) : Colors.grey[600]!,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: isUpcoming ? const Color(0xFF00CC00) : Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${dateFormat.format(scheduledDate)} • ${timeFormat.format(scheduledDate)}',
                            style: TextStyle(
                              color: isUpcoming ? const Color(0xFF00CC00) : Colors.grey[400],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (isRecurring) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue[900],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.repeat,
                              size: 12,
                              color: Colors.blue[300],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Recorrente',
                              style: TextStyle(
                                color: Colors.blue[300],
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: Colors.grey[400]),
                      color: Colors.grey[800],
                      onSelected: (value) => _handleMenuAction(value, ride),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.white70, size: 20),
                              SizedBox(width: 12),
                              Text('Editar', style: TextStyle(color: Colors.white70)),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'cancel',
                          child: Row(
                            children: [
                              Icon(Icons.cancel, color: Colors.red, size: 20),
                              SizedBox(width: 12),
                              Text('Cancelar', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Route information
                Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00CC00),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 2,
                          height: 32,
                          color: Colors.grey[700],
                        ),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ride['from'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            ride['to'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Footer with category and price
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ride['category'],
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'R\$ ${ride['estimatedFare'].toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                // Recurring info
                if (isRecurring) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 4,
                    children: (ride['recurringDays'] as List<String>)
                        .map((day) => Chip(
                              label: Text(
                                day.substring(0, 3),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white70,
                                ),
                              ),
                              backgroundColor: Colors.grey[800],
                              side: BorderSide.none,
                              padding: const EdgeInsets.all(0),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRideDetails(Map<String, dynamic> ride) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text(
                    'Detalhes da Viagem',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.grey),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Scheduled date
                    _buildDetailRow(
                      'Data e Hora',
                      DateFormat('dd/MM/yyyy • HH:mm').format(ride['scheduledDate']),
                    ),

                    _buildDetailRow('Categoria', ride['category']),
                    _buildDetailRow('Valor Estimado', 'R\$ ${ride['estimatedFare'].toStringAsFixed(2)}'),

                    const SizedBox(height: 20),

                    // Route
                    const Text(
                      'Trajeto',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Color(0xFF00CC00),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Container(
                              width: 2,
                              height: 40,
                              color: Colors.grey[700],
                            ),
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Origem',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                ride['from'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Destino',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                ride['to'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    if (ride['recurring'] == true) ...[
                      const SizedBox(height: 20),
                      _buildDetailRow(
                        'Recorrência',
                        (ride['recurringDays'] as List<String>).join(', '),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _editRide(ride);
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF00CC00)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              'Editar',
                              style: TextStyle(
                                color: Color(0xFF00CC00),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _cancelRide(ride);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
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
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ),
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
      ),
    );
  }

  void _handleMenuAction(String action, Map<String, dynamic> ride) {
    switch (action) {
      case 'edit':
        _editRide(ride);
        break;
      case 'cancel':
        _cancelRide(ride);
        break;
    }
  }

  void _editRide(Map<String, dynamic> ride) {
    // TODO: Implement edit ride functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de editar viagem em desenvolvimento'),
        backgroundColor: Color(0xFF00CC00),
      ),
    );
  }

  void _cancelRide(Map<String, dynamic> ride) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Cancelar Viagem',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Tem certeza que deseja cancelar esta viagem agendada?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Não',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _scheduledRides.removeWhere((r) => r['id'] == ride['id']);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Viagem cancelada com sucesso'),
                  backgroundColor: Color(0xFF00CC00),
                ),
              );
            },
            child: const Text(
              'Sim, Cancelar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _scheduleNewRide() {
    // TODO: Navigate to schedule ride screen or show modal
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de agendar nova viagem em desenvolvimento'),
        backgroundColor: Color(0xFF00CC00),
      ),
    );
  }
}