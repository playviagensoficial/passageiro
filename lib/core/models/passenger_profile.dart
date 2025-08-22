import 'package:json_annotation/json_annotation.dart';

part 'passenger_profile.g.dart';

@JsonSerializable()
class PassengerProfile {
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'preferred_payment_method')
  final String? preferredPaymentMethod;
  final String? photo;
  @JsonKey(name: 'emergency_contact')
  final String? emergencyContact;
  @JsonKey(name: 'total_rides')
  final int totalRides;
  final double rating;
  @JsonKey(name: 'favorite_addresses')
  final List<String>? favoriteAddresses;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  PassengerProfile({
    required this.userId,
    this.preferredPaymentMethod,
    this.photo,
    this.emergencyContact,
    this.totalRides = 0,
    this.rating = 0.0,
    this.favoriteAddresses,
    this.createdAt,
    this.updatedAt,
  });

  factory PassengerProfile.fromJson(Map<String, dynamic> json) => _$PassengerProfileFromJson(json);
  Map<String, dynamic> toJson() => _$PassengerProfileToJson(this);

  PassengerProfile copyWith({
    int? userId,
    String? preferredPaymentMethod,
    String? photo,
    String? emergencyContact,
    int? totalRides,
    double? rating,
    List<String>? favoriteAddresses,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PassengerProfile(
      userId: userId ?? this.userId,
      preferredPaymentMethod: preferredPaymentMethod ?? this.preferredPaymentMethod,
      photo: photo ?? this.photo,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      totalRides: totalRides ?? this.totalRides,
      rating: rating ?? this.rating,
      favoriteAddresses: favoriteAddresses ?? this.favoriteAddresses,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}