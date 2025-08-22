import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/play_logo.dart';
import '../../../shared/theme/app_theme.dart';

class PassengerWalletScreen extends StatefulWidget {
  const PassengerWalletScreen({super.key});

  @override
  State<PassengerWalletScreen> createState() => _PassengerWalletScreenState();
}

class _PassengerWalletScreenState extends State<PassengerWalletScreen> {
  double _currentBalance = 0.00;
  List<Map<String, dynamic>> _vouchers = [
    {
      'code': 'PLAYPROMO',
      'date': '05 de jan. 09:32AM',
      'discount': 'DESCONTO 10%',
      'value': 10.0,
      'status': 'Ativo'
    },
    {
      'code': 'NOVOUSUARIO',
      'date': '03 de jan. 14:20PM', 
      'discount': 'DESCONTO 15%',
      'value': 15.0,
      'status': 'Usado'
    },
    {
      'code': 'FIDELIDADE',
      'date': '01 de jan. 08:15AM',
      'discount': 'R\$ 5,00 OFF',
      'value': 5.0,
      'status': 'Expirado'
    },
  ];

  Future<void> _showAddBalanceModal() async {
    final TextEditingController amountController = TextEditingController();
    String selectedMethod = 'pix';

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Adicionar Saldo',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Valor (R\$)',
                  hintText: '0,00',
                  prefixText: 'R\$ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                'Método de Pagamento:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('PIX'),
                      value: 'pix',
                      groupValue: selectedMethod,
                      onChanged: (value) => setDialogState(() => selectedMethod = value!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Cartão'),
                      value: 'card',
                      groupValue: selectedMethod,
                      onChanged: (value) => setDialogState(() => selectedMethod = value!),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text.replaceAll(',', '.'));
              if (amount != null && amount > 0) {
                _addBalance(amount, selectedMethod);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.black,
            ),
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _addBalance(double amount, String method) {
    setState(() {
      _currentBalance += amount;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ R\$ ${amount.toStringAsFixed(2)} adicionados via $method'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Future<void> _showWithdrawModal() async {
    final TextEditingController amountController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Sacar Saldo',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Saldo disponível: R\$ ${_currentBalance.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
            
            const SizedBox(height: 16),
            
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Valor para sacar (R\$)',
                hintText: '0,00',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text.replaceAll(',', '.'));
              if (amount != null && amount > 0 && amount <= _currentBalance) {
                _withdrawBalance(amount);
                Navigator.pop(context);
              } else if (amount != null && amount > _currentBalance) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('⚠️ Saldo insuficiente'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sacar'),
          ),
        ],
      ),
    );
  }

  void _withdrawBalance(double amount) {
    setState(() {
      _currentBalance -= amount;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('💰 R\$ ${amount.toStringAsFixed(2)} sacados com sucesso'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _showAddVoucherModal() async {
    final TextEditingController codeController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Adicionar Voucher',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeController,
              decoration: InputDecoration(
                labelText: 'Código do Voucher',
                hintText: 'Ex: PRIMEIRAVIAGEM',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (codeController.text.isNotEmpty) {
                _addVoucher(codeController.text);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.black,
            ),
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _addVoucher(String code) {
    // Simular adição de voucher
    final now = DateTime.now();
    final dateStr = '${now.day.toString().padLeft(2, '0')} de ${_getMonthName(now.month)}. ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}${now.hour >= 12 ? 'PM' : 'AM'}';
    
    setState(() {
      _vouchers.insert(0, {
        'code': code.toUpperCase(),
        'date': dateStr,
        'discount': 'DESCONTO 20%',
        'value': 20.0,
        'status': 'Ativo'
      });
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎫 Voucher "$code" adicionado com sucesso!'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];
    return months[month - 1];
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
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // Título Carteira - Conforme wireframe
                const Text(
                  'Carteira',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Card Seu Saldo Play - Conforme wireframe
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Seu Saldo Play',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        'R\$ ${_currentBalance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Botões de Saldo - Conforme wireframe
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _showAddBalanceModal,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                '+ Adicionar Saldo',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 12),
                          
                          GestureDetector(
                            onTap: _showWithdrawModal,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                '💰 Sacar Saldo',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Seção Vouchers - Conforme wireframe
                const Text(
                  'Vouchers',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Botão Adicionar Voucher - Conforme wireframe
                GestureDetector(
                  onTap: _showAddVoucherModal,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '+ Adicionar Voucher',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Histórico de Vouchers - Conforme wireframe
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: Colors.white, width: 1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Histórico de Vouchers',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Lista de Vouchers - Dinâmica baseada na lista _vouchers
                      ..._vouchers.map((voucher) => _buildVoucherItem(
                        voucher['code'],
                        voucher['date'],
                        voucher['discount'],
                        voucher['status'],
                      )).toList(),
                    ],
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

  // Item de voucher conforme wireframe com status
  Widget _buildVoucherItem(String code, String date, String discount, String status) {
    // Definir cor baseada no status
    Color statusColor;
    Color textColor = Colors.white;
    
    switch (status.toLowerCase()) {
      case 'ativo':
        statusColor = AppTheme.primaryColor;
        break;
      case 'usado':
        statusColor = Colors.orange;
        textColor = Colors.grey[400]!;
        break;
      case 'expirado':
        statusColor = Colors.red;
        textColor = Colors.grey[600]!;
        break;
      default:
        statusColor = Colors.grey;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Código do voucher
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  code,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Data
          Expanded(
            flex: 3,
            child: Text(
              date,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
              ),
            ),
          ),
          
          // Desconto
          Expanded(
            flex: 2,
            child: Text(
              discount,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}