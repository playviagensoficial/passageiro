import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../shared/widgets/play_logo.dart';
import '../../../shared/theme/app_theme.dart';

class RidePaymentScreen extends StatefulWidget {
  final int rideId;
  final String rideAmount;
  final int? driverId;
  final String driverName;

  const RidePaymentScreen({
    super.key,
    required this.rideId,
    required this.rideAmount,
    this.driverId,
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
  
  // Card form controllers
  final _cardController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();
  
  // PIX form controller
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

  bool _validatePaymentForm() {
    switch (_selectedPaymentMethod) {
      case 'card':
        if (_cardController.text.length < 16 ||
            _expiryController.text.length != 5 ||
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
  
  Future<Map<String, dynamic>> _simulatePayment(double amount) async {
    // Simulate different payment methods
    switch (_selectedPaymentMethod) {
      case 'card':
        return {
          'success': true,
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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
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
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'Corrida com ${widget.driverName}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[400],
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
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.rideAmount.startsWith('R\$') ? widget.rideAmount : 'R\$ ${widget.rideAmount}',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Payment method selector
            const Text(
              'Forma de Pagamento',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            _buildPaymentMethodOption('card', 'Cartão de Crédito/Débito', Icons.credit_card, Colors.blue),
            const SizedBox(height: 12),
            _buildPaymentMethodOption('pix', 'PIX', Icons.qr_code, Colors.green),
            const SizedBox(height: 12),
            _buildPaymentMethodOption('cash', 'Dinheiro', Icons.attach_money, Colors.orange),
            
            const SizedBox(height: 32),
            
            // Payment form
            if (_selectedPaymentMethod == 'card') _buildCardForm(),
            if (_selectedPaymentMethod == 'pix') _buildPixForm(),
            if (_selectedPaymentMethod == 'cash') _buildCashInfo(),
            
            const SizedBox(height: 32),
            
            // Fees breakdown
            if (_feesBreakdown != null) _buildFeesBreakdown(),
            
            const SizedBox(height: 32),
            
            // Process payment button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isProcessingPayment ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isProcessingPayment
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodOption(String method, String name, IconData icon, Color color) {
    final isSelected = _selectedPaymentMethod == method;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
        _calculateFeesBreakdown();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : Colors.white.withOpacity(0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  color: isSelected ? color : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCardForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dados do Cartão',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Número do cartão
        TextField(
          controller: _cardController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16),
            CardNumberFormatter(),
          ],
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Número do Cartão',
            labelStyle: TextStyle(color: Colors.grey[400]),
            hintText: '1234 5678 9012 3456',
            hintStyle: TextStyle(color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[600]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[600]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            prefixIcon: const Icon(Icons.credit_card, color: Colors.blue),
          ),
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            // Data de validade
            Expanded(
              child: TextField(
                controller: _expiryController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                  DateFormatter(),
                ],
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Validade',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  hintText: 'MM/AA',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[600]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[600]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // CVV
            Expanded(
              child: TextField(
                controller: _cvvController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'CVV',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  hintText: '123',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[600]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[600]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                  ),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Nome no cartão
        TextField(
          controller: _nameController,
          textCapitalization: TextCapitalization.characters,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Nome no Cartão',
            labelStyle: TextStyle(color: Colors.grey[400]),
            hintText: 'NOME COMPLETO',
            hintStyle: TextStyle(color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[600]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[600]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            prefixIcon: const Icon(Icons.person, color: Colors.blue),
          ),
        ),
      ],
    );
  }

  Widget _buildPixForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dados do PIX',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        TextField(
          controller: _pixKeyController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Chave PIX',
            labelStyle: TextStyle(color: Colors.grey[400]),
            hintText: 'CPF, e-mail, telefone ou chave aleatória',
            hintStyle: TextStyle(color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[600]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[600]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            prefixIcon: const Icon(Icons.qr_code, color: Colors.green),
          ),
        ),
        
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.green),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'O PIX será processado instantaneamente após a confirmação.',
                  style: TextStyle(
                    color: Colors.green[300],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCashInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.attach_money, color: Colors.orange, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Pagamento em Dinheiro',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Você pagará diretamente ao motorista no final da viagem.',
            style: TextStyle(
              color: Colors.orange[300],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeesBreakdown() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withOpacity(0.3)),
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
          const SizedBox(height: 16),
          
          _buildFeeRow('Valor da corrida', _feesBreakdown!['rideAmount']),
          if (_feesBreakdown!['serviceFee'] > 0)
            _buildFeeRow('Taxa de serviço', _feesBreakdown!['serviceFee']),
          if (_feesBreakdown!['processingFee'] > 0)
            _buildFeeRow('Taxa de processamento', _feesBreakdown!['processingFee']),
          
          const Divider(color: Colors.white54),
          
          _buildFeeRow('Total', _feesBreakdown!['total'], isTotal: true),
        ],
      ),
    );
  }

  Widget _buildFeeRow(String label, double value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? Colors.white : Colors.grey[400],
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            'R\$ ${value.toStringAsFixed(2)}',
            style: TextStyle(
              color: isTotal ? AppTheme.primaryColor : Colors.white,
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  String _getPaymentButtonText() {
    switch (_selectedPaymentMethod) {
      case 'card':
        return 'Pagar com Cartão';
      case 'pix':
        return 'Pagar com PIX';
      case 'cash':
        return 'Confirmar Pagamento em Dinheiro';
      default:
        return 'Processar Pagamento';
    }
  }
}

// Card number formatter
class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }
    
    return newValue.copyWith(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.toString().length),
    );
  }
}

// Date formatter (MM/YY)
class DateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      if (i == 2) {
        buffer.write('/');
      }
      buffer.write(text[i]);
    }
    
    return newValue.copyWith(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.toString().length),
    );
  }
}