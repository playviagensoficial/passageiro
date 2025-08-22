import 'package:json_annotation/json_annotation.dart';

part 'ride.g.dart';

@JsonSerializable()
class Ride {
  final int id;
  @JsonKey(name: 'passenger_id')
  final int passengerId;
  @JsonKey(name: 'driver_id')
  final int? driverId;
  @JsonKey(name: 'pickup_address')
  final String pickupAddress;
  @JsonKey(name: 'pickup_latitude')
  final double pickupLatitude;
  @JsonKey(name: 'pickup_longitude')
  final double pickupLongitude;
  @JsonKey(name: 'destination_address')
  final String destinationAddress;
  @JsonKey(name: 'destination_latitude')
  final double destinationLatitude;
  @JsonKey(name: 'destination_longitude')
  final double destinationLongitude;
  final String status;
  final double? fare;
  @JsonKey(name: 'payment_method')
  final String? paymentMethod;
  @JsonKey(name: 'vehicle_category')
  final String vehicleCategory;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @JsonKey(name: 'accepted_at')
  final DateTime? acceptedAt;
  @JsonKey(name: 'started_at')
  final DateTime? startedAt;
  @JsonKey(name: 'completed_at')
  final DateTime? completedAt;
  @JsonKey(name: 'cancelled_at')
  final DateTime? cancelledAt;
  final String? notes;

  Ride({
    required this.id,
    required this.passengerId,
    this.driverId,
    required this.pickupAddress,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.destinationAddress,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.status,
    this.fare,
    this.paymentMethod,
    required this.vehicleCategory,
    required this.createdAt,
    this.updatedAt,
    this.acceptedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.notes,
  });

  factory Ride.fromJson(Map<String, dynamic> json) => _$RideFromJson(json);
  Map<String, dynamic> toJson() => _$RideToJson(this);

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  Ride copyWith({
    int? id,
    int? passengerId,
    int? driverId,
    String? pickupAddress,
    double? pickupLatitude,
    double? pickupLongitude,
    String? destinationAddress,
    double? destinationLatitude,
    double? destinationLongitude,
    String? status,
    double? fare,
    String? paymentMethod,
    String? vehicleCategory,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? acceptedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? notes,
  }) {
    return Ride(
      id: id ?? this.id,
      passengerId: passengerId ?? this.passengerId,
      driverId: driverId ?? this.driverId,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      pickupLatitude: pickupLatitude ?? this.pickupLatitude,
      pickupLongitude: pickupLongitude ?? this.pickupLongitude,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      destinationLatitude: destinationLatitude ?? this.destinationLatitude,
      destinationLongitude: destinationLongitude ?? this.destinationLongitude,
      status: status ?? this.status,
      fare: fare ?? this.fare,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      vehicleCategory: vehicleCategory ?? this.vehicleCategory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      notes: notes ?? this.notes,
    );
  }

  // Factory constructor que funciona com resposta do servidor (camelCase)
  factory Ride.fromServerResponse(Map<String, dynamic> json) {
    // Helper function to safely convert string or number to double
    double? parseDoubleFromAny(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value);
      }
      return null;
    }

    return Ride(
      id: json['id'] as int,
      passengerId: json['passengerId'] as int? ?? 0,
      driverId: json['driverId'] as int?,
      pickupAddress: json['pickupAddress'] as String? ?? '',
      pickupLatitude: parseDoubleFromAny(json['pickupLat']) ?? 0.0,
      pickupLongitude: parseDoubleFromAny(json['pickupLng']) ?? 0.0,
      destinationAddress: json['destinationAddress'] as String? ?? '',
      destinationLatitude: parseDoubleFromAny(json['destinationLat']) ?? 0.0,
      destinationLongitude: parseDoubleFromAny(json['destinationLng']) ?? 0.0,
      status: json['status'] as String? ?? 'requested',
      fare: parseDoubleFromAny(json['fare']),
      paymentMethod: json['paymentMethod'] as String?,
      vehicleCategory: json['vehicleType'] as String? ?? 'economy',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      acceptedAt: json['acceptedAt'] != null 
          ? DateTime.parse(json['acceptedAt'] as String)
          : null,
      startedAt: json['startedAt'] != null 
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      cancelledAt: json['cancelledAt'] != null 
          ? DateTime.parse(json['cancelledAt'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }
}