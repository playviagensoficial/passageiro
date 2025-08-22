import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/bottom_navigation.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  void _onBottomNavTap(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/passenger-home');
        break;
      case 1:
        Navigator.pushNamed(context, '/activity');
        break;
      case 2:
        // Already on account
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Conta',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF00CC00),
                  child: Text(
                    user?.name.isNotEmpty == true
                        ? user!.name[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Menu items
          _buildMenuItem(
            icon: Icons.edit,
            title: 'Editar perfil',
            onTap: () => Navigator.pushNamed(context, '/edit-profile'),
          ),
          _buildMenuItem(
            icon: Icons.history,
            title: 'Histórico de viagens',
            onTap: () => Navigator.pushNamed(context, '/ride-history'),
          ),
          _buildMenuItem(
            icon: Icons.schedule,
            title: 'Viagens agendadas',
            onTap: () => Navigator.pushNamed(context, '/scheduled-rides'),
          ),
          _buildMenuItem(
            icon: Icons.account_balance_wallet,
            title: 'Carteira',
            onTap: () => Navigator.pushNamed(context, '/wallet'),
          ),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'Ajuda',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.settings,
            title: 'Configurações',
            onTap: () {},
          ),

          const SizedBox(height: 24),

          // Logout
          _buildMenuItem(
            icon: Icons.logout,
            title: 'Sair',
            textColor: Colors.red,
            onTap: () async {
              await authProvider.logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: UberBottomNavigation(
        currentIndex: 2,
        onTap: _onBottomNavTap,
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: textColor ?? Colors.grey[600]),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: textColor ?? Colors.black87,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        tileColor: Colors.grey[50],
      ),
    );
  }
}