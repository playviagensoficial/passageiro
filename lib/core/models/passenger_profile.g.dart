// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'passenger_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PassengerProfile _$PassengerProfileFromJson(Map<String, dynamic> json) =>
    PassengerProfile(
      userId: (json['user_id'] as num).toInt(),
      preferredPaymentMethod: json['preferred_payment_method'] as String?,
      photo: json['photo'] as String?,
      emergencyContact: json['emergency_contact'] as String?,
      totalRides: (json['total_rides'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      favoriteAddresses:
          (json['favorite_addresses'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      createdAt:
          json['created_at'] == null
              ? null
              : DateTime.parse(json['created_at'] as String),
      updatedAt:
          json['updated_at'] == null
              ? null
              : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$PassengerProfileToJson(PassengerProfile instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'preferred_payment_method': instance.preferredPaymentMethod,
      'photo': instance.photo,
      'emergency_contact': instance.emergencyContact,
      'total_rides': instance.totalRides,
      'rating': instance.rating,
      'favorite_addresses': instance.favoriteAddresses,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
