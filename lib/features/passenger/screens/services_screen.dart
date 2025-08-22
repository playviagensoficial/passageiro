import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ride/providers/ride_provider.dart';
import '../../../core/models/vehicle_category.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RideProvider>().loadVehicleCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Nossos Serviços',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF00FF00).withOpacity(0.1),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF00FF00), width: 1),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00FF00),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00FF00).withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.directions_car,
                        color: Colors.black,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Play Viagens',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Conectando você ao seu destino com segurança e praticidade',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),

              // Vehicle Categories
              const Text(
                'Categorias de Veículos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Consumer<RideProvider>(
                builder: (context, rideProvider, child) {
                  if (rideProvider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF00FF00)),
                    );
                  }

                  return Column(
                    children: rideProvider.vehicleCategories.map((category) {
                      return _buildServiceCard(
                        title: category.displayName ?? category.name,
                        description: _getServiceDescription(category.name),
                        icon: _getServiceIcon(category.name),
                        price: 'A partir de R\$ ${category.baseFareValue.toStringAsFixed(2)}',
                        features: _getServiceFeatures(category.name),
                        onTap: () => _selectService(category),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Additional Services
              const Text(
                'Serviços Especiais',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              _buildServiceCard(
                title: 'Viagens Agendadas',
                description: 'Agende sua viagem com antecedência e viaje com tranquilidade',
                icon: Icons.schedule,
                price: 'Sem taxa adicional',
                features: ['Agendamento com até 30 dias', 'Confirmação automática', 'Lembrete por notificação'],
                onTap: () => Navigator.pushNamed(context, '/schedule-ride'),
              ),

              _buildServiceCard(
                title: 'Viagens Corporativas',
                description: 'Soluções de mobilidade para empresas',
                icon: Icons.business,
                price: 'Consulte condições',
                features: ['Faturamento mensal', 'Relatórios detalhados', 'Centro de custo'],
                onTap: () => _showCorporateInfo(),
              ),

              _buildServiceCard(
                title: 'Entrega de Objetos',
                description: 'Envie seus objetos com segurança',
                icon: Icons.local_shipping,
                price: 'A partir de R\$ 8,00',
                features: ['Rastreamento em tempo real', 'Seguro incluso', 'Entrega em até 2h'],
                onTap: () => _showDeliveryInfo(),
              ),

              const SizedBox(height: 32),

              // Support Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.support_agent, color: Color(0xFF00FF00)),
                        SizedBox(width: 12),
                        Text(
                          'Suporte 24/7',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Nossa equipe está sempre disponível para ajudar você',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSupportButton(
                            'Chat Online',
                            Icons.chat,
                            () => _openChat(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSupportButton(
                            'WhatsApp',
                            Icons.message,
                            () => _openWhatsApp(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String description,
    required IconData icon,
    required String price,
    required List<String> features,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00FF00).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00FF00).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: const Color(0xFF00FF00), size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            price,
                            style: const TextStyle(
                              color: Color(0xFF00FF00),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: features.map((feature) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF00FF00).withOpacity(0.2)),
                      ),
                      child: Text(
                        feature,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSupportButton(String title, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00FF00),
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  String _getServiceDescription(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'economy':
        return 'Opção econômica para o dia a dia com veículos confortáveis';
      case 'comfort':
        return 'Mais espaço e conforto para suas viagens';
      case 'premium':
        return 'Máximo conforto e luxo para ocasiões especiais';
      case 'moto':
        return 'Rápido e econômico para pequenas distâncias';
      default:
        return 'Serviço de transporte confiável e seguro';
    }
  }

  IconData _getServiceIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'economy':
        return Icons.directions_car;
      case 'comfort':
        return Icons.car_rental;
      case 'premium':
        return Icons.local_taxi;
      case 'moto':
        return Icons.two_wheeler;
      default:
        return Icons.directions_car;
    }
  }

  List<String> _getServiceFeatures(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'economy':
        return ['Até 4 passageiros', 'Ar-condicionado', 'Preço baixo'];
      case 'comfort':
        return ['Até 4 passageiros', 'Veículos superiores', 'Mais espaço'];
      case 'premium':
        return ['Até 4 passageiros', 'Veículos de luxo', 'Serviço VIP'];
      case 'moto':
        return ['1 passageiro', 'Entrega rápida', 'Trânsito ágil'];
      default:
        return ['Serviço confiável', 'Motoristas verificados', 'Suporte 24/7'];
    }
  }

  void _selectService(VehicleCategory category) {
    Navigator.pushNamed(context, '/request-ride');
  }

  void _showCorporateInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Viagens Corporativas', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Entre em contato conosco para saber mais sobre nossas soluções corporativas:\n\n'
          '• Faturamento mensal\n'
          '• Relatórios detalhados\n'
          '• Gestão de centro de custo\n'
          '• Aprovação de viagens\n'
          '• Dashboard executivo',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar', style: TextStyle(color: Color(0xFF00FF00))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _openWhatsApp();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FF00)),
            child: const Text('Entrar em Contato', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showDeliveryInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Entrega de Objetos', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Serviço de entrega rápida e segura:\n\n'
          '• Rastreamento em tempo real\n'
          '• Seguro incluso\n'
          '• Entrega em até 2h\n'
          '• Objetos até 10kg\n'
          '• Documentos e pequenos volumes',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar', style: TextStyle(color: Color(0xFF00FF00))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implementar tela de entrega
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Funcionalidade em desenvolvimento'),
                  backgroundColor: Color(0xFF00FF00),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FF00)),
            child: const Text('Solicitar Entrega', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _openChat() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chat online em desenvolvimento'),
        backgroundColor: Color(0xFF00FF00),
      ),
    );
  }

  void _openWhatsApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Redirecionando para WhatsApp...'),
        backgroundColor: Color(0xFF00FF00),
      ),
    );
    // TODO: Implementar abertura do WhatsApp
  }
}