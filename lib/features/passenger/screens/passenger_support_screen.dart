import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/widgets/play_logo.dart';
import '../../../shared/theme/app_theme.dart';

class PassengerSupportScreen extends StatefulWidget {
  const PassengerSupportScreen({super.key});

  @override
  State<PassengerSupportScreen> createState() => _PassengerSupportScreenState();
}

class _PassengerSupportScreenState extends State<PassengerSupportScreen> {
  late final List<SupportOption> _supportOptions;
  
  @override
  void initState() {
    super.initState();
    _supportOptions = [
      SupportOption(
        icon: Icons.help_outline,
        title: 'Central de Ajuda',
        subtitle: 'Perguntas frequentes e tutoriais completos',
        color: Colors.blue,
        onTap: () => _showHelpCenter(),
      ),
      SupportOption(
        icon: Icons.message,
        title: 'WhatsApp',
        subtitle: '(49) 9 3300-8629',
        color: const Color(0xFF25D366),
        onTap: () => _openWhatsApp(),
      ),
      SupportOption(
        icon: Icons.phone,
        title: 'Telefone',
        subtitle: '(49) 9 3300-8629',
        color: Colors.orange,
        onTap: () => _makePhoneCall(),
      ),
      SupportOption(
        icon: Icons.email,
        title: 'E-mail',
        subtitle: 'suporte@playviagens.org',
        color: Colors.red,
        onTap: () => _sendEmail(),
      ),
      SupportOption(
        icon: Icons.feedback,
        title: 'Enviar Feedback',
        subtitle: 'Conte-nos sua experiência',
        color: Colors.purple,
        onTap: () => _showFeedbackDialog(),
      ),
      SupportOption(
        icon: Icons.star_rate,
        title: 'Avaliar Aplicativo',
        subtitle: 'Deixe sua avaliação na loja',
        color: Colors.amber,
        onTap: () => _rateApp(),
      ),
      SupportOption(
        icon: Icons.link,
        title: 'Links Úteis',
        subtitle: 'Termos de uso e documentos',
        color: Colors.cyan,
        onTap: () => _showUsefulLinks(),
      ),
    ];
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
            
            // Título
            const Text(
              'Suporte',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Como podemos ajudar você?',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Opções de suporte
            ...(_supportOptions.map((option) => _buildSupportOption(option)).toList()),
            
            const SizedBox(height: 32),
            
            // Informações de contato de emergência
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.emergency, color: Colors.red[300]),
                      const SizedBox(width: 8),
                      Text(
                        'Emergência',
                        style: TextStyle(
                          color: Colors.red[300],
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  const Text(
                    'Em caso de emergência durante uma viagem, entre em contato imediatamente:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _makePhoneCall('190'),
                          icon: const Icon(Icons.local_police, color: Colors.white),
                          label: const Text(
                            'Polícia - 190',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            padding: const EdgeInsets.all(12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _makePhoneCall('192'),
                          icon: const Icon(Icons.local_hospital, color: Colors.white),
                          label: const Text(
                            'SAMU - 192',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[700],
                            padding: const EdgeInsets.all(12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
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
            
            // Informações da versão
            Center(
              child: Column(
                children: [
                  Text(
                    'Play Viagens Passageiro',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Versão 1.0.0',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportOption(SupportOption option) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _handleSupportOptionTap(option),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: option.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  option.icon,
                  color: option.color,
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      option.subtitle,
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

  void _handleSupportOptionTap(SupportOption option) {
    if (option.onTap != null) {
      option.onTap();
    }
  }

  void _showHelpCenter() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FAQScreen(),
      ),
    );
  }

  Future<void> _openWhatsApp() async {
    final Uri launchUri = Uri.parse('https://wa.me/554933008629?text=Olá,%20preciso%20de%20ajuda%20com%20o%20aplicativo%20Play%20Viagens');
    try {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Não foi possível abrir o WhatsApp'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _makePhoneCall([String? number]) async {
    final phoneNumber = number ?? '+554933008629';
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      await launchUrl(launchUri);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Não foi possível fazer a ligação'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendEmail() async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: 'suporte@playviagens.org',
      query: 'subject=Suporte Play Viagens&body=Olá, preciso de ajuda com...',
    );
    try {
      await launchUrl(launchUri);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Não foi possível enviar e-mail'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => const FeedbackDialog(),
    );
  }

  void _rateApp() async {
    // URL da Play Store (Android)
    final Uri playStoreUri = Uri.parse('https://play.google.com/store/apps/details?id=com.playviagens.passageiro');
    
    try {
      await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⭐ Loja de aplicativos não disponível'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    }
  }


  void _showUsefulLinks() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UsefulLinksScreen(),
      ),
    );
  }
}

class SupportOption {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  SupportOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}

// FAQ Screen
class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<FAQItem> faqItems = [
      FAQItem(
        question: 'Como solicitar uma corrida?',
        answer: 'Abra o app, insira seu destino, escolha a categoria do veículo e confirme sua solicitação.',
      ),
      FAQItem(
        question: 'Como alterar o método de pagamento?',
        answer: 'Na tela de solicitação da corrida, toque em "Forma de Pagamento" e selecione sua preferência.',
      ),
      FAQItem(
        question: 'Posso cancelar uma corrida?',
        answer: 'Sim, você pode cancelar até o motorista chegar ao local de embarque.',
      ),
      FAQItem(
        question: 'Como avaliar minha viagem?',
        answer: 'Após cada corrida, você poderá avaliar o motorista e deixar comentários.',
      ),
      FAQItem(
        question: 'Meus dados estão seguros?',
        answer: 'Sim, utilizamos criptografia e seguimos as melhores práticas de segurança.',
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Perguntas Frequentes',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faqItems.length,
        itemBuilder: (context, index) {
          return _buildFAQItem(faqItems[index]);
        },
      ),
    );
  }

  Widget _buildFAQItem(FAQItem item) {
    return Card(
      color: const Color(0xFF2A2A2A),
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          item.question,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              item.answer,
              style: TextStyle(
                color: Colors.grey[300],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}

// Feedback Dialog
class FeedbackDialog extends StatefulWidget {
  const FeedbackDialog({super.key});

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  final _feedbackController = TextEditingController();
  int _rating = 5;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2A2A2A),
      title: const Text(
        'Enviar Feedback',
        style: TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Como foi sua experiência?',
            style: TextStyle(color: Colors.white),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => setState(() => _rating = index + 1),
                child: Icon(
                  Icons.star,
                  color: index < _rating ? Colors.amber : Colors.grey,
                  size: 32,
                ),
              );
            }),
          ),
          
          const SizedBox(height: 16),
          
          TextField(
            controller: _feedbackController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Conte-nos sua experiência...',
              hintStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(),
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
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('💌 Feedback enviado com sucesso!'),
                backgroundColor: AppTheme.primaryColor,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
          ),
          child: const Text(
            'Enviar',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }
}

// Privacy Policy Screen
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Política de Privacidade',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.security, color: AppTheme.primaryColor, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Sua privacidade é nossa prioridade',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '''POLÍTICA DE PRIVACIDADE – PLAY VIAGENS®

Última atualização: 15/08/2025

A Play Viagens®, por meio de sua associação vinculada Play Viagens – Associação de Mobilidade e Inclusão (CNPJ 61.805.518/0001-97), com sede na Rua Clóvis Cezar de Oliveira, 188 – Bairro Santa Cruz – Concórdia/SC – CEP 89.703-142, preza pela segurança, privacidade e transparência no tratamento dos dados dos seus usuários – motoristas, passageiros e licenciados.

Ao utilizar nossos serviços ou acessar nossas plataformas digitais, você aceita os termos desta Política de Privacidade.

1. A QUEM SE APLICA ESTA POLÍTICA

Esta política se aplica a todos os usuários da Play Viagens®, incluindo:
• Motoristas cadastrados na plataforma
• Passageiros que utilizam o aplicativo ou serviços de transporte
• Licenciados e parceiros regionais

2. QUAIS DADOS COLETAMOS

a) Dados pessoais:
• Nome completo, CPF/CNPJ, endereço, telefone, e-mail
• Dados bancários ou carteira digital (para pagamentos e repasses)
• Dados de CNH, veículo e documentos obrigatórios (motoristas)
• Informações de geolocalização (durante uso do app)
• Foto de perfil (motorista e passageiro)

b) Dados de uso da plataforma:
• Histórico de viagens, pagamentos e interações
• Avaliações, comunicações e reclamações
• Informações de dispositivo, IP e cookies

3. FINALIDADE DA COLETA

Utilizamos seus dados para:
• Operar e melhorar a plataforma de mobilidade
• Efetuar pagamentos e repasses
• Garantir a segurança de usuários e condutores
• Cumprir obrigações legais e regulatórias
• Enviar comunicações importantes e suporte
• Análise de desempenho para licenciados e parceiros

4. COMPARTILHAMENTO DE DADOS

A Play Viagens® não vende dados pessoais. Compartilhamos informações apenas quando necessário para:
• Processamento de pagamentos (ex: gateways como PagSeguro, InfinitePay)
• Cumprimento de obrigações legais ou judiciais
• Prestação de suporte técnico e operacional por parceiros autorizados
• Envio de informações por meio de WhatsApp (via API autorizada), e-mail ou notificação

5. ARMAZENAMENTO E SEGURANÇA

Seus dados são armazenados em ambiente seguro, com criptografia e acesso restrito. Aplicamos medidas técnicas e administrativas para prevenir vazamentos, acessos indevidos ou uso não autorizado.

6. DIREITOS DO USUÁRIO

Você tem direito a:
• Confirmar a existência de tratamento de dados
• Solicitar acesso, correção ou exclusão dos seus dados
• Revogar consentimento, nos termos da LGPD (Lei 13.709/2018)
• Solicitar a portabilidade de dados, quando aplicável

Para exercer seus direitos, entre em contato pelo e-mail: suporte@playviagens.org ou WhatsApp (49) 9 3300-8629.

7. COOKIES E TECNOLOGIAS DE RASTREAMENTO

Utilizamos cookies para personalizar sua experiência. Você pode gerenciar suas preferências diretamente no navegador.

8. ALTERAÇÕES NESTA POLÍTICA

Reservamo-nos o direito de alterar esta Política a qualquer momento. As alterações entrarão em vigor na data de sua publicação em nossos canais oficiais.

9. CONTATO

Play Viagens – Associação de Mobilidade e Inclusão
Rua Clóvis Cezar de Oliveira, 188 – Concórdia/SC
E-mail: suporte@playviagens.org
WhatsApp: (49) 9 3300-8629

© Play Viagens® – Marca registrada. Todos os direitos reservados.''',
              style: TextStyle(
                color: Colors.white,
                height: 1.6,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Terms of Use Screen
class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Termos de Uso',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.indigo.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.description, color: Colors.indigo, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Termos e condições de uso',
                      style: TextStyle(
                        color: Colors.indigo,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '''TERMOS DE USO - PLAY VIAGENS

Última atualização: Janeiro 2024

Bem-vindo ao Play Viagens. Estes Termos de Uso ("Termos") estabelecem as condições para uso do aplicativo e serviços da Play Viagens Tecnologia Ltda. ("Play Viagens", "nós", "nosso").

1. ACEITAÇÃO DOS TERMOS

1.1 Ao baixar, acessar ou usar o aplicativo Play Viagens, você concorda em cumprir estes Termos.

1.2 Se você não concordar com algum termo, não use nosso serviço.

1.3 Você deve ter pelo menos 18 anos para usar nossos serviços.

2. DESCRIÇÃO DOS SERVIÇOS

2.1 O Play Viagens é uma plataforma tecnológica que conecta:
• Passageiros que precisam de transporte
• Motoristas parceiros autônomos
• Empresas de transporte cadastradas

2.2 Serviços Oferecidos:
• Solicitação de corridas
• Processamento de pagamentos
• Sistema de avaliações
• Suporte ao cliente
• Geolocalização e navegação

2.3 O Play Viagens NÃO:
• Possui ou opera veículos
• Emprega motoristas
• Fornece serviços de transporte diretamente

3. CADASTRO E CONTA DE USUÁRIO

3.1 Requisitos para Cadastro:
• Ser maior de 18 anos
• Fornecer informações verdadeiras e atualizadas
• Possuir número de telefone válido
• Aceitar nossa Política de Privacidade

3.2 Responsabilidades do Usuário:
• Manter dados atualizados
• Proteger login e senha
• Não compartilhar conta com terceiros
• Notificar sobre uso não autorizado

4. SOLICITAÇÃO E USO DE CORRIDAS

4.1 Processo de Solicitação:
• Informe local de embarque e destino
• Escolha categoria de veículo
• Confirme método de pagamento
• Aguarde confirmação do motorista

4.2 Durante a Corrida:
• Esteja no local de embarque no horário combinado
• Trate o motorista com respeito
• Use cinto de segurança
• Não consuma álcool ou drogas no veículo
• Não fume no veículo

4.3 Cancelamentos:
• Cancelamentos gratuitos: até 5 minutos após solicitação
• Cancelamentos tardios: podem gerar cobrança
• Não comparecimento: pode gerar cobrança integral

5. PAGAMENTOS E PREÇOS

5.1 Métodos de Pagamento:
• Cartão de crédito/débito
• PIX
• Dinheiro (quando disponível)
• Carteira digital

5.2 Cobrança:
• Preços calculados por distância e tempo
• Podem aplicar-se taxas dinâmicas
• Taxas de cancelamento quando aplicáveis
• Todos os preços incluem impostos

5.3 Faturas e Recibos:
• Disponíveis no aplicativo
• Enviados por e-mail quando solicitado

6. COMPORTAMENTO E CONDUTA

6.1 Comportamento Esperado:
• Respeitar motoristas e outros usuários
• Ser pontual
• Manter o veículo limpo
• Seguir instruções de segurança

6.2 Comportamentos Proibidos:
• Assédio, discriminação ou violência
• Atividades ilegais
• Danos ao veículo
• Comportamento inadequado
• Uso do serviço para menores desacompanhados

7. SISTEMA DE AVALIAÇÕES

7.1 Você pode avaliar:
• Qualidade do serviço
• Pontualidade
• Limpeza do veículo
• Cortesia do motorista

7.2 Sua avaliação:
• Deve ser honesta e construtiva
• Pode ser vista pelo motorista
• Influencia na qualidade geral do serviço

8. LIMITAÇÃO DE RESPONSABILIDADE

8.1 O Play Viagens não se responsabiliza por:
• Acidentes durante o transporte
• Danos causados por motoristas parceiros
• Perda ou roubo de pertences
• Atrasos ou rotas escolhidas
• Problemas com o veículo

8.2 Seguro:
• Motoristas devem possuir seguro obrigatório
• Recomendamos verificar cobertura adicional
• Play Viagens não fornece seguro direto

9. PROPRIEDADE INTELECTUAL

9.1 O aplicativo e conteúdo são propriedade da Play Viagens

9.2 Você não pode:
• Copiar ou reproduzir o aplicativo
• Criar obras derivadas
• Usar marcas sem autorização
• Fazer engenharia reversa

10. PRIVACIDADE E DADOS

10.1 Consulte nossa Política de Privacidade para entender:
• Como coletamos dados
• Como usamos informações
• Seus direitos sobre dados pessoais

11. SUSPENSÃO E ENCERRAMENTO

11.1 Podemos suspender sua conta por:
• Violação destes Termos
• Comportamento inadequado
• Atividades fraudulentas
• Avaliações consistentemente baixas

11.2 Você pode encerrar sua conta a qualquer momento

12. ALTERAÇÕES NOS TERMOS

12.1 Podemos alterar estes Termos periodicamente

12.2 Notificaremos sobre mudanças através do aplicativo

12.3 Continuar usando o serviço significa aceitar as alterações

13. RESOLUÇÃO DE DISPUTAS

13.1 Para resolver problemas:
• Entre em contato com nosso suporte
• Tentamos resolver amigavelmente
• Foro da comarca de [Cidade da empresa]

14. LEGISLAÇÃO APLICÁVEL

14.1 Estes Termos são regidos pelas leis brasileiras

14.2 Código de Defesa do Consumidor aplicável quando relevante

15. DISPOSIÇÕES GERAIS

15.1 Se alguma cláusula for inválida, as demais permanecem válidas

15.2 Estes Termos constituem o acordo completo

16. CONTATO E SUPORTE

Para dúvidas sobre estes Termos:

Play Viagens Tecnologia Ltda.
CNPJ: XX.XXX.XXX/0001-XX
E-mail: juridico@playviagens.org
Suporte: suporte@playviagens.org
Telefone: (49) 9 3300-8629
WhatsApp: (49) 9 3300-8629

Endereço: [Endereço da empresa]

17. ATENDIMENTO AO CONSUMIDOR

Conforme Decreto 7.962/13:
• SAC disponível 24h por telefone e WhatsApp
• Resposta em até 5 dias úteis
• Procedimentos para reclamações no aplicativo

Obrigado por usar o Play Viagens!''',
              style: TextStyle(
                color: Colors.white,
                height: 1.6,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Useful Links Screen
class UsefulLinksScreen extends StatelessWidget {
  const UsefulLinksScreen({super.key});

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
          'Links Úteis',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PlayLogo(size: 60),
            const SizedBox(height: 32),
            
            // Terms of Use Card
            _buildLinkCard(
              context: context,
              icon: Icons.description,
              title: 'Termos de Uso',
              subtitle: 'Condições de uso do aplicativo',
              color: const Color(0xFF00FF00),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TermsOfUseScreen(),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Contact Support Card
            _buildLinkCard(
              context: context,
              icon: Icons.support_agent,
              title: 'Central de Suporte',
              subtitle: 'Entre em contato conosco',
              color: Colors.blue,
              onTap: () => Navigator.pop(context),
            ),
            
            const SizedBox(height: 16),
            
            // App Store Card
            _buildLinkCard(
              context: context,
              icon: Icons.star_rate,
              title: 'Avaliar Aplicativo',
              subtitle: 'Deixe sua avaliação na loja',
              color: Colors.amber,
              onTap: () => _rateApp(),
            ),
            
            const SizedBox(height: 32),
            
            const Text(
              'Precisa de mais ajuda?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 8),
            
            const Text(
              'Nossa equipe de suporte está disponível 24/7 para ajudá-lo.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _launchUrl('tel:+5511999999999'),
                    icon: const Icon(Icons.phone, color: Colors.white),
                    label: const Text(
                      'Ligar',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00FF00),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _launchUrl('mailto:suporte@playviagens.com'),
                    icon: const Icon(Icons.email, color: Colors.white),
                    label: const Text(
                      'E-mail',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLinkCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      color: const Color(0xFF2A2A2A),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
  
  void _rateApp() {
    // Platform-specific store URLs
    const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.playviagens.passageiro';
    
    // Open Play Store
    _launchUrl(playStoreUrl);
  }
  
  void _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}