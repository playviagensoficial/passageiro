import 'package:flutter/material.dart';
import '../../../core/models/whatsapp_message.dart';
import '../../../core/services/whatsapp_service.dart';

class WhatsAppProvider with ChangeNotifier {
  final WhatsAppService _whatsAppService = WhatsAppService();

  // Estado das mensagens
  List<WhatsAppMessage> _messages = [];
  List<WhatsAppMessage> get messages => _messages;

  // Estado dos templates
  List<MessageTemplate> _templates = [];
  List<MessageTemplate> get templates => _templates;

  // Estado das estatísticas
  WhatsAppStats? _stats;
  WhatsAppStats? get stats => _stats;

  // Estado de carregamento
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Estado de erro
  String? _error;
  String? get error => _error;

  // Filtros de busca
  String? _searchQuery;
  WhatsAppStatus? _statusFilter;
  WhatsAppMessageType? _messageTypeFilter;
  DateTime? _startDateFilter;
  DateTime? _endDateFilter;

  // Getters para os filtros
  String? get searchQuery => _searchQuery;
  WhatsAppStatus? get statusFilter => _statusFilter;
  WhatsAppMessageType? get messageTypeFilter => _messageTypeFilter;
  DateTime? get startDateFilter => _startDateFilter;
  DateTime? get endDateFilter => _endDateFilter;

  // Paginação
  int _currentPage = 0;
  bool _hasMoreMessages = true;
  bool get hasMoreMessages => _hasMoreMessages;

  /// Inicializa o provider carregando dados iniciais
  Future<void> initialize({int? userId, String? userType}) async {
    await loadMessageHistory(userId: userId, userType: userType);
    await loadTemplates();
    await loadStats();
  }

  /// Carrega o histórico de mensagens
  Future<void> loadMessageHistory({
    int? userId,
    String? userType,
    bool refresh = false,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      if (refresh) {
        _currentPage = 0;
        _messages.clear();
        _hasMoreMessages = true;
      }

      final newMessages = await _whatsAppService.getMessageHistory(
        userId: userId,
        userType: userType,
        limit: 20,
        offset: _currentPage * 20,
      );

      if (refresh) {
        _messages = newMessages;
      } else {
        _messages.addAll(newMessages);
      }

      _hasMoreMessages = newMessages.length == 20;
      _currentPage++;

      notifyListeners();
    } catch (e) {
      _setError('Erro ao carregar mensagens: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Carrega mais mensagens (paginação)
  Future<void> loadMoreMessages({int? userId, String? userType}) async {
    if (!_hasMoreMessages || _isLoading) return;

    await loadMessageHistory(
      userId: userId,
      userType: userType,
      refresh: false,
    );
  }

  /// Busca mensagens com filtros
  Future<void> searchMessages({
    String? query,
    WhatsAppStatus? status,
    WhatsAppMessageType? messageType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      // Atualiza os filtros
      _searchQuery = query;
      _statusFilter = status;
      _messageTypeFilter = messageType;
      _startDateFilter = startDate;
      _endDateFilter = endDate;

      final searchResults = await _whatsAppService.searchMessages(
        query: query,
        status: status,
        messageType: messageType,
        startDate: startDate,
        endDate: endDate,
        limit: 50,
      );

      _messages = searchResults;
      _currentPage = 0;
      _hasMoreMessages = false; // Não paginar resultados de busca

      notifyListeners();
    } catch (e) {
      _setError('Erro na busca: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Limpa os filtros de busca
  Future<void> clearFilters({int? userId, String? userType}) async {
    _searchQuery = null;
    _statusFilter = null;
    _messageTypeFilter = null;
    _startDateFilter = null;
    _endDateFilter = null;

    await loadMessageHistory(userId: userId, userType: userType, refresh: true);
  }

  /// Envia uma mensagem manual
  Future<bool> sendManualMessage({
    required String phone,
    required String message,
    String? templateId,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final result = await _whatsAppService.sendManualMessage(
        phone: phone,
        message: message,
        templateId: templateId,
      );

      // Recarrega as mensagens para mostrar a nova mensagem
      await loadMessageHistory(refresh: true);

      return result['success'] ?? false;
    } catch (e) {
      _setError('Erro ao enviar mensagem: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Carrega os templates de mensagens
  Future<void> loadTemplates() async {
    try {
      final templates = await _whatsAppService.getTemplates();
      _templates = templates;
      notifyListeners();
    } catch (e) {
      _setError('Erro ao carregar templates: $e');
    }
  }

  /// Cria um novo template
  Future<bool> createTemplate({
    required String name,
    required String content,
    required List<String> variables,
    required WhatsAppCategory category,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final newTemplate = await _whatsAppService.createTemplate(
        name: name,
        content: content,
        variables: variables,
        category: category,
      );

      _templates.add(newTemplate);
      notifyListeners();

      return true;
    } catch (e) {
      _setError('Erro ao criar template: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Carrega as estatísticas
  Future<void> loadStats() async {
    try {
      final stats = await _whatsAppService.getStats();
      _stats = stats;
      notifyListeners();
    } catch (e) {
      _setError('Erro ao carregar estatísticas: $e');
    }
  }

  /// Envia notificação de corrida
  Future<bool> sendRideNotification({
    required String phone,
    required String status,
    Map<String, dynamic>? rideDetails,
  }) async {
    try {
      final result = await _whatsAppService.sendRideNotification(
        phone: phone,
        status: status,
        rideDetails: rideDetails,
      );

      return result['success'] ?? false;
    } catch (e) {
      _setError('Erro ao enviar notificação: $e');
      return false;
    }
  }

  /// Envia notificação para motorista
  Future<bool> sendDriverNotification({
    required String phone,
    required Map<String, dynamic> rideDetails,
  }) async {
    try {
      final result = await _whatsAppService.sendDriverNotification(
        phone: phone,
        rideDetails: rideDetails,
      );

      return result['success'] ?? false;
    } catch (e) {
      _setError('Erro ao enviar notificação: $e');
      return false;
    }
  }

  /// Envia confirmação de pagamento
  Future<bool> sendPaymentConfirmation({
    required String phone,
    required Map<String, dynamic> paymentDetails,
  }) async {
    try {
      final result = await _whatsAppService.sendPaymentConfirmation(
        phone: phone,
        paymentDetails: paymentDetails,
      );

      return result['success'] ?? false;
    } catch (e) {
      _setError('Erro ao enviar confirmação: $e');
      return false;
    }
  }

  /// Formata número de telefone
  String formatPhoneNumber(String phone) {
    return _whatsAppService.formatPhoneNumber(phone);
  }

  /// Valida número de telefone
  bool isValidPhoneNumber(String phone) {
    return _whatsAppService.isValidPhoneNumber(phone);
  }

  /// Filtra mensagens por status
  List<WhatsAppMessage> getMessagesByStatus(WhatsAppStatus status) {
    return _messages.where((message) => message.status == status).toList();
  }

  /// Filtra mensagens por tipo
  List<WhatsAppMessage> getMessagesByType(WhatsAppMessageType type) {
    return _messages.where((message) => message.messageType == type).toList();
  }

  /// Filtra templates por categoria
  List<MessageTemplate> getTemplatesByCategory(WhatsAppCategory category) {
    return _templates.where((template) => template.category == category).toList();
  }

  /// Obtém mensagens do dia atual
  List<WhatsAppMessage> getTodayMessages() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _messages.where((message) {
      return message.sentAt.isAfter(startOfDay) && 
             message.sentAt.isBefore(endOfDay);
    }).toList();
  }

  /// Obtém estatísticas rápidas
  Map<String, int> getQuickStats() {
    final todayMessages = getTodayMessages();
    
    return {
      'total': _messages.length,
      'today': todayMessages.length,
      'sent': getMessagesByStatus(WhatsAppStatus.sent).length,
      'delivered': getMessagesByStatus(WhatsAppStatus.delivered).length,
      'read': getMessagesByStatus(WhatsAppStatus.read).length,
      'failed': getMessagesByStatus(WhatsAppStatus.failed).length,
      'manual': getMessagesByType(WhatsAppMessageType.manual).length,
      'automatic': getMessagesByType(WhatsAppMessageType.automatic).length,
    };
  }

  /// Métodos auxiliares privados
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Limpa o estado de erro
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reset completo do provider
  void reset() {
    _messages.clear();
    _templates.clear();
    _stats = null;
    _isLoading = false;
    _error = null;
    _searchQuery = null;
    _statusFilter = null;
    _messageTypeFilter = null;
    _startDateFilter = null;
    _endDateFilter = null;
    _currentPage = 0;
    _hasMoreMessages = true;
    notifyListeners();
  }
}