import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String email;
  final String phone;
  final String name;
  final String role;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  final bool verified;
  final bool active;

  User({
    required this.id,
    required this.email,
    required this.phone,
    required this.name,
    required this.role,
    this.createdAt,
    this.updatedAt,
    this.verified = false,
    this.active = true,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  bool get isDriver => role == 'driver';
  bool get isPassenger => role == 'passenger';

  User copyWith({
    int? id,
    String? email,
    String? phone,
    String? name,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? verified,
    bool? active,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      verified: verified ?? this.verified,
      active: active ?? this.active,
    );
  }
}