// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VehicleCategory _$VehicleCategoryFromJson(Map<String, dynamic> json) =>
    VehicleCategory(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      displayName: json['displayName'] as String?,
      description: json['description'] as String,
      baseFare: json['baseFare'] as String,
      perKmRate: json['perKmRate'] as String,
      perMinuteRate: json['perMinuteRate'] as String,
      minimumFare: json['minimumFare'] as String?,
      maxCapacity: (json['maxCapacity'] as num).toInt(),
      isActive: json['isActive'] as bool? ?? true,
      iconUrl: json['iconUrl'] as String?,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
    );

Map<String, dynamic> _$VehicleCategoryToJson(VehicleCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'displayName': instance.displayName,
      'description': instance.description,
      'baseFare': instance.baseFare,
      'perKmRate': instance.perKmRate,
      'perMinuteRate': instance.perMinuteRate,
      'minimumFare': instance.minimumFare,
      'maxCapacity': instance.maxCapacity,
      'isActive': instance.isActive,
      'iconUrl': instance.iconUrl,
      'icon': instance.icon,
      'color': instance.color,
    };
