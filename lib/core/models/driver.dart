import 'package:json_annotation/json_annotation.dart';

part 'driver.g.dart';

@JsonSerializable()
class Driver {
  final int id;
  final String name;
  final String email;
  @JsonKey(name: 'phone_number')
  final String phoneNumber;
  @JsonKey(name: 'profile_photo_url')
  final String? profilePhotoUrl;
  final double rating;
  @JsonKey(name: 'total_rides')
  final int totalRides;
  @JsonKey(name: 'license_number')
  final String? licenseNumber;
  @JsonKey(name: 'vehicle_id')
  final int? vehicleId;
  @JsonKey(name: 'vehicle_plate')
  final String? vehiclePlate;
  @JsonKey(name: 'vehicle_model')
  final String? vehicleModel;
  @JsonKey(name: 'vehicle_color')
  final String? vehicleColor;
  @JsonKey(name: 'vehicle_photo_url')
  final String? vehiclePhotoUrl;
  @JsonKey(name: 'current_latitude')
  final double? currentLatitude;
  @JsonKey(name: 'current_longitude')
  final double? currentLongitude;
  @JsonKey(name: 'is_online')
  final bool isOnline;
  @JsonKey(name: 'is_available')
  final bool isAvailable;

  Driver({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.profilePhotoUrl,
    required this.rating,
    required this.totalRides,
    this.licenseNumber,
    this.vehicleId,
    this.vehiclePlate,
    this.vehicleModel,
    this.vehicleColor,
    this.vehiclePhotoUrl,
    this.currentLatitude,
    this.currentLongitude,
    required this.isOnline,
    required this.isAvailable,
  });

  factory Driver.fromJson(Map<String, dynamic> json) => _$DriverFromJson(json);
  Map<String, dynamic> toJson() => _$DriverToJson(this);

  String get formattedRating => rating.toStringAsFixed(1);
  
  String get vehicleInfo => vehicleModel != null && vehiclePlate != null 
      ? '$vehicleModel - $vehiclePlate'
      : 'Veículo não informado';
      
  String get formattedPhone {
    if (phoneNumber.length == 11) {
      return '(${phoneNumber.substring(0, 2)}) ${phoneNumber.substring(2, 7)}-${phoneNumber.substring(7)}';
    }
    return phoneNumber;
  }

  Driver copyWith({
    int? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? profilePhotoUrl,
    double? rating,
    int? totalRides,
    String? licenseNumber,
    int? vehicleId,
    String? vehiclePlate,
    String? vehicleModel,
    String? vehicleColor,
    String? vehiclePhotoUrl,
    double? currentLatitude,
    double? currentLongitude,
    bool? isOnline,
    bool? isAvailable,
  }) {
    return Driver(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      rating: rating ?? this.rating,
      totalRides: totalRides ?? this.totalRides,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      vehicleId: vehicleId ?? this.vehicleId,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      vehiclePhotoUrl: vehiclePhotoUrl ?? this.vehiclePhotoUrl,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      isOnline: isOnline ?? this.isOnline,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}