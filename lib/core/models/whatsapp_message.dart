
class WhatsAppMessage {
  final String id;
  final String phone;
  final String message;
  final WhatsAppStatus status;
  final DateTime sentAt;
  final String? userName;
  final String userType;
  final WhatsAppMessageType messageType;
  final String? zaapId;
  final String? messageId;
  final String? category;

  WhatsAppMessage({
    required this.id,
    required this.phone,
    required this.message,
    required this.status,
    required this.sentAt,
    this.userName,
    required this.userType,
    required this.messageType,
    this.zaapId,
    this.messageId,
    this.category,
  });

  factory WhatsAppMessage.fromJson(Map<String, dynamic> json) {
    return WhatsAppMessage(
      id: json['id'] as String,
      phone: json['phone'] as String,
      message: json['message'] as String,
      status: WhatsAppStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => WhatsAppStatus.sent,
      ),
      sentAt: DateTime.parse(json['sentAt'] as String),
      userName: json['userName'] as String?,
      userType: json['userType'] as String,
      messageType: WhatsAppMessageType.values.firstWhere(
        (e) => e.name == json['messageType'],
        orElse: () => WhatsAppMessageType.automatic,
      ),
      zaapId: json['zaapId'] as String?,
      messageId: json['messageId'] as String?,
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'message': message,
      'status': status.name,
      'sentAt': sentAt.toIso8601String(),
      'userName': userName,
      'userType': userType,
      'messageType': messageType.name,
      'zaapId': zaapId,
      'messageId': messageId,
      'category': category,
    };
  }

  WhatsAppMessage copyWith({
    String? id,
    String? phone,
    String? message,
    WhatsAppStatus? status,
    DateTime? sentAt,
    String? userName,
    String? userType,
    WhatsAppMessageType? messageType,
    String? zaapId,
    String? messageId,
    String? category,
  }) {
    return WhatsAppMessage(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      message: message ?? this.message,
      status: status ?? this.status,
      sentAt: sentAt ?? this.sentAt,
      userName: userName ?? this.userName,
      userType: userType ?? this.userType,
      messageType: messageType ?? this.messageType,
      zaapId: zaapId ?? this.zaapId,
      messageId: messageId ?? this.messageId,
      category: category ?? this.category,
    );
  }
}

class MessageTemplate {
  final String id;
  final String name;
  final String content;
  final List<String> variables;
  final WhatsAppCategory category;

  MessageTemplate({
    required this.id,
    required this.name,
    required this.content,
    required this.variables,
    required this.category,
  });

  factory MessageTemplate.fromJson(Map<String, dynamic> json) {
    return MessageTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      content: json['content'] as String,
      variables: (json['variables'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      category: WhatsAppCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => WhatsAppCategory.support,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'content': content,
      'variables': variables,
      'category': category.name,
    };
  }
}

class WhatsAppStats {
  final int totalMessages;
  final int sentToday;
  final int deliveredToday;
  final int failedToday;
  final Map<String, int> messagesByType;
  final Map<String, int> messagesByStatus;

  WhatsAppStats({
    required this.totalMessages,
    required this.sentToday,
    required this.deliveredToday,
    required this.failedToday,
    required this.messagesByType,
    required this.messagesByStatus,
  });

  factory WhatsAppStats.fromJson(Map<String, dynamic> json) {
    return WhatsAppStats(
      totalMessages: json['totalMessages'] as int,
      sentToday: json['sentToday'] as int,
      deliveredToday: json['deliveredToday'] as int,
      failedToday: json['failedToday'] as int,
      messagesByType: Map<String, int>.from(json['messagesByType'] as Map),
      messagesByStatus: Map<String, int>.from(json['messagesByStatus'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalMessages': totalMessages,
      'sentToday': sentToday,
      'deliveredToday': deliveredToday,
      'failedToday': failedToday,
      'messagesByType': messagesByType,
      'messagesByStatus': messagesByStatus,
    };
  }
}

enum WhatsAppStatus {
  sent,
  delivered,
  read,
  failed
}

enum WhatsAppMessageType {
  manual,
  automatic
}

enum WhatsAppCategory {
  ride,
  payment,
  support,
  marketing
}

extension WhatsAppStatusExtension on WhatsAppStatus {
  String get displayName {
    switch (this) {
      case WhatsAppStatus.sent:
        return 'Enviado';
      case WhatsAppStatus.delivered:
        return 'Entregue';
      case WhatsAppStatus.read:
        return 'Lido';
      case WhatsAppStatus.failed:
        return 'Falhou';
    }
  }

  String get emoji {
    switch (this) {
      case WhatsAppStatus.sent:
        return '📤';
      case WhatsAppStatus.delivered:
        return '✅';
      case WhatsAppStatus.read:
        return '👁️';
      case WhatsAppStatus.failed:
        return '❌';
    }
  }
}

extension WhatsAppMessageTypeExtension on WhatsAppMessageType {
  String get displayName {
    switch (this) {
      case WhatsAppMessageType.manual:
        return 'Manual';
      case WhatsAppMessageType.automatic:
        return 'Automático';
    }
  }
}

extension WhatsAppCategoryExtension on WhatsAppCategory {
  String get displayName {
    switch (this) {
      case WhatsAppCategory.ride:
        return 'Corrida';
      case WhatsAppCategory.payment:
        return 'Pagamento';
      case WhatsAppCategory.support:
        return 'Suporte';
      case WhatsAppCategory.marketing:
        return 'Marketing';
    }
  }

  String get emoji {
    switch (this) {
      case WhatsAppCategory.ride:
        return '🚗';
      case WhatsAppCategory.payment:
        return '💳';
      case WhatsAppCategory.support:
        return '🛠️';
      case WhatsAppCategory.marketing:
        return '📢';
    }
  }
}