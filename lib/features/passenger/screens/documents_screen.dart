import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:convert';
import '../../auth/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  bool _isLoading = true;
  
  // Document status tracking with file paths
  Map<String, DocumentInfo> _documents = {
    'rg': DocumentInfo(status: DocumentStatus.pending, displayName: 'Documento de Identidade (RG)'),
    'cpf': DocumentInfo(status: DocumentStatus.pending, displayName: 'CPF'),
    'comprovante_residencia': DocumentInfo(status: DocumentStatus.pending, displayName: 'Comprovante de Residência'),
    'selfie': DocumentInfo(status: DocumentStatus.pending, displayName: 'Selfie com Documento'),
  };

  @override
  void initState() {
    super.initState();
    _loadDocumentStatus();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
            'Meus Documentos',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF00FF00)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, _allDocumentsApproved()),
        ),
        title: const Text(
          'Meus Documentos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF00FF00)),
            onPressed: _loadDocumentStatus,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
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
                border: Border.all(color: const Color(0xFF00FF00).withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.security,
                    color: Color(0xFF00FF00),
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Verificação de Identidade',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Para sua segurança e de outros usuários, precisamos verificar sua identidade.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  _buildVerificationProgress(),
                ],
              ),
            ),

            const SizedBox(height: 32),

            const Text(
              'Documentos Necessários',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),

            // Document Cards
            _buildDocumentCard(
              'rg',
              'Documento de Identidade (RG)',
              'Envie uma foto clara do seu RG',
              Icons.credit_card,
              _documents['rg']!,
            ),

            _buildDocumentCard(
              'cpf',
              'CPF',
              'Foto do seu CPF ou comprovante da Receita Federal',
              Icons.assignment_ind,
              _documents['cpf']!,
            ),

            _buildDocumentCard(
              'comprovante_residencia',
              'Comprovante de Residência',
              'Conta de luz, água ou telefone dos últimos 3 meses',
              Icons.home,
              _documents['comprovante_residencia']!,
            ),

            _buildDocumentCard(
              'selfie',
              'Selfie com Documento',
              'Tire uma selfie segurando seu RG ao lado do rosto',
              Icons.camera_alt,
              _documents['selfie']!,
            ),

            const SizedBox(height: 32),

            // Tips Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: Colors.blue, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Dicas para fotos perfeitas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTip('✓ Use boa iluminação, evite sombras'),
                  _buildTip('✓ Mantenha o documento plano e sem dobras'),
                  _buildTip('✓ Certifique-se que o texto está legível'),
                  _buildTip('✓ Tire a foto de frente, sem inclinação'),
                  _buildTip('✓ Use fundo neutro e liso'),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Submit Button
            if (_allDocumentsUploaded())
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _submitDocuments,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FF00),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isUploading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Enviando documentos...',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      : const Text(
                          'Enviar para Verificação',
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
    );
  }

  Widget _buildVerificationProgress() {
    final completedDocs = _documents.values.where((doc) => 
        doc.status == DocumentStatus.approved || doc.status == DocumentStatus.uploaded).length;
    final totalDocs = _documents.length;
    final progress = completedDocs / totalDocs;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Progresso',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(
              '$completedDocs/$totalDocs documentos',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade700,
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00FF00)),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildDocumentCard(String documentId, String title, String description, 
      IconData icon, DocumentInfo document) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDocumentOptions(documentId, title),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _getStatusColor(document.status).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getStatusColor(document.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: _getStatusColor(document.status), size: 24),
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
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildStatusChip(document.status),
                          if (document.status != DocumentStatus.pending) ...[
                            const SizedBox(width: 8),
                            _buildActionButtons(documentId, document),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  document.status == DocumentStatus.approved 
                      ? Icons.check_circle 
                      : document.status == DocumentStatus.rejected 
                          ? Icons.error 
                          : Icons.camera_alt,
                  color: document.status == DocumentStatus.approved 
                      ? const Color(0xFF00FF00) 
                      : document.status == DocumentStatus.rejected 
                          ? Colors.red 
                          : Colors.grey,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(DocumentStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusText(status),
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        tip,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
      ),
    );
  }

  Color _getStatusColor(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.pending:
        return Colors.grey;
      case DocumentStatus.uploaded:
        return Colors.orange;
      case DocumentStatus.approved:
        return const Color(0xFF00FF00);
      case DocumentStatus.rejected:
        return Colors.red;
    }
  }

  String _getStatusText(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.pending:
        return 'Pendente';
      case DocumentStatus.uploaded:
        return 'Enviado';
      case DocumentStatus.approved:
        return 'Aprovado';
      case DocumentStatus.rejected:
        return 'Rejeitado';
    }
  }

  bool _allDocumentsUploaded() {
    return _documents.values.every((doc) => 
        doc.status == DocumentStatus.uploaded || doc.status == DocumentStatus.approved);
  }

  bool _allDocumentsApproved() {
    return _documents.values.every((doc) => doc.status == DocumentStatus.approved);
  }

  Future<void> _loadDocumentStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = context.read<AuthProvider>().currentUser;
      if (user == null) return;

      // Call backend to get document status
      final response = await ApiService.get('/passenger/documents/${user.id}');
      
      if (response['success']) {
        final documentsData = response['data'] as Map<String, dynamic>;
        setState(() {
          _documents.forEach((key, document) {
            if (documentsData.containsKey(key)) {
              final docData = documentsData[key];
              document.status = _parseDocumentStatus(docData['status']);
              document.filePath = docData['file_path'];
              document.uploadedAt = docData['uploaded_at'] != null 
                  ? DateTime.parse(docData['uploaded_at']) 
                  : null;
              document.rejectionReason = docData['rejection_reason'];
            }
          });
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar status dos documentos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  DocumentStatus _parseDocumentStatus(String? status) {
    switch (status) {
      case 'uploaded':
        return DocumentStatus.uploaded;
      case 'approved':
        return DocumentStatus.approved;
      case 'rejected':
        return DocumentStatus.rejected;
      default:
        return DocumentStatus.pending;
    }
  }

  Widget _buildActionButtons(String documentId, DocumentInfo document) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (document.status == DocumentStatus.uploaded || document.status == DocumentStatus.rejected) ...[
          // Replace button
          InkWell(
            onTap: () => _showDocumentOptions(documentId, document.displayName),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit, color: Colors.orange, size: 12),
                  SizedBox(width: 4),
                  Text(
                    'Editar',
                    style: TextStyle(color: Colors.orange, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Remove button
          InkWell(
            onTap: () => _removeDocument(documentId),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 12),
                  SizedBox(width: 4),
                  Text(
                    'Remover',
                    style: TextStyle(color: Colors.red, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _removeDocument(String documentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Remover Documento', style: TextStyle(color: Colors.white)),
        content: Text(
          'Tem certeza que deseja remover o documento "${_documents[documentId]?.displayName}"?',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remover', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isUploading = true;
      });

      try {
        final user = context.read<AuthProvider>().currentUser;
        if (user == null) return;

        final response = await ApiService.delete('/passenger/documents/${user.id}/$documentId');
        
        if (response['success']) {
          setState(() {
            _documents[documentId]?.status = DocumentStatus.pending;
            _documents[documentId]?.filePath = null;
            _documents[documentId]?.uploadedAt = null;
            _documents[documentId]?.rejectionReason = null;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Documento removido com sucesso!'),
              backgroundColor: Color(0xFF00FF00),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao remover documento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _showDocumentOptions(String documentId, String title) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildOptionButton(
                          Icons.camera_alt,
                          'Câmera',
                          () {
                            Navigator.pop(context);
                            _takePicture(documentId, ImageSource.camera);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildOptionButton(
                          Icons.photo_library,
                          'Galeria',
                          () {
                            Navigator.pop(context);
                            _takePicture(documentId, ImageSource.gallery);
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(IconData icon, String label, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2A2A2A),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF00FF00)),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: const Color(0xFF00FF00)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<void> _takePicture(String documentId, ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null) {
        await _uploadDocument(documentId, photo);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao capturar imagem: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadDocument(String documentId, XFile photo) async {
    setState(() {
      _isUploading = true;
    });

    try {
      final user = context.read<AuthProvider>().currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      // Convert image to base64
      final bytes = await photo.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Upload to backend with validation
      final response = await ApiService.post('/passenger/documents/${user.id}/$documentId', {
        'document_type': documentId,
        'image_data': 'data:image/jpeg;base64,$base64Image',
        'file_name': photo.name,
      });

      if (response['success']) {
        setState(() {
          _documents[documentId]?.status = DocumentStatus.uploaded;
          _documents[documentId]?.filePath = response['data']['file_path'];
          _documents[documentId]?.uploadedAt = DateTime.now();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Documento enviado e validado com sucesso!'),
            backgroundColor: Color(0xFF00FF00),
          ),
        );

        // Auto-validate if all documents are uploaded
        if (_allDocumentsUploaded()) {
          await _submitDocuments();
        }
      } else {
        throw Exception(response['message'] ?? 'Erro ao validar documento');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar documento: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _submitDocuments() async {
    setState(() {
      _isUploading = true;
    });

    try {
      final user = context.read<AuthProvider>().currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      // Submit all documents to admin module for validation
      final response = await ApiService.post('/admin/validate-documents/${user.id}', {
        'documents': _documents.map((key, doc) => MapEntry(key, {
          'status': doc.status.toString().split('.').last,
          'file_path': doc.filePath,
          'uploaded_at': doc.uploadedAt?.toIso8601String(),
        })),
      });

      if (response['success']) {
        setState(() {
          _documents.updateAll((key, doc) {
            doc.status = DocumentStatus.uploaded; // Waiting for admin approval
            return doc;
          });
        });

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            title: const Text(
              '🎉 Documentos Enviados para Validação!',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Seus documentos foram enviados para o módulo administrativo e salvos no banco de dados de produção. '
              'Você receberá uma notificação em até 24 horas sobre a aprovação.',
              style: TextStyle(color: Colors.grey),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, true); // Return true to indicate success
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FF00),
                ),
                child: const Text(
                  'Entendi',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      } else {
        throw Exception(response['message'] ?? 'Erro na validação administrativa');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar para validação: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }
}

enum DocumentStatus {
  pending,
  uploaded,
  approved,
  rejected,
}

class DocumentInfo {
  DocumentStatus status;
  String displayName;
  String? filePath;
  DateTime? uploadedAt;
  String? rejectionReason;

  DocumentInfo({
    required this.status,
    required this.displayName,
    this.filePath,
    this.uploadedAt,
    this.rejectionReason,
  });
}