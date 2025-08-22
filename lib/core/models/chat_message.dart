import 'package:json_annotation/json_annotation.dart';

part 'chat_message.g.dart';

@JsonSerializable()
class ChatMessage {
  final int id;
  @JsonKey(name: 'ride_id')
  final int rideId;
  @JsonKey(name: 'sender_id')
  final int senderId;
  @JsonKey(name: 'sender_type')
  final String senderType; // 'passenger' or 'driver'
  final String message;
  @JsonKey(name: 'is_automatic')
  final bool isAutomatic;
  @JsonKey(name: 'message_type')
  final String messageType; // 'text', 'location', 'quick_message'
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'read_at')
  final DateTime? readAt;

  ChatMessage({
    required this.id,
    required this.rideId,
    required this.senderId,
    required this.senderType,
    required this.message,
    this.isAutomatic = false,
    this.messageType = 'text',
    required this.createdAt,
    this.readAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);

  bool get isFromDriver => senderType == 'driver';
  bool get isFromPassenger => senderType == 'passenger';
  bool get isRead => readAt != null;

  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inMinutes < 1) {
      return 'Agora';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}min';
    } else if (difference.inDays < 1) {
      return '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
    } else {
      return '${createdAt.day}/${createdAt.month} ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
    }
  }

  ChatMessage copyWith({
    int? id,
    int? rideId,
    int? senderId,
    String? senderType,
    String? message,
    bool? isAutomatic,
    String? messageType,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      rideId: rideId ?? this.rideId,
      senderId: senderId ?? this.senderId,
      senderType: senderType ?? this.senderType,
      message: message ?? this.message,
      isAutomatic: isAutomatic ?? this.isAutomatic,
      messageType: messageType ?? this.messageType,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }
}