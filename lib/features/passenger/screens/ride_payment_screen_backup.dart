import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/widgets/play_logo.dart';
import '../../../shared/theme/app_theme.dart';
import 'dart:math' as math;
import '../widgets/payment_method_selector.dart';

class RidePaymentScreen extends StatefulWidget {
  final int rideId;
  final String rideAmount;
  final int? driverId;
  final String driverName;

  const RidePaymentScreen({
    super.key,
    required this.rideId,
    required this.rideAmount,
    required this.driverId,
    required this.driverName,
  });

  @override
  State<RidePaymentScreen> createState() => _RidePaymentScreenState();
}

class _RidePaymentScreenState extends State<RidePaymentScreen> {
  String _selectedPaymentMethod = 'card';
  bool _isProcessingPayment = false;
  bool _paymentCompleted = false;
  Map<String, dynamic>? _paymentResult;
  Map<String, dynamic>? _feesBreakdown;
  final _cardController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();
  final _pixKeyController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _calculateFeesBreakdown();
  }
  
  @override
  void dispose() {
    _cardController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    _pixKeyController.dispose();
    super.dispose();
  }

  void _calculateFeesBreakdown() {
    final amount = double.tryParse(widget.rideAmount.replaceAll('R\$ ', '').replaceAll(',', '.')) ?? 0.0;
    setState(() {
      _feesBreakdown = _calculateFees(amount, _selectedPaymentMethod);
    });
  }
  
  Map<String, dynamic> _calculateFees(double amount, String method) {
    double serviceFee = 0.0;
    double processingFee = 0.0;
    
    switch (method) {
      case 'card':
        serviceFee = amount * 0.05; // 5% taxa de serviço
        processingFee = 2.50; // Taxa fixa de processamento
        break;
      case 'pix':
        serviceFee = amount * 0.02; // 2% taxa de serviço
        processingFee = 0.50; // Taxa reduzida para PIX
        break;
      case 'cash':
        serviceFee = 0.0; // Sem taxa para dinheiro
        processingFee = 0.0;
        break;
    }
    
    final total = amount + serviceFee + processingFee;
    
    return {
      'rideAmount': amount,
      'serviceFee': serviceFee,
      'processingFee': processingFee,
      'total': total,
    };
  }

  Future<void> _processPayment() async {
    if (!_validatePaymentForm()) {
      return;
    }
    
    setState(() {
      _isProcessingPayment = true;
    });
    
    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 3));
      
      final amount = double.tryParse(widget.rideAmount.replaceAll('R\$ ', '').replaceAll(',', '.')) ?? 0.0;
      final result = await _simulatePayment(amount);
      
      setState(() {
        _paymentResult = result;
        _paymentCompleted = result['success'];
        _isProcessingPayment = false;
      });
      
      if (result['success']) {
        _showSuccessDialog();
      } else {
        _showErrorDialog(result['error']);
      }
    } catch (e) {
      setState(() {
        _isProcessingPayment = false;
      });
      _showErrorDialog('Erro no processamento: $e');
    }
  }
  
  bool _validatePaymentForm() {
    switch (_selectedPaymentMethod) {
      case 'card':
        if (_cardController.text.length != 19 || // 16 digits + 3 spaces
            _expiryController.text.length != 5 || // MM/YY
            _cvvController.text.length != 3 ||
            _nameController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Preencha todos os dados do cartão'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
        break;
      case 'pix':
        if (_pixKeyController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Informe sua chave PIX'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
        break;
    }
    return true;
  }
  
  Future<Map<String, dynamic>> _simulatePayment(double amount) async {
    // Simulate different payment methods
    switch (_selectedPaymentMethod) {
      case 'card':
        // Simulate card processing
        return {
          'success': true, // Always success for demo
          'transactionId': 'TXN${DateTime.now().millisecondsSinceEpoch}',
          'method': 'Cartão de Crédito',
          'amount': amount,
          'processedAt': DateTime.now().toIso8601String(),
        };
      case 'pix':
        return {
          'success': true,
          'transactionId': 'PIX${DateTime.now().millisecondsSinceEpoch}',
          'method': 'PIX',
          'amount': amount,
          'processedAt': DateTime.now().toIso8601String(),
        };
      case 'cash':
        return {
          'success': true,
          'transactionId': 'CASH${DateTime.now().millisecondsSinceEpoch}',
          'method': 'Dinheiro',
          'amount': amount,
          'processedAt': DateTime.now().toIso8601String(),
        };
      default:
        throw Exception('Método de pagamento não suportado');
    }
  }
  
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: AppTheme.primaryColor,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Pagamento Aprovado!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Transação: ${_paymentResult?['transactionId'] ?? ''}',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/ride-evaluation',
                (route) => route.settings.name == '/passenger-home',
                arguments: {'rideId': widget.rideId},
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text(
              'Avaliar Viagem',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'Erro no Pagamento',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          error,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

    try {
      final result = await PaymentService.processPayment(
        rideId: widget.rideId,
        amount: widget.rideAmount,
        driverId: widget.driverId,
        paymentMethod: _selectedPaymentMethod,
      );

      setState(() {
        _paymentResult = result;
        _isProcessingPayment = false;
      });

      if (result['success'] == true) {
        // Show success dialog
        _showPaymentSuccessDialog();
      } else {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Erro no pagamento'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessingPayment = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao processar pagamento: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.primaryColor, size: 32),
            const SizedBox(width: 12),
            const Text('Pagamento Aprovado!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Valor: R\$ ${widget.rideAmount.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('Método: ${_getPaymentMethodName(_selectedPaymentMethod)}'),
            if (_paymentResult?['transaction_id'] != null) ...[
              const SizedBox(height: 8),
              Text('ID: ${_paymentResult!['transaction_id']}'),
            ],
            if (_paymentResult?['authorization_code'] != null) ...[
              const SizedBox(height: 8),
              Text('Autorização: ${_paymentResult!['authorization_code']}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.pushReplacementNamed(context, '/ride-evaluation', arguments: {
                'rideId': widget.rideId,
                'paymentResult': _paymentResult,
              });
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  String _getPaymentMethodName(String method) {
    switch (method) {
      case 'card_machine':
        return 'Maquininha do Motorista';
      case 'pix':
        return 'PIX';
      case 'cash':
        return 'Dinheiro';
      case 'wallet':
        return 'Carteira Play';
      default:
        return method;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const PlayLogoHorizontal(height: 32),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Finalize o Pagamento',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'Corrida com ${widget.driverName}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Valor da corrida
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryColor),
              ),
              child: Column(
                children: [
                  const Text(
                    'Valor da Corrida',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'R\$ ${widget.rideAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Payment method selector
            PaymentMethodSelector(
              selectedMethod: _selectedPaymentMethod,
              onMethodSelected: (method) {
                setState(() {
                  _selectedPaymentMethod = method;
                });
                _calculateFeesBreakdown();
              },
            ),
            
            const SizedBox(height: 24),
            
            // Fees breakdown
            if (_feesBreakdown != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Divisão do Pagamento',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFeeRow('Valor da Corrida', _feesBreakdown!['ride_amount']),
                    _buildFeeRow('Taxa da Plataforma', -_feesBreakdown!['platform_fee']),
                    if (_feesBreakdown!['card_processing_fee'] > 0)
                      _buildFeeRow('Taxa do Cartão', -_feesBreakdown!['card_processing_fee']),
                    const Divider(),
                    _buildFeeRow('Motorista Recebe', _feesBreakdown!['driver_amount'], isTotal: true),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
            ],
            
            // PIX QR Code (if PIX selected and generated)
            if (_selectedPaymentMethod == 'pix' && _paymentResult?['qr_code'] != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Escaneie o QR Code',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.qr_code,
                          size: 150,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_paymentResult?['pix_code'] != null)
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: _paymentResult!['pix_code']));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Código PIX copiado!'),
                              backgroundColor: AppTheme.primaryColor,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _paymentResult!['pix_code'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.copy, size: 16),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
            ],
            
            // Payment button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isProcessingPayment ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isProcessingPayment
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Processando...',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        _getPaymentButtonText(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeRow(String label, double amount, {bool isTotal = false}) {
    final color = amount < 0 ? Colors.red : (isTotal ? AppTheme.primaryColor : Colors.black);
    final prefix = amount < 0 ? '- R\$ ' : 'R\$ ';
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: Colors.black,
            ),
          ),
          Text(
            '$prefix${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getPaymentButtonText() {
    switch (_selectedPaymentMethod) {
      case 'card_machine':
        return 'Pagar na Maquininha';
      case 'pix':
        return 'Gerar PIX';
      case 'cash':
        return 'Confirmar Pagamento em Dinheiro';
      case 'wallet':
        return 'Pagar com Carteira';
      default:
        return 'Processar Pagamento';
    }
  }
}