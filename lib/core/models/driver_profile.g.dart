// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverProfile _$DriverProfileFromJson(Map<String, dynamic> json) =>
    DriverProfile(
      userId: (json['user_id'] as num).toInt(),
      licenseNumber: json['license_number'] as String,
      vehicleModel: json['vehicle_model'] as String,
      vehicleYear: (json['vehicle_year'] as num).toInt(),
      vehicleColor: json['vehicle_color'] as String,
      vehiclePlate: json['vehicle_plate'] as String,
      vehicleCategory: json['vehicle_category'] as String,
      status: json['status'] as String? ?? 'pending',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalRides: (json['total_rides'] as num?)?.toInt() ?? 0,
      currentLatitude: (json['current_latitude'] as num?)?.toDouble(),
      currentLongitude: (json['current_longitude'] as num?)?.toDouble(),
      isOnline: json['is_online'] as bool? ?? false,
      documentsVerified: json['documents_verified'] as bool? ?? false,
      photo: json['photo'] as String?,
      bankAccount: json['bank_account'] as String?,
      createdAt:
          json['created_at'] == null
              ? null
              : DateTime.parse(json['created_at'] as String),
      updatedAt:
          json['updated_at'] == null
              ? null
              : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$DriverProfileToJson(DriverProfile instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'license_number': instance.licenseNumber,
      'vehicle_model': instance.vehicleModel,
      'vehicle_year': instance.vehicleYear,
      'vehicle_color': instance.vehicleColor,
      'vehicle_plate': instance.vehiclePlate,
      'vehicle_category': instance.vehicleCategory,
      'status': instance.status,
      'rating': instance.rating,
      'total_rides': instance.totalRides,
      'current_latitude': instance.currentLatitude,
      'current_longitude': instance.currentLongitude,
      'is_online': instance.isOnline,
      'documents_verified': instance.documentsVerified,
      'photo': instance.photo,
      'bank_account': instance.bankAccount,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
