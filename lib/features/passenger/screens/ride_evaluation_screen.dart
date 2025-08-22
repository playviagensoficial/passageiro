import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/play_logo.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/api/api_client.dart';
import '../../auth/providers/auth_provider.dart';

class RideEvaluationScreen extends StatefulWidget {
  const RideEvaluationScreen({super.key});

  @override
  State<RideEvaluationScreen> createState() => _RideEvaluationScreenState();
}

class _RideEvaluationScreenState extends State<RideEvaluationScreen> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;
  int? _rideId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['rideId'] != null) {
        _rideId = args['rideId'];
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitEvaluation() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione uma avaliação'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final apiClient = ApiClient.instance;
      final authProvider = context.read<AuthProvider>();
      
      // Usar um rideId padrão se não tiver sido passado
      final rideIdToUse = _rideId ?? 1;
      
      print('⭐ Enviando avaliação - RideId: $rideIdToUse, Rating: $_rating');
      
      final response = await apiClient.rateRide(
        rideIdToUse, 
        rating: _rating.toDouble(),
        comment: _commentController.text.trim(),
      );
      
      if (response.statusCode == 200) {
        print('✅ Avaliação enviada com sucesso');
        
        if (mounted) {
          // Mostrar confirmação
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Avaliação enviada com sucesso!'),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
          
          // Navegar de volta para home
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/passenger-home',
            (route) => false,
          );
        }
      } else {
        throw Exception(response.data?['error'] ?? 'Erro ao enviar avaliação');
      }
    } catch (e) {
      print('❌ Erro ao enviar avaliação: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar avaliação: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _skipEvaluation() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/passenger-home',
      (route) => false,
    );
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
        actions: [
          TextButton(
            onPressed: _skipEvaluation,
            child: const Text(
              'Pular',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            
            // Ícone de sucesso
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.black,
                size: 60,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Título
            const Text(
              'Viagem Concluída!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Subtítulo
            Text(
              'Esperamos que tenha tido uma boa experiência',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Informações da corrida
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  // Informações do motorista
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey[300],
                        child: const Icon(
                          Icons.person,
                          color: Colors.grey,
                          size: 40,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'João Silva',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Volkswagen Gol • ABC-1234',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.orange, size: 16),
                                const Text(
                                  ' 4,5',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Detalhes da viagem
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTripInfo('Tempo', '12 min'),
                      _buildTripInfo('Distância', '5,6 km'),
                      _buildTripInfo('Valor', 'R\$ 10,96'),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Avaliação
            const Text(
              'Como foi sua experiência?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Estrelas para avaliação
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      Icons.star,
                      size: 50,
                      color: index < _rating ? Colors.orange : Colors.grey[300],
                    ),
                  ),
                );
              }),
            ),
            
            const SizedBox(height: 8),
            
            // Texto da avaliação
            if (_rating > 0)
              Text(
                _getRatingText(_rating),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            
            const SizedBox(height: 32),
            
            // Campo de comentário
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _commentController,
                maxLines: 4,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Deixe um comentário (opcional)',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Botão de enviar
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitEvaluation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Enviar Avaliação',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Botão de pular
            SizedBox(
              width: double.infinity,
              height: 60,
              child: TextButton(
                onPressed: _skipEvaluation,
                child: const Text(
                  'Pular Avaliação',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
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

  Widget _buildTripInfo(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Muito ruim';
      case 2:
        return 'Ruim';
      case 3:
        return 'Regular';
      case 4:
        return 'Bom';
      case 5:
        return 'Excelente';
      default:
        return '';
    }
  }
}