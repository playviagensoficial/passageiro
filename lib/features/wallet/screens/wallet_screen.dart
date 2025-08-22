import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import 'wallet_recharge_screen.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/app_bottom_navigation.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    // Load wallet data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>().refreshBalance();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Minha Carteira',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<WalletProvider>().refreshBalance();
            },
          ),
        ],
        elevation: 0,
      ),
      body: Consumer<WalletProvider>(
        builder: (context, walletProvider, child) {
          return Column(
            children: [
              // Balance Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00CC00), Color(0xFF00AA00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00CC00).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.account_balance_wallet, color: Colors.white, size: 32),
                        SizedBox(width: 12),
                        Text(
                          'Saldo disponível',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'R\$ ${walletProvider.balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const WalletRechargeScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add, color: Colors.black),
                            label: const Text(
                              'Recarregar',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _showWithdrawDialog();
                            },
                            icon: const Icon(Icons.remove, color: Colors.white),
                            label: const Text(
                              'Sacar',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black26,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Colors.white30),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Quick Stats
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Este mês',
                        'R\$ 245,30',
                        Icons.calendar_month,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Economia',
                        'R\$ 89,50',
                        Icons.savings,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Transactions Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text(
                      'Histórico de transações',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        // TODO: Show full history
                      },
                      child: const Text(
                        'Ver tudo',
                        style: TextStyle(
                          color: Color(0xFF00CC00),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Transactions List
              Expanded(
                child: walletProvider.transactions.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Nenhuma transação ainda',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: walletProvider.transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = walletProvider.transactions[index];
                          return _buildTransactionItem(transaction);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(WalletTransaction transaction) {
    final isCredit = transaction.type == TransactionType.credit;
    final dateFormat = DateFormat('dd/MM/yyyy • HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCredit ? Colors.green[900] : Colors.red[900],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isCredit ? Icons.add : Icons.remove,
              color: isCredit ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      dateFormat.format(transaction.date),
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                    if (transaction.status == TransactionStatus.pending) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange[900],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Pendente',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'}R\$ ${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: isCredit ? Colors.green : Colors.red,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog() {
    final amountController = TextEditingController();
    final bankAccountController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Saque para conta bancária',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Saldo disponível: R\$ ${context.read<WalletProvider>().balance.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFF00FF00),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              
              // Amount field
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Valor do saque',
                  labelStyle: const TextStyle(color: Colors.grey),
                  hintText: 'Ex: 50,00',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixText: 'R\$ ',
                  prefixStyle: const TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF00FF00)),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Bank account field
              TextField(
                controller: bankAccountController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Conta bancária',
                  labelStyle: const TextStyle(color: Colors.grey),
                  hintText: 'Banco - Agência - Conta',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF00FF00)),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'O saque será processado em até 2 dias úteis',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          Consumer<WalletProvider>(
            builder: (context, walletProvider, child) {
              return ElevatedButton(
                onPressed: walletProvider.isLoading ? null : () async {
                  final amountStr = amountController.text.trim();
                  final bankAccount = bankAccountController.text.trim();
                  
                  if (amountStr.isEmpty || bankAccount.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Preencha todos os campos'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  
                  final amount = double.tryParse(amountStr.replaceAll(',', '.'));
                  if (amount == null || amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Valor inválido'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  
                  if (amount < 5.0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Valor mínimo para saque é R\$ 5,00'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  
                  final success = await walletProvider.withdrawFunds(
                    amount: amount,
                    bankAccount: bankAccount,
                  );
                  
                  if (success) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Saque solicitado com sucesso!'),
                        backgroundColor: Color(0xFF00FF00),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Saldo insuficiente'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FF00),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: walletProvider.isLoading 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      )
                    : const Text(
                        'Solicitar Saque',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
}