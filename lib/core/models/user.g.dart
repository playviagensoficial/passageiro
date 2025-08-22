// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num).toInt(),
  email: json['email'] as String,
  phone: json['phone'] as String,
  name: json['name'] as String,
  role: json['role'] as String,
  createdAt:
      json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
  updatedAt:
      json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
  verified: json['verified'] as bool? ?? false,
  active: json['active'] as bool? ?? true,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'phone': instance.phone,
  'name': instance.name,
  'role': instance.role,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'verified': instance.verified,
  'active': instance.active,
};
