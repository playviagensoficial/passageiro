import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../shared/widgets/play_logo.dart';
import '../../../shared/theme/app_theme.dart';

class PassengerDocumentsScreen extends StatefulWidget {
  const PassengerDocumentsScreen({super.key});

  @override
  State<PassengerDocumentsScreen> createState() => _PassengerDocumentsScreenState();
}

class _PassengerDocumentsScreenState extends State<PassengerDocumentsScreen> {
  final ImagePicker _picker = ImagePicker();
  
  // Document statuses
  Map<String, DocumentStatus> _documents = {
    'profile_photo': DocumentStatus(),
    'cpf': DocumentStatus(),
    'rg': DocumentStatus(),
    'proof_of_residence': DocumentStatus(),
    'selfie': DocumentStatus(),
  };

  Future<void> _pickDocument(String documentType) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _documents[documentType] = DocumentStatus(
            filePath: image.path,
            status: 'pending',
            uploadedAt: DateTime.now(),
          );
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📸 ${_getDocumentName(documentType)} capturado com sucesso!'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro ao capturar documento: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickFromGallery(String documentType) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _documents[documentType] = DocumentStatus(
            filePath: image.path,
            status: 'pending',
            uploadedAt: DateTime.now(),
          );
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📁 ${_getDocumentName(documentType)} selecionado com sucesso!'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro ao selecionar documento: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getDocumentName(String documentType) {
    switch (documentType) {
      case 'profile_photo':
        return 'Foto de Perfil';
      case 'cpf':
        return 'CPF';
      case 'rg':
        return 'RG';
      case 'proof_of_residence':
        return 'Comprovante de Residência';
      case 'selfie':
        return 'Selfie';
      default:
        return 'Documento';
    }
  }

  String _getDocumentDescription(String documentType) {
    switch (documentType) {
      case 'profile_photo':
        return 'Foto clara do rosto para identificação';
      case 'cpf':
        return 'Frente do documento CPF';
      case 'rg':
        return 'Frente e verso do RG';
      case 'proof_of_residence':
        return 'Conta de luz, água ou telefone recente';
      case 'selfie':
        return 'Selfie segurando o documento RG';
      default:
        return '';
    }
  }

  IconData _getDocumentIcon(String documentType) {
    switch (documentType) {
      case 'profile_photo':
        return Icons.account_circle;
      case 'cpf':
        return Icons.credit_card;
      case 'rg':
        return Icons.badge;
      case 'proof_of_residence':
        return Icons.home;
      case 'selfie':
        return Icons.camera_alt;
      default:
        return Icons.description;
    }
  }

  void _showDocumentOptions(String documentType) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF2A2A2A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      _getDocumentName(documentType),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      _getDocumentDescription(documentType),
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _pickDocument(documentType);
                            },
                            icon: const Icon(Icons.camera_alt, color: Colors.black),
                            label: const Text(
                              'Câmera',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              padding: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _pickFromGallery(documentType);
                            },
                            icon: const Icon(Icons.photo_library, color: Colors.white),
                            label: const Text(
                              'Galeria',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[700],
                              padding: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
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
              'Documentos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Adicione seus documentos para validação',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Lista de documentos
            ...(_documents.keys.map((documentType) {
              return _buildDocumentItem(documentType, _documents[documentType]!);
            }).toList()),
            
            const SizedBox(height: 32),
            
            // Informações importantes
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[300]),
                      const SizedBox(width: 8),
                      Text(
                        'Informações Importantes',
                        style: TextStyle(
                          color: Colors.blue[300],
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  const Text(
                    '• Documentos devem estar legíveis e atualizados\n• Fotos devem ser nítidas e sem cortes\n• O processo de verificação pode levar até 24 horas\n• Mantenha seus dados sempre atualizados',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.5,
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

  Widget _buildDocumentItem(String documentType, DocumentStatus documentStatus) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: documentStatus.hasFile ? AppTheme.primaryColor : Colors.white,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Ícone do documento
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: documentStatus.hasFile 
                  ? AppTheme.primaryColor.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getDocumentIcon(documentType),
              color: documentStatus.hasFile ? AppTheme.primaryColor : Colors.grey,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Informações do documento
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getDocumentName(documentType),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  documentStatus.hasFile 
                      ? 'Documento enviado'
                      : _getDocumentDescription(documentType),
                  style: TextStyle(
                    color: documentStatus.hasFile ? AppTheme.primaryColor : Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
                
                if (documentStatus.hasFile) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(documentStatus.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(documentStatus.status),
                      style: TextStyle(
                        color: _getStatusColor(documentStatus.status),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Botão de ação
          GestureDetector(
            onTap: () => _showDocumentOptions(documentType),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: documentStatus.hasFile 
                    ? AppTheme.primaryColor.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: documentStatus.hasFile 
                    ? null 
                    : Border.all(color: AppTheme.primaryColor),
              ),
              child: Icon(
                documentStatus.hasFile ? Icons.edit : Icons.add,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'approved':
        return 'Aprovado';
      case 'rejected':
        return 'Rejeitado';
      case 'pending':
        return 'Em análise';
      default:
        return 'Não enviado';
    }
  }
}

class DocumentStatus {
  final String? filePath;
  final String status; // 'pending', 'approved', 'rejected', 'not_sent'
  final DateTime? uploadedAt;

  DocumentStatus({
    this.filePath,
    this.status = 'not_sent',
    this.uploadedAt,
  });

  bool get hasFile => filePath != null && filePath!.isNotEmpty;
}