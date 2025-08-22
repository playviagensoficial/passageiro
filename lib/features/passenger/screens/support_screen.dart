import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/widgets/play_logo.dart';
import '../../../shared/theme/app_theme.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  Future<void> _sendEmail(String email) async {
    final url = 'mailto:$email?subject=Suporte Play Viagens';
    if (await canLaunch(url)) {
      await launch(url);
    }
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
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Título Suporte
            const Text(
              'Suporte',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'Como podemos ajudar você?',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Central de Ajuda
            _buildSectionHeader('Central de Ajuda'),
            const SizedBox(height: 16),
            
            _buildSupportCard(
              'Perguntas Frequentes',
              'Encontre respostas para as dúvidas mais comuns',
              Icons.help_outline,
              () {
                // Navegar para FAQ
              },
            ),
            
            _buildSupportCard(
              'Guias e Tutoriais',
              'Aprenda a usar todos os recursos do app',
              Icons.book_outlined,
              () {
                // Navegar para guias
              },
            ),
            
            _buildSupportCard(
              'Relatório de Problemas',
              'Reporte bugs ou problemas técnicos',
              Icons.bug_report_outlined,
              () {
                // Navegar para reportar problema
              },
            ),
            
            const SizedBox(height: 32),
            
            // Contato Direto
            _buildSectionHeader('Contato Direto'),
            const SizedBox(height: 16),
            
            _buildContactCard(
              'WhatsApp',
              'Fale conosco pelo WhatsApp',
              Icons.message,
              AppTheme.primaryColor,
              () => _launchURL('https://wa.me/5511999999999'),
            ),
            
            _buildContactCard(
              'Telefone',
              '(11) 9999-9999',
              Icons.phone,
              Colors.blue,
              () => _makePhoneCall('+5511999999999'),
            ),
            
            _buildContactCard(
              'E-mail',
              'suporte@playviagens.com.br',
              Icons.email,
              Colors.orange,
              () => _sendEmail('suporte@playviagens.com.br'),
            ),
            
            const SizedBox(height: 32),
            
            // Emergência
            _buildSectionHeader('Emergência'),
            const SizedBox(height: 16),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red, width: 2),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.emergency,
                    color: Colors.red,
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Linha de Emergência',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Em caso de emergência durante a viagem',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _makePhoneCall('190'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Ligar para 190',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Informações do App
            _buildSectionHeader('Informações do App'),
            const SizedBox(height: 16),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Versão do App', '1.0.0'),
                  const SizedBox(height: 12),
                  _buildInfoRow('Build', '1.0.0+1'),
                  const SizedBox(height: 12),
                  _buildInfoRow('Plataforma', 'Android'),
                  const SizedBox(height: 12),
                  _buildInfoRow('Última Atualização', '18/08/2025'),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Links Úteis
            _buildSectionHeader('Links Úteis'),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildLinkButton(
                    'Termos de Uso',
                    () => _launchURL('https://playviagens.com.br/termos'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildLinkButton(
                    'Privacidade',
                    () => _launchURL('https://playviagens.com.br/privacidade'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSupportCard(String title, String description, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[800]!),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLinkButton(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.primaryColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: AppTheme.primaryColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}