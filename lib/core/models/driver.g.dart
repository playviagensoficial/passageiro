// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Driver _$DriverFromJson(Map<String, dynamic> json) => Driver(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  email: json['email'] as String,
  phoneNumber: json['phone_number'] as String,
  profilePhotoUrl: json['profile_photo_url'] as String?,
  rating: (json['rating'] as num).toDouble(),
  totalRides: (json['total_rides'] as num).toInt(),
  licenseNumber: json['license_number'] as String?,
  vehicleId: (json['vehicle_id'] as num?)?.toInt(),
  vehiclePlate: json['vehicle_plate'] as String?,
  vehicleModel: json['vehicle_model'] as String?,
  vehicleColor: json['vehicle_color'] as String?,
  vehiclePhotoUrl: json['vehicle_photo_url'] as String?,
  currentLatitude: (json['current_latitude'] as num?)?.toDouble(),
  currentLongitude: (json['current_longitude'] as num?)?.toDouble(),
  isOnline: json['is_online'] as bool,
  isAvailable: json['is_available'] as bool,
);

Map<String, dynamic> _$DriverToJson(Driver instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'phone_number': instance.phoneNumber,
  'profile_photo_url': instance.profilePhotoUrl,
  'rating': instance.rating,
  'total_rides': instance.totalRides,
  'license_number': instance.licenseNumber,
  'vehicle_id': instance.vehicleId,
  'vehicle_plate': instance.vehiclePlate,
  'vehicle_model': instance.vehicleModel,
  'vehicle_color': instance.vehicleColor,
  'vehicle_photo_url': instance.vehiclePhotoUrl,
  'current_latitude': instance.currentLatitude,
  'current_longitude': instance.currentLongitude,
  'is_online': instance.isOnline,
  'is_available': instance.isAvailable,
};
