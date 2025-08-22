import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../../../shared/widgets/play_logo.dart';
import '../../../shared/theme/app_theme.dart';

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  
  File? _profilePhoto;
  File? _idDocument;
  File? _addressProof;
  File? _phoneProof;
  
  bool _isUploading = false;
  
  final List<Map<String, dynamic>> _documentTypes = [
    {
      'title': 'Foto do Perfil',
      'description': 'Foto clara do seu rosto',
      'type': 'profile_photo',
      'required': true,
      'file': null,
    },
    {
      'title': 'Documento de Identidade',
      'description': 'RG, CNH ou Passaporte',
      'type': 'id_document',
      'required': true,
      'file': null,
    },
    {
      'title': 'Comprovante de Endereço',
      'description': 'Conta de luz, água ou telefone',
      'type': 'address_proof',
      'required': true,
      'file': null,
    },
    {
      'title': 'Comprovante de Telefone',
      'description': 'Fatura ou print do aplicativo',
      'type': 'phone_proof',
      'required': false,
      'file': null,
    },
  ];

  Future<void> _pickImage(String documentType) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      
      if (image != null) {
        setState(() {
          final file = File(image.path);
          
          switch (documentType) {
            case 'profile_photo':
              _profilePhoto = file;
              break;
            case 'id_document':
              _idDocument = file;
              break;
            case 'address_proof':
              _addressProof = file;
              break;
            case 'phone_proof':
              _phoneProof = file;
              break;
          }
          
          // Atualizar o arquivo na lista
          final index = _documentTypes.indexWhere((doc) => doc['type'] == documentType);
          if (index != -1) {
            _documentTypes[index]['file'] = file;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao capturar imagem'),
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
        maxWidth: 1920,
        maxHeight: 1080,
      );
      
      if (image != null) {
        setState(() {
          final file = File(image.path);
          
          switch (documentType) {
            case 'profile_photo':
              _profilePhoto = file;
              break;
            case 'id_document':
              _idDocument = file;
              break;
            case 'address_proof':
              _addressProof = file;
              break;
            case 'phone_proof':
              _phoneProof = file;
              break;
          }
          
          // Atualizar o arquivo na lista
          final index = _documentTypes.indexWhere((doc) => doc['type'] == documentType);
          if (index != -1) {
            _documentTypes[index]['file'] = file;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao selecionar imagem'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImagePickerOptions(String documentType) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Câmera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(documentType);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery(documentType);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancelar'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _fileToBase64(File file) async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  Future<void> _uploadDocuments() async {
    // Verificar se todos os documentos obrigatórios foram enviados
    final requiredDocs = _documentTypes.where((doc) => doc['required']).toList();
    final missingDocs = requiredDocs.where((doc) => doc['file'] == null).toList();
    
    if (missingDocs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Envie todos os documentos obrigatórios: ${missingDocs.map((doc) => doc['title']).join(', ')}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Converter arquivos para base64
      final documents = <String, String>{};
      
      for (final doc in _documentTypes) {
        if (doc['file'] != null) {
          final base64 = await _fileToBase64(doc['file']);
          documents[doc['type']] = 'data:image/jpeg;base64,$base64';
        }
      }

      // Simular upload para API
      await Future.delayed(const Duration(seconds: 3));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Documentos enviados com sucesso!'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
        
        // Navegar de volta
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao enviar documentos'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título e descrição
            const Text(
              'Documentos Necessários',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'Para usar o app, precisamos verificar alguns documentos. Tire fotos claras e bem iluminadas.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Lista de documentos
            ...(_documentTypes.map((doc) => _buildDocumentCard(doc)).toList()),
            
            const SizedBox(height: 32),
            
            // Informações de segurança
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.security, color: Colors.blue[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Seus documentos são criptografados e armazenados com segurança. Usamos apenas para verificação de identidade.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Botão de enviar
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _uploadDocuments,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isUploading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Enviando...',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'Enviar Documentos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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

  Widget _buildDocumentCard(Map<String, dynamic> doc) {
    final hasFile = doc['file'] != null;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: hasFile ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
        border: Border.all(
          color: hasFile ? AppTheme.primaryColor : Colors.grey[300]!,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          doc['title'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: hasFile ? AppTheme.primaryColor : Colors.black,
                          ),
                        ),
                        if (doc['required'])
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Obrigatório',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doc['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (hasFile)
                Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryColor,
                  size: 32,
                )
              else
                Icon(
                  Icons.camera_alt,
                  color: Colors.grey[400],
                  size: 32,
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          if (hasFile) ...[
            // Preview da imagem
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  doc['file'],
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showImagePickerOptions(doc['type']),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: BorderSide(color: AppTheme.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Alterar Foto'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        doc['file'] = null;
                        switch (doc['type']) {
                          case 'profile_photo':
                            _profilePhoto = null;
                            break;
                          case 'id_document':
                            _idDocument = null;
                            break;
                          case 'address_proof':
                            _addressProof = null;
                            break;
                          case 'phone_proof':
                            _phoneProof = null;
                            break;
                        }
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Remover'),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Botão para adicionar foto
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _showImagePickerOptions(doc['type']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.add_a_photo),
                label: const Text('Adicionar Foto'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}