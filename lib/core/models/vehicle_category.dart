import 'package:json_annotation/json_annotation.dart';

part 'vehicle_category.g.dart';

@JsonSerializable()
class VehicleCategory {
  final int id;
  final String name;
  final String? displayName;
  final String description;
  final String baseFare;
  final String perKmRate;
  final String perMinuteRate;
  final String? minimumFare;
  final int maxCapacity;
  final bool isActive;
  final String? iconUrl;
  final String? icon;
  final String? color;

  VehicleCategory({
    required this.id,
    required this.name,
    this.displayName,
    required this.description,
    required this.baseFare,
    required this.perKmRate,
    required this.perMinuteRate,
    this.minimumFare,
    required this.maxCapacity,
    this.isActive = true,
    this.iconUrl,
    this.icon,
    this.color,
  });

  // Computed properties for numeric values
  double get baseFareValue => double.tryParse(baseFare) ?? 0.0;
  double get perKmRateValue => double.tryParse(perKmRate) ?? 0.0;
  double get perMinuteRateValue => double.tryParse(perMinuteRate) ?? 0.0;
  double get minimumFareValue => double.tryParse(minimumFare ?? '') ?? baseFareValue;

  factory VehicleCategory.fromJson(Map<String, dynamic> json) => _$VehicleCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$VehicleCategoryToJson(this);

  VehicleCategory copyWith({
    int? id,
    String? name,
    String? displayName,
    String? description,
    String? baseFare,
    String? perKmRate,
    String? perMinuteRate,
    String? minimumFare,
    int? maxCapacity,
    String? iconUrl,
    String? icon,
    String? color,
    bool? isActive,
  }) {
    return VehicleCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      baseFare: baseFare ?? this.baseFare,
      perKmRate: perKmRate ?? this.perKmRate,
      perMinuteRate: perMinuteRate ?? this.perMinuteRate,
      minimumFare: minimumFare ?? this.minimumFare,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      iconUrl: iconUrl ?? this.iconUrl,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
    );
  }
}