import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../../auth/providers/auth_provider.dart';

class WalletRechargeScreen extends StatefulWidget {
  const WalletRechargeScreen({super.key});

  @override
  State<WalletRechargeScreen> createState() => _WalletRechargeScreenState();
}

class _WalletRechargeScreenState extends State<WalletRechargeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  
  String _selectedPaymentMethod = 'pix';
  double _selectedQuickAmount = 0;
  bool _isProcessing = false;
  
  final List<Map<String, dynamic>> _quickAmounts = [
    {'value': 20.0, 'label': 'R\$ 20'},
    {'value': 50.0, 'label': 'R\$ 50'},
    {'value': 100.0, 'label': 'R\$ 100'},
    {'value': 200.0, 'label': 'R\$ 200'},
  ];
  
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'pix',
      'name': 'PIX',
      'description': 'Transferência instantânea',
      'icon': Icons.pix,
      'color': Color(0xFF32BCAD),
    },
    {
      'id': 'credit_card',
      'name': 'Cartão de Crédito',
      'description': 'Visa, Mastercard, Elo',
      'icon': Icons.credit_card,
      'color': Color(0xFF1976D2),
    },
    {
      'id': 'debit_card',
      'name': 'Cartão de Débito',
      'description': 'Débito em conta',
      'icon': Icons.account_balance_wallet,
      'color': Color(0xFF388E3C),
    },
    {
      'id': 'boleto',
      'name': 'Boleto Bancário',
      'description': 'Vencimento em 3 dias úteis',
      'icon': Icons.receipt_long,
      'color': Color(0xFFFF5722),
    },
    {
      'id': 'bank_transfer',
      'name': 'Transferência Bancária',
      'description': 'TED/DOC',
      'icon': Icons.account_balance,
      'color': Color(0xFF795548),
    },
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _selectQuickAmount(double amount) {
    setState(() {
      _selectedQuickAmount = amount;
      _amountController.text = amount.toStringAsFixed(2);
    });
  }

  Future<void> _processRecharge() async {
    if (!_formKey.currentState!.validate()) return;
    
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      _showErrorDialog('Digite um valor válido para recarga');
      return;
    }
    
    if (amount < 5.0) {
      _showErrorDialog('Valor mínimo para recarga é R\$ 5,00');
      return;
    }
    
    if (amount > 1000.0) {
      _showErrorDialog('Valor máximo para recarga é R\$ 1.000,00');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final walletProvider = context.read<WalletProvider>();
      final authProvider = context.read<AuthProvider>();
      
      final success = await walletProvider.processRecharge(
        userId: authProvider.currentUser!.id,
        amount: amount,
        paymentMethod: _selectedPaymentMethod,
        cardData: _selectedPaymentMethod.contains('card') ? {
          'number': _cardNumberController.text,
          'holder': _cardHolderController.text,
          'expiry': _expiryController.text,
          'cvv': _cvvController.text,
        } : null,
      );

      if (success) {
        _showSuccessDialog(amount);
      } else {
        _showErrorDialog(walletProvider.errorMessage ?? 'Erro ao processar recarga');
      }
    } catch (e) {
      _showErrorDialog('Erro inesperado. Tente novamente.');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erro'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(double amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Recarga Realizada!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            Text(
              'Sua carteira foi recarregada com R\$ ${amount.toStringAsFixed(2)}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            if (_selectedPaymentMethod == 'pix') ...[
              const SizedBox(height: 16),
              const Text(
                'O valor estará disponível em instantes.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
            if (_selectedPaymentMethod == 'boleto') ...[
              const SizedBox(height: 16),
              const Text(
                'O valor será creditado após o pagamento do boleto.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to wallet
            },
            child: const Text('Concluir'),
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
        title: const Text(
          'Recarregar Carteira',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Balance Card
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
                    const Text(
                      'Saldo atual',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Consumer<WalletProvider>(
                      builder: (context, walletProvider, child) {
                        return Text(
                          'R\$ ${walletProvider.balance.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Quick Amount Selection
              const Text(
                'Valores rápidos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: _quickAmounts.map((amount) {
                  final isSelected = _selectedQuickAmount == amount['value'];
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => _selectQuickAmount(amount['value']),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF00CC00) : Colors.grey[800],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF00CC00) : Colors.grey[600]!,
                            ),
                          ),
                          child: Text(
                            amount['label'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Custom Amount Input
              const Text(
                'Ou digite o valor',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  hintText: '0,00',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixText: 'R\$ ',
                  prefixStyle: const TextStyle(color: Colors.white, fontSize: 18),
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Digite o valor da recarga';
                  }
                  final amount = double.tryParse(value!.replaceAll(',', '.'));
                  if (amount == null || amount <= 0) {
                    return 'Digite um valor válido';
                  }
                  if (amount < 5.0) {
                    return 'Valor mínimo: R\$ 5,00';
                  }
                  if (amount > 1000.0) {
                    return 'Valor máximo: R\$ 1.000,00';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Payment Methods
              const Text(
                'Escolha a forma de pagamento',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              ..._paymentMethods.map((method) {
                final isSelected = _selectedPaymentMethod == method['id'];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPaymentMethod = method['id'];
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.grey[800] : Colors.grey[850],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF00CC00) : Colors.grey[700]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: method['color'],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              method['icon'],
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  method['name'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  method['description'],
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFF00CC00),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              // Card Details Form (only show if card method selected)
              if (_selectedPaymentMethod.contains('card')) ...[
                const SizedBox(height: 24),
                const Text(
                  'Dados do cartão',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Card Number
                TextFormField(
                  controller: _cardNumberController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Número do cartão',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    hintText: '0000 0000 0000 0000',
                    hintStyle: TextStyle(color: Colors.grey[600]),
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
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(16),
                    _CardNumberFormatter(),
                  ],
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Digite o número do cartão';
                    }
                    if (value!.replaceAll(' ', '').length < 16) {
                      return 'Número do cartão inválido';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Card Holder Name
                TextFormField(
                  controller: _cardHolderController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Nome do titular',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    hintText: 'Como está impresso no cartão',
                    hintStyle: TextStyle(color: Colors.grey[600]),
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
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Digite o nome do titular';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Expiry and CVV
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _expiryController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'MM/AA',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                          hintText: '12/25',
                          hintStyle: TextStyle(color: Colors.grey[600]),
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
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                          _ExpiryDateFormatter(),
                        ],
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Digite a validade';
                          }
                          if (value!.length != 5) {
                            return 'MM/AA';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _cvvController,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'CVV',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                          hintText: '123',
                          hintStyle: TextStyle(color: Colors.grey[600]),
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
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'CVV';
                          }
                          if (value!.length < 3) {
                            return 'CVV inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 32),

              // Recharge Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processRecharge,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00CC00),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        )
                      : const Text(
                          'Recarregar Carteira',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Security Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.security, color: Color(0xFF00CC00), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Seus dados estão protegidos com criptografia de ponta a ponta',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// Card Number Formatter
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      if (i % 4 == 0 && i != 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }
    
    final formatted = buffer.toString();
    
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Expiry Date Formatter
class _ExpiryDateFormatter extends TextInputFormatter {
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
    
    final formatted = buffer.toString();
    
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}