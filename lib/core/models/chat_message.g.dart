// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => ChatMessage(
  id: (json['id'] as num).toInt(),
  rideId: (json['ride_id'] as num).toInt(),
  senderId: (json['sender_id'] as num).toInt(),
  senderType: json['sender_type'] as String,
  message: json['message'] as String,
  isAutomatic: json['is_automatic'] as bool? ?? false,
  messageType: json['message_type'] as String? ?? 'text',
  createdAt: DateTime.parse(json['created_at'] as String),
  readAt:
      json['read_at'] == null
          ? null
          : DateTime.parse(json['read_at'] as String),
);

Map<String, dynamic> _$ChatMessageToJson(ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ride_id': instance.rideId,
      'sender_id': instance.senderId,
      'sender_type': instance.senderType,
      'message': instance.message,
      'is_automatic': instance.isAutomatic,
      'message_type': instance.messageType,
      'created_at': instance.createdAt.toIso8601String(),
      'read_at': instance.readAt?.toIso8601String(),
    };
