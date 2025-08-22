import 'package:flutter/material.dart';
import '../../../shared/theme/app_theme.dart';

class PaymentMethodSelector extends StatefulWidget {
  final String selectedMethod;
  final Function(String) onMethodSelected;

  const PaymentMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onMethodSelected,
  });

  @override
  State<PaymentMethodSelector> createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<PaymentMethodSelector> {
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'card',
      'name': 'Maquininha do Motorista',
      'description': 'Débito/Crédito na máquina',
      'icon': Icons.credit_card,
      'color': Colors.blue,
      'preferred': true,
    },
    {
      'id': 'pix',
      'name': 'PIX',
      'description': 'Pagamento instantâneo',
      'icon': Icons.qr_code,
      'color': Colors.green,
      'preferred': true,
    },
    {
      'id': 'cash',
      'name': 'Dinheiro',
      'description': 'Pagamento em espécie',
      'icon': Icons.attach_money,
      'color': Colors.orange,
      'preferred': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Forma de Pagamento',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        
        const SizedBox(height: 16),
        
        ...(_paymentMethods.map((method) => _buildPaymentMethod(method)).toList()),
      ],
    );
  }

  Widget _buildPaymentMethod(Map<String, dynamic> method) {
    final isSelected = widget.selectedMethod == method['id'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => widget.onMethodSelected(method['id']),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? method['color'].withOpacity(0.1) : Colors.white,
            border: Border.all(
              color: isSelected ? method['color'] : Colors.grey[300]!,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: method['color'].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  method['icon'],
                  color: method['color'],
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          method['name'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? method['color'] : Colors.black,
                          ),
                        ),
                        if (method['preferred'])
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Recomendado',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      method['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: method['color'],
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}