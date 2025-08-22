import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class WhatsAppVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String tempToken;

  const WhatsAppVerificationScreen({
    Key? key,
    required this.phoneNumber,
    required this.tempToken,
  }) : super(key: key);

  @override
  State<WhatsAppVerificationScreen> createState() => _WhatsAppVerificationScreenState();
}

class _WhatsAppVerificationScreenState extends State<WhatsAppVerificationScreen> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  int _timeLeft = 30; // 30 segundos
  bool _canResend = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _sendInitialCode();
  }

  void _sendInitialCode() async {
    // Enviar código automaticamente quando a tela carregar
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.sendWhatsAppCode(
      phone: widget.phoneNumber,
      tempToken: widget.tempToken,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length >= 11) {
      return '(${cleaned.substring(0, 2)}) ${cleaned.substring(2, 7)}-${cleaned.substring(7, 11)}';
    }
    return phone;
  }

  Future<void> _verifyCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      await authProvider.verifyWhatsAppCode(
        phoneNumber: widget.phoneNumber,
        code: _codeController.text.trim(),
        tempToken: widget.tempToken,
      );

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/passenger-home',
          (route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Autenticação concluída! Bem-vindo ao Play Viagens!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendCode() async {
    if (!_canResend) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      await authProvider.resendWhatsAppCode(
        phoneNumber: widget.phoneNumber,
        tempToken: widget.tempToken,
      );

      setState(() {
        _timeLeft = 30;
        _canResend = false;
      });
      _timer?.cancel();
      _startTimer();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📱 Novo código enviado via WhatsApp!'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
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
                        'Verificação WhatsApp',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Space to center the title
                  ],
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        
                        // Logo Play Viagens
                        Row(
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

                        const SizedBox(height: 40),

                        // Ícone WhatsApp com verificação
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00FF00).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF00FF00),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.message_outlined,
                                  color: Colors.black,
                                  size: 32,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF00CC00),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.verified,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Descrição (sem título)
                        Text(
                          'Digite o código que enviamos via WhatsApp para',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 8),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00FF00).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF00FF00).withOpacity(0.3)),
                          ),
                          child: Text(
                            _formatPhoneNumber(widget.phoneNumber),
                            style: const TextStyle(
                              color: Color(0xFF00FF00),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Campo de código
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Código de Verificação',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _codeController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6),
                              ],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontFamily: 'monospace',
                                letterSpacing: 8,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                hintText: '000000',
                                hintStyle: TextStyle(color: Colors.grey[400]),
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Digite o código do WhatsApp';
                                }
                                if (value.length != 6) {
                                  return 'Código deve ter 6 dígitos';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                if (_errorMessage != null) {
                                  setState(() {
                                    _errorMessage = null;
                                  });
                                }
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Timer e reenvio
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[700]!),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.schedule,
                                color: Color(0xFF00FF00),
                                size: 20,
                              ),
                              const SizedBox(height: 8),
                              if (!_canResend)
                                Text(
                                  'Reenviar código em ${_formatTime(_timeLeft)}',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              else
                                TextButton(
                                  onPressed: _isLoading ? null : _resendCode,
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFF00FF00),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.refresh, size: 16),
                                      const SizedBox(width: 8),
                                      Text(
                                        _isLoading ? 'Reenviando...' : 'Reenviar código',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Mensagem de erro
                        if (_errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.3),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                // Botão verificar (fixo na parte inferior)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading || _codeController.text.length != 6 ? null : _verifyCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00FF00),
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: Colors.grey[700],
                      disabledForegroundColor: Colors.grey[500],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.verified_user, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Verificar e Entrar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}