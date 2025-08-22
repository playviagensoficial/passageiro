import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../ride/providers/ride_provider.dart';
import '../../../core/models/ride.dart';
import '../../../core/widgets/app_bottom_navigation.dart';

class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  String _selectedFilter = 'todas';
  final List<String> _filters = ['todas', 'concluidas', 'canceladas'];
  
  @override
  void initState() {
    super.initState();
    // Load ride history when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RideProvider>().loadRideHistory();
    });
  }
  
  // Demo data for fallback
  final List<Map<String, dynamic>> _demoRides = [
    {
      'id': '1',
      'from': 'Rua das Flores, 123',
      'to': 'Aeroporto Internacional',
      'date': DateTime(2024, 1, 15, 14, 30),
      'fare': 25.50,
      'status': 'concluida',
      'driver': 'João Silva',
      'vehicle': 'Honda Civic Prata',
      'distance': '12.5 km',
      'duration': '28 min',
      'paymentMethod': 'carteira'
    },
    {
      'id': '2',
      'from': 'Shopping Center Norte',
      'to': 'Rua Augusta, 456',
      'date': DateTime(2024, 1, 14, 10, 15),
      'fare': 18.25,
      'status': 'concluida',
      'driver': 'Maria Santos',
      'vehicle': 'Toyota Corolla Branco',
      'distance': '8.2 km',
      'duration': '22 min',
      'paymentMethod': 'pix'
    },
    {
      'id': '3',
      'from': 'Centro da Cidade',
      'to': 'Bairro Jardins',
      'date': DateTime(2024, 1, 13, 16, 45),
      'fare': 22.00,
      'status': 'cancelada',
      'driver': null,
      'vehicle': null,
      'distance': null,
      'duration': null,
      'paymentMethod': null,
      'cancelReason': 'Cancelado pelo passageiro'
    },
    {
      'id': '4',
      'from': 'Universidade Federal',
      'to': 'Terminal Rodoviário',
      'date': DateTime(2024, 1, 12, 8, 20),
      'fare': 32.75,
      'status': 'concluida',
      'driver': 'Carlos Pereira',
      'vehicle': 'Nissan Sentra Azul',
      'distance': '15.8 km',
      'duration': '35 min',
      'paymentMethod': 'cartao'
    },
    {
      'id': '5',
      'from': 'Estação de Metrô',
      'to': 'Hospital Central',
      'date': DateTime(2024, 1, 11, 19, 10),
      'fare': 16.40,
      'status': 'concluida',
      'driver': 'Ana Costa',
      'vehicle': 'Hyundai HB20 Vermelho',
      'distance': '7.1 km',
      'duration': '18 min',
      'paymentMethod': 'carteira'
    },
  ];

  List<Ride> get _filteredRides {
    final rideProvider = context.watch<RideProvider>();
    List<Ride> allRides = rideProvider.rideHistory;
    
    // Use demo data if no real rides available
    if (allRides.isEmpty) {
      // Convert demo data to Ride objects for consistency
      allRides = _demoRides.map((rideData) => _demoRideToRide(rideData)).toList();
    }
    
    if (_selectedFilter == 'todas') return allRides;
    if (_selectedFilter == 'concluidas') {
      return allRides.where((ride) => ride.status == 'completed').toList();
    }
    if (_selectedFilter == 'canceladas') {
      return allRides.where((ride) => ride.status == 'cancelled').toList();
    }
    return allRides;
  }
  
  Ride _demoRideToRide(Map<String, dynamic> data) {
    return Ride(
      id: int.parse(data['id']),
      passengerId: 1, // Demo passenger ID
      driverId: data['status'] == 'concluida' ? 1 : null,
      pickupAddress: data['from'],
      destinationAddress: data['to'],
      pickupLatitude: 0.0, // Demo coordinates
      pickupLongitude: 0.0,
      destinationLatitude: 0.0,
      destinationLongitude: 0.0,
      status: data['status'] == 'concluida' ? 'completed' : 'cancelled',
      fare: data['fare'],
      paymentMethod: data['paymentMethod'],
      vehicleCategory: 'Economy',
      createdAt: data['date'],
      acceptedAt: data['status'] == 'concluida' ? data['date'] : null,
      startedAt: data['status'] == 'concluida' ? data['date'] : null,
      completedAt: data['status'] == 'concluida' ? data['date'] : null,
      cancelledAt: data['status'] == 'cancelada' ? data['date'] : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RideProvider>(
      builder: (context, rideProvider, child) {
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
          'Histórico de Corridas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            height: 50,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF00CC00) : Colors.transparent,
                        borderRadius: BorderRadius.circular(21),
                      ),
                      child: Center(
                        child: Text(
                          _getFilterLabel(filter),
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white54,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Rides List
          Expanded(
            child: rideProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00FF00)),
                    ),
                  )
                : _filteredRides.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () => rideProvider.loadRideHistory(),
                        color: const Color(0xFF00FF00),
                        backgroundColor: Colors.black,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredRides.length,
                          itemBuilder: (context, index) {
                            final ride = _filteredRides[index];
                            return _buildRideItem(ride);
                          },
                        ),
                      ),
          ),
        ],
      ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma corrida encontrada',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Suas corridas ${_selectedFilter != 'todas' ? _getFilterLabel(_selectedFilter).toLowerCase() : ''} aparecerão aqui',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRideItem(Ride ride) {
    final isCompleted = ride.status == 'completed';
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');
    final rideDate = ride.createdAt;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showRideDetails(ride),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with date and status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${dateFormat.format(rideDate)} • ${timeFormat.format(rideDate)}',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCompleted ? Colors.green[900] : Colors.red[900],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isCompleted ? 'Concluída' : 'Cancelada',
                        style: TextStyle(
                          color: isCompleted ? Colors.green : Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Route information
                Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00CC00),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 2,
                          height: 20,
                          color: Colors.grey[700],
                        ),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isCompleted ? Colors.red : Colors.grey[600],
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ride.pickupAddress,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            ride.destinationAddress,
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

                const SizedBox(height: 12),

                // Price and additional info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (isCompleted) ...[
                      Text(
                        'R\$ ${ride.fare?.toStringAsFixed(2) ?? '0,00'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getDemoRideData(ride.id, 'distance') ?? '',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ] else ...[
                      Text(
                        'Cancelada',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRideDetails(Ride ride) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
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
                    'Detalhes da Corrida',
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
                    // Date and Status
                    _buildDetailItem(
                      'Data e Hora',
                      DateFormat('dd/MM/yyyy • HH:mm').format(ride.createdAt),
                    ),

                    _buildDetailItem(
                      'Status',
                      ride.status == 'completed' ? 'Concluída' : 'Cancelada',
                    ),

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
                                ride.pickupAddress,
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
                                ride.destinationAddress,
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

                    if (ride.status == 'completed') ...[
                      const SizedBox(height: 32),

                      // Trip info
                      _buildDetailItem('Motorista', 'Motorista ${ride.driverId ?? 'N/A'}'),
                      _buildDetailItem('Veículo', 'Veículo ${ride.driverId ?? 'N/A'}'),
                      _buildDetailItem('Distância', _getDemoRideData(ride.id, 'distance') ?? 'N/A'),
                      _buildDetailItem('Duração', _getDemoRideData(ride.id, 'duration') ?? 'N/A'),
                      _buildDetailItem('Forma de Pagamento', _getPaymentMethodLabel(ride.paymentMethod)),

                      const SizedBox(height: 20),

                      // Price breakdown
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Resumo do Pagamento',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Valor da Corrida',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                Text(
                                  'R\$ ${ride.fare?.toStringAsFixed(2) ?? '0,00'}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 20),
                      _buildDetailItem('Motivo', 'Não informado'),
                    ],

                    const SizedBox(height: 32),

                    // Action buttons
                    if (ride.status == 'completed') ...[
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            // TODO: Implement repeat ride
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF00CC00)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Repetir esta corrida',
                            style: TextStyle(
                              color: Color(0xFF00CC00),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
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

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'todas':
        return 'Todas';
      case 'concluidas':
        return 'Concluídas';
      case 'canceladas':
        return 'Canceladas';
      default:
        return filter;
    }
  }

  String _getPaymentMethodLabel(String? method) {
    switch (method) {
      case 'carteira':
        return 'Carteira Digital';
      case 'pix':
        return 'PIX';
      case 'cartao':
        return 'Cartão de Crédito';
      default:
        return 'N/A';
    }
  }

  String? _getDemoRideData(int rideId, String field) {
    final demoRide = _demoRides.firstWhere(
      (ride) => ride['id'] == rideId.toString(),
      orElse: () => <String, dynamic>{},
    );
    return demoRide[field]?.toString();
  }
}