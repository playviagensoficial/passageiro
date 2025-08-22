import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'Política de Privacidade',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Center(
              child: Text(
                'Política de Privacidade – Play Viagens®',
                style: TextStyle(
                  color: Color(0xFF00FF00),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 8),
            
            const Center(
              child: Text(
                'Última atualização: 15/08/2025',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Content
            _buildSection(
              'Introdução',
              'A Play Viagens®, por meio de sua associação vinculada Play Viagens – Associação de Mobilidade e Inclusão (CNPJ 61.805.518/0001-97), com sede na Rua Clóvis Cezar de Oliveira, 188 – Bairro Santa Cruz – Concórdia/SC – CEP 89.703-142, preza pela segurança, privacidade e transparência no tratamento dos dados dos seus usuários – motoristas, passageiros e licenciados.\n\nAo utilizar nossos serviços ou acessar nossas plataformas digitais, você aceita os termos desta Política de Privacidade.',
            ),
            
            _buildSection(
              '1. A quem se aplica esta Política',
              'Esta política se aplica a todos os usuários da Play Viagens®, incluindo:\n\n• Motoristas cadastrados na plataforma;\n• Passageiros que utilizam o aplicativo ou serviços de transporte;\n• Licenciados e parceiros regionais.',
            ),
            
            _buildSection(
              '2. Quais dados coletamos',
              'a) Dados pessoais:\n• Nome completo, CPF/CNPJ, endereço, telefone, e-mail;\n• Dados bancários ou carteira digital (para pagamentos e repasses);\n• Dados de CNH, veículo e documentos obrigatórios (motoristas);\n• Informações de geolocalização (durante uso do app);\n• Foto de perfil (motorista e passageiro).\n\nb) Dados de uso da plataforma:\n• Histórico de viagens, pagamentos e interações;\n• Avaliações, comunicações e reclamações;\n• Informações de dispositivo, IP e cookies.',
            ),
            
            _buildSection(
              '3. Finalidade da coleta',
              'Utilizamos seus dados para:\n\n• Operar e melhorar a plataforma de mobilidade;\n• Efetuar pagamentos e repasses;\n• Garantir a segurança de usuários e condutores;\n• Cumprir obrigações legais e regulatórias;\n• Enviar comunicações importantes e suporte;\n• Análise de desempenho para licenciados e parceiros.',
            ),
            
            _buildSection(
              '4. Compartilhamento de dados',
              'A Play Viagens® não vende dados pessoais. Compartilhamos informações apenas quando necessário para:\n\n• Processamento de pagamentos (ex: gateways como PagSeguro, InfinitePay);\n• Cumprimento de obrigações legais ou judiciais;\n• Prestação de suporte técnico e operacional por parceiros autorizados;\n• Envio de informações por meio de WhatsApp (via API autorizada), e-mail ou notificação.',
            ),
            
            _buildSection(
              '5. Armazenamento e segurança',
              'Seus dados são armazenados em ambiente seguro, com criptografia e acesso restrito. Aplicamos medidas técnicas e administrativas para prevenir vazamentos, acessos indevidos ou uso não autorizado.',
            ),
            
            _buildSection(
              '6. Direitos do usuário',
              'Você tem direito a:\n\n• Confirmar a existência de tratamento de dados;\n• Solicitar acesso, correção ou exclusão dos seus dados;\n• Revogar consentimento, nos termos da LGPD (Lei 13.709/2018);\n• Solicitar a portabilidade de dados, quando aplicável.\n\nPara exercer seus direitos, entre em contato pelo e-mail: suporte@playviagens.org ou WhatsApp (49) 9 3300-8629.',
            ),
            
            _buildSection(
              '7. Cookies e tecnologias de rastreamento',
              'Utilizamos cookies para personalizar sua experiência. Você pode gerenciar suas preferências diretamente no navegador.',
            ),
            
            _buildSection(
              '8. Alterações nesta Política',
              'Reservamo-nos o direito de alterar esta Política a qualquer momento. As alterações entrarão em vigor na data de sua publicação em nossos canais oficiais.',
            ),
            
            _buildSection(
              '9. Contato',
              'Play Viagens – Associação de Mobilidade e Inclusão\nRua Clóvis Cezar de Oliveira, 188 – Concórdia/SC\nE-mail: suporte@playviagens.org\nWhatsApp: (49) 9 3300-8629',
            ),
            
            const SizedBox(height: 24),
            
            // Footer
            const Center(
              child: Text(
                '© Play Viagens® – Marca registrada. Todos os direitos reservados.',
                style: TextStyle(
                  color: Color(0xFF00FF00),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF00FF00),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}