import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../screens/register_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/whatsapp_verification_screen.dart';
import '../screens/privacy_policy_screen.dart';
import '../../../shared/widgets/play_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    
    final result = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) {
      if (result == true) {
        // Login direto bem-sucedido
        Navigator.pushReplacementNamed(context, '/passenger-home');
      } else if (result is Map && result['requiresWhatsApp2FA'] == true) {
        // Navegar para tela de verificação WhatsApp
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WhatsAppVerificationScreen(
              phoneNumber: result['phone'],
              tempToken: result['tempToken'],
            ),
          ),
        );
      }
      // Se result == false, o erro já foi definido no AuthProvider
    }
  }

  void _navigateToRegister(String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterScreen(userType: type == 'passenger' ? 'passenger' : 'driver'),
      ),
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
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 120),
                    
                    // Logo Play Viagens - Conforme wireframe
                    const PlayLogoHorizontal(height: 120),
                    
                    const SizedBox(height: 80),
                    
                    // Campo E-mail - Conforme wireframe
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'E-mail:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF00FF00), width: 2),
                          ),
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                            decoration: const InputDecoration(
                              hintText: 'Digite Seu E-mail',
                              hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                            ),
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
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Campo Senha - Conforme wireframe
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Senha:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF00FF00), width: 2),
                          ),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                            decoration: const InputDecoration(
                              hintText: 'Digite Sua Senha',
                              hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Botão Entrar Principal - Conforme wireframe "Tela de Login-1"
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00FF00),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: authProvider.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Entrar',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Botão Cadastre-se - Conforme wireframe "Tela de Login-1"
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () => _navigateToRegister('passenger'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00FF00),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Cadastre-se',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Esqueceu senha - Conforme wireframe
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Esqueceu minha senha',
                          style: TextStyle(
                            color: Color(0xFF00FF00),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Política de Privacidade - Conforme wireframe
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PrivacyPolicyScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Política de Privacidade',
                          style: TextStyle(
                            color: Color(0xFF00FF00),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}