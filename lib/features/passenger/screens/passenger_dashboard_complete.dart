import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../maps/widgets/google_map_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../whatsapp/screens/whatsapp_history_screen.dart';
import '../../whatsapp/providers/whatsapp_provider.dart';
import 'uber_style_home.dart';

class PassengerDashboardComplete extends StatefulWidget {
  const PassengerDashboardComplete({super.key});

  @override
  State<PassengerDashboardComplete> createState() => _PassengerDashboardCompleteState();
}

class _PassengerDashboardCompleteState extends State<PassengerDashboardComplete>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  double walletBalance = 150.75;
  
  final List<Map<String, dynamic>> recentRides = [
    {
      'id': '1',
      'destination': 'Aeroporto Internacional',
      'date': '15/01/2024',
      'time': '14:30',
      'fare': 25.50,
      'status': 'completed'
    },
    {
      'id': '2',
      'destination': 'Shopping Center',
      'date': '14/01/2024',
      'time': '10:15',
      'fare': 18.25,
      'status': 'completed'
    },
    {
      'id': '3',
      'destination': 'Centro da Cidade',
      'date': '13/01/2024',
      'time': '16:45',
      'fare': 22.00,
      'status': 'cancelled'
    }
  ];

  final List<Map<String, dynamic>> transactions = [
    {
      'id': '1',
      'type': 'withdrawn',
      'amount': 25.50,
      'description': 'Corrida - Centro para Aeroporto',
      'date': '2024-01-15'
    },
    {
      'id': '2',
      'type': 'withdrawn',
      'amount': 18.25,
      'description': 'Corrida - Shopping para Casa',
      'date': '2024-01-14'
    },
    {
      'id': '3',
      'type': 'received',
      'amount': 100.00,
      'description': 'Recarga via PIX',
      'date': '2024-01-13'
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 0); // Start with Corridas tab (Uber style ride request)
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Column(
        children: [
          // Play Header
          _buildPlayHeader(context),
          
          // Tab Bar
          Container(
            color: Colors.grey[800],
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF00CC00),
              indicatorWeight: 3,
              tabs: const [
                Tab(
                  icon: Icon(Icons.directions_car, size: 20),
                  text: 'Corridas',
                ),
                Tab(
                  icon: Icon(Icons.credit_card, size: 20),
                  text: 'Carteira',
                ),
                Tab(
                  icon: Icon(Icons.message, size: 20),
                  text: 'WhatsApp',
                ),
                Tab(
                  icon: Icon(Icons.person, size: 20),
                  text: 'Perfil',
                ),
              ],
              labelColor: const Color(0xFF00CC00),
              unselectedLabelColor: Colors.grey[300],
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Container(
                  color: Colors.white,
                  child: _buildCorridasTab(),
                ),
                _buildCarteiraTab(),
                _buildWhatsAppTab(),
                _buildPerfilTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayHeader(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    
    return Container(
      color: const Color(0xFF1A1A1A),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      child: Row(
        children: [
          // Logo
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF00CC00),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 8),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'play',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Viagens',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          
          // User Info and Wallet
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    user?.name ?? 'Passageiro',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _tabController.animateTo(2), // Go to wallet tab
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00CC00),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'R\$ ${walletBalance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {
                  _showLogoutDialog(context);
                },
                icon: const Icon(
                  Icons.logout,
                  color: Colors.grey,
                  size: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInicioTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Wallet Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00CC00), Color(0xFF00AA00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saldo disponível',
                          style: const TextStyle(
                            color: Color(0xCC000000),
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                      ],
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.credit_card,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                Text(
                  'R\$ ${walletBalance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _tabController.animateTo(2),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Adicionar Saldo',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Quick Action - Request Ride
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton.icon(
              onPressed: () => _tabController.animateTo(1),
              icon: const Icon(Icons.directions_car, size: 24),
              label: const Text(
                'Solicitar Corrida',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00CC00),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Quick Actions Grid
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.calendar_today,
                  label: 'Agendar',
                  onTap: () => _tabController.animateTo(1),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.history,
                  label: 'Histórico',
                  onTap: () => _showHistoryModal(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Recent Rides
          if (recentRides.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Corridas Recentes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...recentRides.take(3).map((ride) => _buildRecentRideItem(ride)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCorridasTab() {
    return const UberStyleHome();
  }

  Widget _buildCarteiraTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Wallet Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00CC00), Color(0xFF00AA00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saldo disponível',
                          style: const TextStyle(
                            color: Color(0xCC000000),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.credit_card,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                Text(
                  'R\$ ${walletBalance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/wallet-recharge');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Recarregar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showWithdrawModal(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.black),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Sacar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Transactions
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Transações Recentes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                ...transactions.map((transaction) => _buildTransactionItem(transaction)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerfilTab() {
    final user = context.watch<AuthProvider>().currentUser;
    final authProvider = context.read<AuthProvider>();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Profile Info
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00CC00),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.black,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Usuário',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xCC000000),
                            ),
                          ),
                          Text(
                            user?.email ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Profile Options
                _buildProfileOption(
                  icon: Icons.person,
                  title: 'Editar Perfil',
                  onTap: () => _showEditProfileModal(),
                ),
                _buildProfileOption(
                  icon: Icons.history,
                  title: 'Histórico Completo',
                  onTap: () => _showHistoryModal(),
                ),
                _buildProfileOption(
                  icon: Icons.calendar_today,
                  title: 'Viagens Agendadas',
                  onTap: () => _showScheduledRidesModal(),
                ),
                _buildProfileOption(
                  icon: Icons.logout,
                  title: 'Sair',
                  onTap: () => _showLogoutDialog(context),
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: Colors.black),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentRideItem(Map<String, dynamic> ride) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF00CC00),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.location_on,
              color: Colors.black,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ride['destination'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '${ride['date']} - ${ride['time']}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'R\$ ${ride['fare'].toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: ride['status'] == 'completed' 
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  ride['status'] == 'completed' ? 'Concluída' : 'Cancelada',
                  style: TextStyle(
                    fontSize: 10,
                    color: ride['status'] == 'completed' ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final isReceived = transaction['type'] == 'received';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isReceived ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.credit_card,
              color: isReceived ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['description'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  transaction['date'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isReceived ? '+' : '-'}R\$ ${transaction['amount'].toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isReceived ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          side: BorderSide(color: isDestructive ? Colors.red : Colors.grey[300]!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : Colors.black,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isDestructive ? Colors.red : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sair'),
          content: const Text('Tem certeza que deseja sair?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthProvider>().logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Sair', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showAddFundsModal() {
    Navigator.pushNamed(context, '/add-funds');
  }

  void _showWithdrawModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sacar Saldo'),
          content: const Text('Funcionalidade em desenvolvimento'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showHistoryModal() {
    Navigator.pushNamed(context, '/ride-history');
  }

  void _showScheduledRidesModal() {
    Navigator.pushNamed(context, '/scheduled-rides');
  }

  void _showEditProfileModal() {
    Navigator.pushNamed(context, '/edit-profile');
  }

  Widget _buildRecentRideCard(Map<String, dynamic> ride) {
    final status = ride['status'] as String;
    Color statusColor;
    String statusText;
    
    switch (status) {
      case 'completed':
        statusColor = const Color(0xFF00CC00);
        statusText = 'Concluída';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusText = 'Cancelada';
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'Em andamento';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF00CC00).withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.directions_car,
              color: Color(0xFF00CC00),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ride['destination'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${ride['date']} • ${ride['time']}',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'R\$ ${(ride['fare'] as double).toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[600],
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsAppTab() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        
        return Container(
          color: const Color(0xFF1A1A1A),
          child: WhatsAppHistoryScreen(
            userId: user?.id,
            userType: 'passenger',
            showHeader: false,
          ),
        );
      },
    );
  }
}