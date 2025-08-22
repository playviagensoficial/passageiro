import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class BrazilianPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;
    
    if (newText.isEmpty) {
      return newValue;
    }
    
    // Remove todos os caracteres que não são dígitos
    final digitsOnly = newText.replaceAll(RegExp(r'[^\d]'), '');
    
    // Limita a 11 dígitos (DDD + 9 dígitos)
    final limitedDigits = digitsOnly.length > 11 ? digitsOnly.substring(0, 11) : digitsOnly;
    
    String formatted = '';
    
    if (limitedDigits.length >= 1) {
      formatted = '(${limitedDigits.substring(0, limitedDigits.length >= 2 ? 2 : limitedDigits.length)}';
      
      if (limitedDigits.length >= 3) {
        formatted += ') ';
        
        if (limitedDigits.length <= 10) {
          // Telefone fixo: (11) 1234-5678
          if (limitedDigits.length >= 7) {
            formatted += '${limitedDigits.substring(2, 6)}-${limitedDigits.substring(6)}';
          } else {
            formatted += limitedDigits.substring(2);
          }
        } else {
          // Celular: (11) 99999-9999
          if (limitedDigits.length >= 8) {
            formatted += '${limitedDigits.substring(2, 7)}-${limitedDigits.substring(7)}';
          } else {
            formatted += limitedDigits.substring(2);
          }
        }
      }
    } else {
      formatted = limitedDigits;
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  final String userType;
  
  const RegisterScreen({
    super.key,
    this.userType = 'passenger',
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _acceptTerms = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você deve aceitar os termos de uso'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    
    final result = await authProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      role: widget.userType,
    );

    if (mounted) {
      if (result == true) {
        // Registro completo sem 2FA
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cadastro realizado com sucesso!'),
            backgroundColor: Color(0xFF00CC00),
          ),
        );
        
        if (authProvider.currentToken != null) {
          Navigator.pushReplacementNamed(context, '/passenger-home');
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else if (result is Map && result['requiresWhatsApp2FA'] == true) {
        // Navegar para tela de verificação WhatsApp
        Navigator.pushNamed(
          context, 
          '/whatsapp-verification',
          arguments: {
            'phoneNumber': result['phone'],
            'tempToken': result['tempToken'],
          },
        );
      } else {
        // Erro no registro - mostrar mensagem amigável
        final errorMessage = authProvider.errorMessage ?? 'Erro no cadastro';
        
        // Melhorar mensagens de erro
        String friendlyMessage = errorMessage;
        if (errorMessage.contains('e-mail já está sendo usado')) {
          friendlyMessage = 'Este e-mail já possui uma conta. Tente fazer login ou use outro e-mail.';
        } else if (errorMessage.contains('telefone já está sendo usado')) {
          friendlyMessage = 'Este número de telefone já possui uma conta. Tente fazer login ou use outro número.';
        } else if (errorMessage.contains('duplicate key') || errorMessage.contains('já cadastrado')) {
          friendlyMessage = 'Já existe uma conta com essas informações. Tente fazer login.';
        }
        
        _showErrorDialog(friendlyMessage);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2D2D2D),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red[400], size: 28),
              const SizedBox(width: 8),
              const Text(
                'Erro no Cadastro',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF00FF00),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Entendi', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Header with back button
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const Expanded(
                        child: Text(
                          'Cadastro Passageiro',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48), // Balance the back button
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Logo
                  Container(
                    margin: const EdgeInsets.only(bottom: 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00FF00),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            size: 24,
                            color: Colors.white,
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
                                fontSize: 20,
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
                  ),

                  // Form
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Name Field
                          _buildTextField(
                            controller: _nameController,
                            label: 'Nome completo',
                            hint: 'Digite seu nome completo',
                            icon: Icons.person,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Nome é obrigatório';
                              }
                              if (value!.trim().split(' ').length < 2) {
                                return 'Digite nome e sobrenome';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Email Field
                          _buildTextField(
                            controller: _emailController,
                            label: 'E-mail',
                            hint: 'Digite seu e-mail',
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'E-mail é obrigatório';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                                return 'E-mail inválido';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Phone Field
                          _buildTextField(
                            controller: _phoneController,
                            label: 'Telefone (DDD + número)',
                            hint: '(11) 99999-9999',
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [BrazilianPhoneFormatter()],
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Telefone é obrigatório';
                              }
                              // Remove formatting
                              String phone = value!.replaceAll(RegExp(r'[^\d]'), '');
                              if (phone.length < 10 || phone.length > 11) {
                                return 'Digite um telefone válido (10 ou 11 dígitos)';
                              }
                              // Validar DDD brasileiro (11-99)
                              if (phone.length >= 2) {
                                int ddd = int.tryParse(phone.substring(0, 2)) ?? 0;
                                if (ddd < 11 || ddd > 99) {
                                  return 'DDD inválido (deve ser entre 11 e 99)';
                                }
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Password Field
                          _buildTextField(
                            controller: _passwordController,
                            label: 'Senha',
                            hint: 'Digite uma senha forte',
                            icon: Icons.lock,
                            obscureText: !_isPasswordVisible,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: Colors.grey[400],
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Senha é obrigatória';
                              }
                              if (value!.length < 6) {
                                return 'Senha deve ter pelo menos 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Confirm Password Field
                          _buildTextField(
                            controller: _confirmPasswordController,
                            label: 'Confirmar senha',
                            hint: 'Digite a senha novamente',
                            icon: Icons.lock_outline,
                            obscureText: !_isConfirmPasswordVisible,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: Colors.grey[400],
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Confirme sua senha';
                              }
                              if (value != _passwordController.text) {
                                return 'Senhas não conferem';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Terms checkbox
                          Row(
                            children: [
                              Checkbox(
                                value: _acceptTerms,
                                onChanged: (value) {
                                  setState(() {
                                    _acceptTerms = value ?? false;
                                  });
                                },
                                activeColor: const Color(0xFF00FF00),
                                checkColor: Colors.black,
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _acceptTerms = !_acceptTerms;
                                    });
                                  },
                                  child: const Text(
                                    'Aceito os termos de uso e política de privacidade',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Error Message
                          if (authProvider.errorMessage != null) ...[
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2D1B1B),
                                border: Border.all(color: Colors.red),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error, color: Colors.red, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      authProvider.errorMessage!,
                                      style: const TextStyle(color: Colors.red, fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          
                          // Register Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: authProvider.isLoading ? null : _handleRegister,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00FF00),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: authProvider.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                      ),
                                    )
                                  : const Text(
                                      'Criar Conta Passageiro',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Login link
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Já tem conta? Entre aqui',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          inputFormatters: inputFormatters,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(icon, color: Colors.grey[400]),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.grey[800],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF00CC00)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF00CC00)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF00CC00), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: validator,
        ),
      ],
    );
  }
}