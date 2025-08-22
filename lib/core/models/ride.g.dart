// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ride _$RideFromJson(Map<String, dynamic> json) => Ride(
  id: (json['id'] as num).toInt(),
  passengerId: (json['passenger_id'] as num).toInt(),
  driverId: (json['driver_id'] as num?)?.toInt(),
  pickupAddress: json['pickup_address'] as String,
  pickupLatitude: (json['pickup_latitude'] as num).toDouble(),
  pickupLongitude: (json['pickup_longitude'] as num).toDouble(),
  destinationAddress: json['destination_address'] as String,
  destinationLatitude: (json['destination_latitude'] as num).toDouble(),
  destinationLongitude: (json['destination_longitude'] as num).toDouble(),
  status: json['status'] as String,
  fare: (json['fare'] as num?)?.toDouble(),
  paymentMethod: json['payment_method'] as String?,
  vehicleCategory: json['vehicle_category'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt:
      json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
  acceptedAt:
      json['accepted_at'] == null
          ? null
          : DateTime.parse(json['accepted_at'] as String),
  startedAt:
      json['started_at'] == null
          ? null
          : DateTime.parse(json['started_at'] as String),
  completedAt:
      json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
  cancelledAt:
      json['cancelled_at'] == null
          ? null
          : DateTime.parse(json['cancelled_at'] as String),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$RideToJson(Ride instance) => <String, dynamic>{
  'id': instance.id,
  'passenger_id': instance.passengerId,
  'driver_id': instance.driverId,
  'pickup_address': instance.pickupAddress,
  'pickup_latitude': instance.pickupLatitude,
  'pickup_longitude': instance.pickupLongitude,
  'destination_address': instance.destinationAddress,
  'destination_latitude': instance.destinationLatitude,
  'destination_longitude': instance.destinationLongitude,
  'status': instance.status,
  'fare': instance.fare,
  'payment_method': instance.paymentMethod,
  'vehicle_category': instance.vehicleCategory,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'accepted_at': instance.acceptedAt?.toIso8601String(),
  'started_at': instance.startedAt?.toIso8601String(),
  'completed_at': instance.completedAt?.toIso8601String(),
  'cancelled_at': instance.cancelledAt?.toIso8601String(),
  'notes': instance.notes,
};
