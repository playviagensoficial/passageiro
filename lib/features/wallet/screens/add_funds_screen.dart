import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';

class AddFundsScreen extends StatefulWidget {
  const AddFundsScreen({super.key});

  @override
  State<AddFundsScreen> createState() => _AddFundsScreenState();
}

class _AddFundsScreenState extends State<AddFundsScreen> {
  final TextEditingController _amountController = TextEditingController();
  String _selectedPaymentMethod = 'pix';
  final List<double> _quickAmounts = [20.00, 50.00, 100.00, 200.00];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _selectQuickAmount(double amount) {
    _amountController.text = amount.toStringAsFixed(2);
  }

  Future<void> _processAddFunds() async {
    final amountText = _amountController.text.replaceAll(',', '.');
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite um valor válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (amount < 5.00) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Valor mínimo: R\$ 5,00'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final walletProvider = context.read<WalletProvider>();
    
    final success = await walletProvider.addFunds(
      amount: amount,
      paymentMethod: _selectedPaymentMethod,
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('R\$ ${amount.toStringAsFixed(2)} adicionados com sucesso!'),
          backgroundColor: const Color(0xFF00CC00),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao adicionar saldo. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Adicionar Saldo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<WalletProvider>(
        builder: (context, walletProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Current Balance Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00CC00), Color(0xFF00AA00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Saldo atual',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                        ],
                      ),
                      Text(
                        'R\$ ${walletProvider.balance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Amount Input Section
                const Text(
                  'Quanto você quer adicionar?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Amount Input Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF00CC00)),
                  ),
                  child: TextField(
                    controller: _amountController,
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    decoration: InputDecoration(
                      prefixText: 'R\$ ',
                      prefixStyle: const TextStyle(
                        color: Color(0xFF00CC00),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      hintText: '0,00',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Quick Amount Buttons
                const Text(
                  'Valores rápidos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: _quickAmounts.map((amount) {
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: OutlinedButton(
                          onPressed: () => _selectQuickAmount(amount),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF00CC00)),
                            foregroundColor: const Color(0xFF00CC00),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'R\$ ${amount.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                // Payment Method Section
                const Text(
                  'Forma de pagamento',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                // Payment Methods
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _PaymentMethodTile(
                        icon: Icons.pix,
                        title: 'PIX',
                        subtitle: 'Aprovação instantânea',
                        value: 'pix',
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
                        isRecommended: true,
                      ),
                      _PaymentMethodTile(
                        icon: Icons.credit_card,
                        title: 'Cartão de Crédito',
                        subtitle: 'Até 12x sem juros',
                        value: 'credit_card',
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
                      ),
                      _PaymentMethodTile(
                        icon: Icons.qr_code,
                        title: 'Boleto Bancário',
                        subtitle: 'Aprovação em até 2 dias úteis',
                        value: 'boleto',
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Add Funds Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: walletProvider.isLoading ? null : _processAddFunds,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00CC00),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: walletProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            'ADICIONAR SALDO',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Info Text
                Text(
                  'Valor mínimo: R\$ 5,00\nMáximo: R\$ 1.000,00 por transação',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;
  final bool isRecommended;

  const _PaymentMethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.isRecommended = false,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      activeColor: const Color(0xFF00CC00),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      title: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isRecommended) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00CC00),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'RECOMENDADO',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}