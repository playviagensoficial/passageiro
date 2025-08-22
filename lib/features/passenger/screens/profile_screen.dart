import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import 'privacy_policy_screen.dart';
import '../../wallet/providers/wallet_provider.dart';
import '../../../core/widgets/app_bottom_navigation.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _referralCodeController = TextEditingController();
  bool _isEditing = false;
  
  @override
  void initState() {
    super.initState();
    // Load wallet balance for display
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>().refreshBalance();
      _loadUserData();
    });
  }
  
  void _loadUserData() {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _emailController.text = user.email ?? '';
      _phoneController.text = user.phone ?? '';
      _referralCodeController.text = 'AKTYU'; // Static referral code from wireframe
    }
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF00FF00),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.play_arrow, color: Colors.black, size: 20),
            ),
            const SizedBox(width: 8),
            const Text(
              'play',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Viagens',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: const [
          SizedBox(width: 48), // Balance the menu icon
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // Profile Picture
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD1D1D1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.grey,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // User Name
                Text(
                  user?.name ?? 'Nome do passageiro',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Rating
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      '4,5',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Email Field
                _buildProfileField('E-mail:', _emailController),
                
                const SizedBox(height: 16),
                
                // Phone Field
                _buildProfileField('Telefone:', _phoneController),
                
                const SizedBox(height: 16),
                
                // Referral Code Field
                _buildProfileField('Código de Indicação:', _referralCodeController),
                
                const SizedBox(height: 40),
                
                // Documents Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _navigateToDocuments(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00FF00),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Documentos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Delete Account Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _showDeleteAccountDialog(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Excluir Conta',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Privacy Policy Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacyPolicyScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.policy, color: Colors.white),
                    label: const Text(
                      'Política de Privacidade',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Support Section
                const Text(
                  'Suporte para o Passageiro',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileField(String label, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF00FF00).withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 140,
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            Expanded(
              child: TextFormField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                enabled: _isEditing,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (_isEditing)
              IconButton(
                icon: const Icon(Icons.save, color: Color(0xFF00FF00)),
                onPressed: () => _saveUserData(),
              )
            else
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.grey),
                onPressed: () => setState(() => _isEditing = true),
              ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _saveUserData() async {
    try {
      final authProvider = context.read<AuthProvider>();
      // Here you would typically call an API to update user data
      // For now, we'll just show a success message
      
      setState(() {
        _isEditing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dados atualizados com sucesso!'),
          backgroundColor: Color(0xFF00FF00),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar dados: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToDocuments() async {
    final result = await Navigator.pushNamed(context, '/documents');
    
    // Check if documents were successfully uploaded and validated
    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Documentos enviados e validados com sucesso!'),
          backgroundColor: Color(0xFF00FF00),
        ),
      );
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Excluir Conta', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Tem certeza que deseja excluir sua conta permanentemente? Esta ação não pode ser desfeita.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => _deleteAccount(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    Navigator.pop(context); // Close dialog
    
    try {
      // Here you would call your API to delete the account
      // For now, we'll just log out the user
      await context.read<AuthProvider>().logout();
      
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta excluída com sucesso'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir conta: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

}