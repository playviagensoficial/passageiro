import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/constants/privacy_policy.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: Container(
        color: Colors.black,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and last updated
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.policy,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Play Viagens®',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      PrivacyPolicyContent.lastUpdated,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Privacy policy content
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  PrivacyPolicyContent.content,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Contact information
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.contact_support,
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Canais de Contato',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Email contact
                    GestureDetector(
                      onTap: () => _launchEmail(),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.email,
                                color: Colors.blue,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'E-mail',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    PrivacyPolicyContent.contactEmail,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
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
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // WhatsApp contact
                    GestureDetector(
                      onTap: () => _launchWhatsApp(),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.chat,
                                color: Colors.green,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'WhatsApp',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    PrivacyPolicyContent.contactWhatsApp,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
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
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Address
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.orange,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Endereço',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  PrivacyPolicyContent.companyAddress,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // LGPD compliance badge
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified_user,
                      color: Colors.blue,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Esta política está em conformidade com a Lei Geral de Proteção de Dados (LGPD) e demais normas aplicáveis.',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: PrivacyPolicyContent.contactEmail,
      query: 'subject=Contato sobre Política de Privacidade - Play Viagens',
    );
    
    try {
      await launchUrl(emailUri);
    } catch (e) {
      // Handle error silently or show snackbar
    }
  }

  void _launchWhatsApp() async {
    final String phoneNumber = PrivacyPolicyContent.contactWhatsApp.replaceAll(RegExp(r'[^0-9]'), '');
    final Uri whatsappUri = Uri.parse('https://wa.me/55$phoneNumber?text=Olá! Tenho uma dúvida sobre a Política de Privacidade da Play Viagens.');
    
    try {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      // Handle error silently or show snackbar
    }
  }
}