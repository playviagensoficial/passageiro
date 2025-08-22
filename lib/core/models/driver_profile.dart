import 'package:json_annotation/json_annotation.dart';

part 'driver_profile.g.dart';

@JsonSerializable()
class DriverProfile {
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'license_number')
  final String licenseNumber;
  @JsonKey(name: 'vehicle_model')
  final String vehicleModel;
  @JsonKey(name: 'vehicle_year')
  final int vehicleYear;
  @JsonKey(name: 'vehicle_color')
  final String vehicleColor;
  @JsonKey(name: 'vehicle_plate')
  final String vehiclePlate;
  @JsonKey(name: 'vehicle_category')
  final String vehicleCategory;
  final String status;
  final double rating;
  @JsonKey(name: 'total_rides')
  final int totalRides;
  @JsonKey(name: 'current_latitude')
  final double? currentLatitude;
  @JsonKey(name: 'current_longitude')
  final double? currentLongitude;
  @JsonKey(name: 'is_online')
  final bool isOnline;
  @JsonKey(name: 'documents_verified')
  final bool documentsVerified;
  final String? photo;
  @JsonKey(name: 'bank_account')
  final String? bankAccount;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  DriverProfile({
    required this.userId,
    required this.licenseNumber,
    required this.vehicleModel,
    required this.vehicleYear,
    required this.vehicleColor,
    required this.vehiclePlate,
    required this.vehicleCategory,
    this.status = 'pending',
    this.rating = 0.0,
    this.totalRides = 0,
    this.currentLatitude,
    this.currentLongitude,
    this.isOnline = false,
    this.documentsVerified = false,
    this.photo,
    this.bankAccount,
    this.createdAt,
    this.updatedAt,
  });

  factory DriverProfile.fromJson(Map<String, dynamic> json) => _$DriverProfileFromJson(json);
  Map<String, dynamic> toJson() => _$DriverProfileToJson(this);

  bool get isActive => status == 'active';
  bool get isPending => status == 'pending';
  bool get isBlocked => status == 'blocked';

  DriverProfile copyWith({
    int? userId,
    String? licenseNumber,
    String? vehicleModel,
    int? vehicleYear,
    String? vehicleColor,
    String? vehiclePlate,
    String? vehicleCategory,
    String? status,
    double? rating,
    int? totalRides,
    double? currentLatitude,
    double? currentLongitude,
    bool? isOnline,
    bool? documentsVerified,
    String? photo,
    String? bankAccount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DriverProfile(
      userId: userId ?? this.userId,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleYear: vehicleYear ?? this.vehicleYear,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      vehicleCategory: vehicleCategory ?? this.vehicleCategory,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      totalRides: totalRides ?? this.totalRides,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      isOnline: isOnline ?? this.isOnline,
      documentsVerified: documentsVerified ?? this.documentsVerified,
      photo: photo ?? this.photo,
      bankAccount: bankAccount ?? this.bankAccount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}