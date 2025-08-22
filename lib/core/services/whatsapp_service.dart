import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/whatsapp_message.dart';
import '../config/app_config.dart';

class WhatsAppService {
  static String get _baseUrl => AppConfig.baseUrl;
  
  // Singleton instance
  static final WhatsAppService _instance = WhatsAppService._internal();
  factory WhatsAppService() => _instance;
  WhatsAppService._internal();

  // Headers para requisições
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Busca o histórico de mensagens WhatsApp para um usuário
  Future<List<WhatsAppMessage>> getMessageHistory({
    int? userId,
    String? userType,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      if (userId != null) {
        queryParams['userId'] = userId.toString();
      }
      if (userType != null) {
        queryParams['userType'] = userType;
      }

      final uri = Uri.parse('$_baseUrl/api/whatsapp/history')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> messagesJson = data['messages'] ?? [];
        
        return messagesJson
            .map((messageJson) => WhatsAppMessage.fromJson(messageJson))
            .toList();
      } else {
        throw Exception('Erro ao buscar histórico: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro no WhatsApp Service - getMessageHistory: $e');
      throw Exception('Erro ao buscar histórico de mensagens: $e');
    }
  }

  /// Envia uma mensagem manual via WhatsApp
  Future<Map<String, dynamic>> sendManualMessage({
    required String phone,
    required String message,
    String? templateId,
  }) async {
    try {
      final body = {
        'phone': phone,
        'message': message,
        if (templateId != null) 'templateId': templateId,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/api/whatsapp/send-manual'),
        headers: _headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ao enviar mensagem: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro no WhatsApp Service - sendManualMessage: $e');
      throw Exception('Erro ao enviar mensagem: $e');
    }
  }

  /// Busca templates de mensagens
  Future<List<MessageTemplate>> getTemplates() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/whatsapp/templates'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> templatesJson = data['templates'] ?? [];
        
        return templatesJson
            .map((templateJson) => MessageTemplate.fromJson(templateJson))
            .toList();
      } else {
        throw Exception('Erro ao buscar templates: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro no WhatsApp Service - getTemplates: $e');
      throw Exception('Erro ao buscar templates: $e');
    }
  }

  /// Cria um novo template
  Future<MessageTemplate> createTemplate({
    required String name,
    required String content,
    required List<String> variables,
    required WhatsAppCategory category,
  }) async {
    try {
      final body = {
        'name': name,
        'content': content,
        'variables': variables,
        'category': category.name,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/api/whatsapp/templates'),
        headers: _headers,
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return MessageTemplate.fromJson(data['template']);
      } else {
        throw Exception('Erro ao criar template: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro no WhatsApp Service - createTemplate: $e');
      throw Exception('Erro ao criar template: $e');
    }
  }

  /// Busca estatísticas do WhatsApp
  Future<WhatsAppStats> getStats() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/whatsapp/stats'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WhatsAppStats.fromJson(data['stats']);
      } else {
        throw Exception('Erro ao buscar estatísticas: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro no WhatsApp Service - getStats: $e');
      throw Exception('Erro ao buscar estatísticas: $e');
    }
  }

  /// Envia notificação de corrida para passageiro
  Future<Map<String, dynamic>> sendRideNotification({
    required String phone,
    required String status,
    Map<String, dynamic>? rideDetails,
  }) async {
    try {
      final body = {
        'phone': phone,
        'status': status,
        if (rideDetails != null) 'rideDetails': rideDetails,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/api/whatsapp/ride-notification'),
        headers: _headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ao enviar notificação: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro no WhatsApp Service - sendRideNotification: $e');
      throw Exception('Erro ao enviar notificação: $e');
    }
  }

  /// Envia notificação para motorista
  Future<Map<String, dynamic>> sendDriverNotification({
    required String phone,
    required Map<String, dynamic> rideDetails,
  }) async {
    try {
      final body = {
        'phone': phone,
        'rideDetails': rideDetails,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/api/whatsapp/driver-notification'),
        headers: _headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ao enviar notificação: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro no WhatsApp Service - sendDriverNotification: $e');
      throw Exception('Erro ao enviar notificação: $e');
    }
  }

  /// Envia confirmação de pagamento
  Future<Map<String, dynamic>> sendPaymentConfirmation({
    required String phone,
    required Map<String, dynamic> paymentDetails,
  }) async {
    try {
      final body = {
        'phone': phone,
        'paymentDetails': paymentDetails,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/api/whatsapp/payment-confirmation'),
        headers: _headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ao enviar confirmação: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro no WhatsApp Service - sendPaymentConfirmation: $e');
      throw Exception('Erro ao enviar confirmação: $e');
    }
  }

  /// Formatar número de telefone brasileiro
  String formatPhoneNumber(String phone) {
    // Remove todos os caracteres não numéricos
    String cleaned = phone.replaceAll(RegExp(r'\D'), '');
    
    // Garantir que comece com o código do país (55)
    if (!cleaned.startsWith('55')) {
      cleaned = '55$cleaned';
    }
    
    // Garantir que números de celular tenham 9 dígitos após o DDD
    if (cleaned.length == 12 && !cleaned.substring(4, 5).contains('9')) {
      // Adiciona 9 após o DDD para números de celular
      cleaned = '${cleaned.substring(0, 4)}9${cleaned.substring(4)}';
    }
    
    return cleaned;
  }

  /// Valida se o número de telefone é válido
  bool isValidPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    
    // Deve ter pelo menos 10 dígitos (DDD + número)
    if (cleaned.length < 10) return false;
    
    // Com código do país, deve ter 13 dígitos
    if (cleaned.startsWith('55') && cleaned.length != 13) return false;
    
    return true;
  }

  /// Busca mensagens por filtros específicos
  Future<List<WhatsAppMessage>> searchMessages({
    String? query,
    WhatsAppStatus? status,
    WhatsAppMessageType? messageType,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      if (query != null && query.isNotEmpty) {
        queryParams['query'] = query;
      }
      if (status != null) {
        queryParams['status'] = status.name;
      }
      if (messageType != null) {
        queryParams['messageType'] = messageType.name;
      }
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final uri = Uri.parse('$_baseUrl/api/whatsapp/search')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> messagesJson = data['messages'] ?? [];
        
        return messagesJson
            .map((messageJson) => WhatsAppMessage.fromJson(messageJson))
            .toList();
      } else {
        throw Exception('Erro na busca: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro no WhatsApp Service - searchMessages: $e');
      throw Exception('Erro na busca de mensagens: $e');
    }
  }
}