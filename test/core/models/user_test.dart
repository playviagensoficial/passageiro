import 'package:flutter_test/flutter_test.dart';
import 'package:play_viagens_passageiro/core/models/user.dart';

void main() {
  group('User Model Tests', () {
    test('should create user from JSON correctly', () {
      // Arrange
      final json = {
        'id': '1',
        'name': 'João Silva',
        'email': 'joao@email.com',
        'phone': '11987654321',
        'role': 'passenger',
        'isActive': true,
      };

      // Act
      final user = User.fromJson(json);

      // Assert
      expect(user.id, '1');
      expect(user.name, 'João Silva');
      expect(user.email, 'joao@email.com');
      expect(user.phone, '11987654321');
      expect(user.role, 'passenger');
      expect(user.isActive, true);
    });

    test('should convert user to JSON correctly', () {
      // Arrange
      final user = User(
        id: '1',
        name: 'João Silva',
        email: 'joao@email.com',
        phone: '11987654321',
        role: 'passenger',
        isActive: true,
      );

      // Act
      final json = user.toJson();

      // Assert
      expect(json['id'], '1');
      expect(json['name'], 'João Silva');
      expect(json['email'], 'joao@email.com');
      expect(json['phone'], '11987654321');
      expect(json['role'], 'passenger');
      expect(json['isActive'], true);
    });

    test('should identify passenger correctly', () {
      // Arrange
      final passenger = User(
        id: '1',
        name: 'João',
        email: 'joao@email.com',
        phone: '11987654321',
        role: 'passenger',
        isActive: true,
      );

      final driver = User(
        id: '2',
        name: 'Maria',
        email: 'maria@email.com',
        phone: '11987654322',
        role: 'driver',
        isActive: true,
      );

      // Assert
      expect(passenger.isPassenger, true);
      expect(passenger.isDriver, false);
      expect(driver.isPassenger, false);
      expect(driver.isDriver, true);
    });
  });
}