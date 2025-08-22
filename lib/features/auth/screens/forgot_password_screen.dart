import 'package:flutter/material.dart';
import '../../../shared/widgets/play_logo.dart';
import '../../../shared/theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleForgotPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Simular envio de e-mail de recuperação
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('E-mail de recuperação enviado com sucesso!'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
      Navigator.pop(context);
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // Logo Play Viagens
                const PlayLogoHorizontal(height: 100),
                
                const SizedBox(height: 60),
                
                // Título
                const Text(
                  'Esqueceu sua senha?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                // Subtítulo
                const Text(
                  'Digite seu e-mail abaixo e enviaremos um link para redefinir sua senha.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                
                // Campo E-mail
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
                
                const SizedBox(height: 40),
                
                // Botão Enviar
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleForgotPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00FF00),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Enviar E-mail',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Voltar para login
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Voltar para o Login',
                    style: TextStyle(
                      color: Color(0xFF00FF00),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}