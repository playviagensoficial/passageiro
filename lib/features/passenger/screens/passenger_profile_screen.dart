import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/play_logo.dart';
import '../../../shared/theme/app_theme.dart';

class PassengerProfileScreen extends StatefulWidget {
  const PassengerProfileScreen({super.key});

  @override
  State<PassengerProfileScreen> createState() => _PassengerProfileScreenState();
}

class _PassengerProfileScreenState extends State<PassengerProfileScreen> {
  bool _editMode = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current user data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;
      
      if (user != null) {
        _nameController.text = user.name ?? '';
        _emailController.text = user.email ?? '';
        _phoneController.text = user.phone ?? '';
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _editMode = !_editMode;
    });
  }

  Future<void> _saveProfile() async {
    // Simulate saving profile
    setState(() {
      _editMode = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Perfil atualizado com sucesso!'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
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
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _editMode ? Icons.save : Icons.edit,
              color: AppTheme.primaryColor,
              size: 28,
            ),
            onPressed: _editMode ? _saveProfile : _toggleEditMode,
          ),
          if (_editMode)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red, size: 28),
              onPressed: () {
                setState(() {
                  _editMode = false;
                });
              },
            ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // Profile Avatar - Conforme wireframe
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.grey[300],
                      child: Text(
                        user?.name?.substring(0, 1).toUpperCase() ?? 'P',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (_editMode)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            // Implementar seleção de foto
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('📷 Seleção de foto em desenvolvimento'),
                                backgroundColor: AppTheme.primaryColor,
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Nome do Passageiro - Editável
                _editMode
                    ? Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          controller: _nameController,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Nome completo',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: AppTheme.primaryColor),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                            ),
                          ),
                        ),
                      )
                    : Text(
                        user?.name ?? 'Nome do passageiro',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                
                const SizedBox(height: 16),
                
                // Rating - Conforme wireframe
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 28),
                    const SizedBox(width: 8),
                    const Text(
                      '4,5',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Campos de informação editáveis
                _editMode
                    ? _buildEditableField('E-mail:', _emailController, Icons.email)
                    : _buildInfoField('E-mail:', user?.email ?? 'moadaplay@gmail.com'),
                
                const SizedBox(height: 16),
                
                _editMode
                    ? _buildEditableField('Telefone:', _phoneController, Icons.phone)
                    : _buildInfoField('Telefone:', user?.phone ?? '(49) 98808 - 1329'),
                
                const SizedBox(height: 16),
                
                _buildInfoField(
                  'Código de Indicação:',
                  'AKTYU',
                ),
                
                const SizedBox(height: 40),
                
                // Botão Documentos - Conforme wireframe
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/passenger-documents');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_outlined, color: Colors.black),
                        SizedBox(width: 8),
                        Text(
                          'Documentos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Botão Excluir Conta - Conforme wireframe
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.grey[900],
                          title: const Text('Excluir Conta', style: TextStyle(color: Colors.white)),
                          content: const Text(
                            'Deseja realmente excluir sua conta? Esta ação não pode ser desfeita.',
                            style: TextStyle(color: Colors.white),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      
                      if (confirmed == true) {
                        // Implementar lógica de exclusão de conta
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Funcionalidade de exclusão em desenvolvimento'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
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
                
                const SizedBox(height: 40),
                
                // Suporte para o Passageiro - Clicável
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/passenger-support');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.primaryColor, width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.support_agent, color: AppTheme.primaryColor),
                        SizedBox(width: 8),
                        Text(
                          'Suporte para o Passageiro',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // Campo de informação conforme wireframe
  Widget _buildInfoField(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.white, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label  $value',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  // Campo editável de informação
  Widget _buildEditableField(String label, TextEditingController controller, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: AppTheme.primaryColor, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 24),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Digite ${label.toLowerCase()}',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}