import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ride/providers/ride_provider.dart';
import '../../maps/providers/map_provider.dart';
import '../../auth/providers/auth_provider.dart';

class FirstTripScreen extends StatefulWidget {
  const FirstTripScreen({super.key});

  @override
  State<FirstTripScreen> createState() => _FirstTripScreenState();
}

class _FirstTripScreenState extends State<FirstTripScreen> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  int _currentStep = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutQuart));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));
    
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Go to ride request
      Navigator.pushReplacementNamed(context, '/request-ride');
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
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
        title: const Text(
          'Primeira Viagem',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/request-ride'),
            child: const Text(
              'Pular',
              style: TextStyle(color: Color(0xFF00FF00)),
            ),
          ),
        ],
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Progress indicator
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: List.generate(3, (index) {
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                        height: 4,
                        decoration: BoxDecoration(
                          color: index <= _currentStep 
                              ? const Color(0xFF00FF00) 
                              : Colors.grey.shade700,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildWelcomeStep(),
                    _buildBenefitsStep(),
                    _buildPromoStep(),
                  ],
                ),
              ),

              // Navigation buttons
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _previousStep,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF00FF00),
                            side: const BorderSide(color: Color(0xFF00FF00)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Voltar'),
                        ),
                      ),
                    
                    if (_currentStep > 0) const SizedBox(width: 16),
                    
                    Expanded(
                      flex: _currentStep == 0 ? 1 : 1,
                      child: ElevatedButton(
                        onPressed: _nextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00FF00),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _currentStep < 2 ? 'Continuar' : 'Solicitar Primeira Viagem',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
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

  Widget _buildWelcomeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 40),
          
          // Welcome illustration
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF00FF00).withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.waving_hand,
              size: 100,
              color: Color(0xFF00FF00),
            ),
          ),
          
          const SizedBox(height: 40),
          
          const Text(
            'Bem-vindo ao Play Viagens!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          const Text(
            'Estamos muito felizes em ter você conosco! Vamos te mostrar como é fácil solicitar sua primeira viagem.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 40),
          
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00FF00).withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00FF00).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.security,
                        color: Color(0xFF00FF00),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Segurança em primeiro lugar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Todos os nossos motoristas são verificados',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00FF00).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Color(0xFF00FF00),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rastreamento em tempo real',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Acompanhe sua viagem do início ao fim',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          const Text(
            'Por que escolher o Play Viagens?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 40),
          
          _buildBenefitCard(
            Icons.speed,
            'Chegada Rápida',
            'Motoristas próximos a você',
            'Em média 3-5 minutos',
          ),
          
          const SizedBox(height: 16),
          
          _buildBenefitCard(
            Icons.attach_money,
            'Preço Justo',
            'Tarifas transparentes e competitivas',
            'Sem taxas escondidas',
          ),
          
          const SizedBox(height: 16),
          
          _buildBenefitCard(
            Icons.support_agent,
            'Suporte 24/7',
            'Estamos sempre aqui para ajudar',
            'Chat ou telefone disponível',
          ),
          
          const SizedBox(height: 16),
          
          _buildBenefitCard(
            Icons.payment,
            'Múltiplas Formas de Pagamento',
            'PIX, cartão, dinheiro ou carteira digital',
            'Escolha como prefere pagar',
          ),
        ],
      ),
    );
  }

  Widget _buildPromoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // Promo illustration
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF00FF00).withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.card_giftcard,
              size: 80,
              color: Color(0xFF00FF00),
            ),
          ),
          
          const SizedBox(height: 30),
          
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00FF00).withOpacity(0.9),
                  const Color(0xFF00CC00).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FF00).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '🎉',
                      style: TextStyle(fontSize: 30),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'OFERTA ESPECIAL',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '🎉',
                      style: TextStyle(fontSize: 30),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                const Text(
                  '50% OFF',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const Text(
                  'na sua primeira viagem',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Válido apenas para novos usuários',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          const Text(
            'Como funciona?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 20),
          
          _buildHowItWorksStep(
            1,
            'Escolha seu destino',
            'Digite para onde você quer ir',
            Icons.location_on,
          ),
          
          const SizedBox(height: 12),
          
          _buildHowItWorksStep(
            2,
            'Confirme sua viagem',
            'Selecione o tipo de veículo e forma de pagamento',
            Icons.directions_car,
          ),
          
          const SizedBox(height: 12),
          
          _buildHowItWorksStep(
            3,
            'Acompanhe em tempo real',
            'Veja a localização do motorista no mapa',
            Icons.track_changes,
          ),
          
          const SizedBox(height: 12),
          
          _buildHowItWorksStep(
            4,
            'Chegue ao seu destino',
            'Avalie sua experiência e pronto!',
            Icons.flag,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitCard(IconData icon, String title, String description, String detail) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00FF00).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF00FF00).withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFF00FF00), size: 32),
          ),
          const SizedBox(width: 20),
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
                  description,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: const TextStyle(
                    color: Color(0xFF00FF00),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksStep(int step, String title, String description, IconData icon) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF00FF00),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00FF00).withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              step.toString(),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF00FF00), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        description,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}