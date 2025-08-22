import 'package:flutter_test/flutter_test.dart';
import 'package:play_viagens_passageiro/features/auth/providers/auth_provider.dart';
import 'package:play_viagens_passageiro/core/models/user.dart';

void main() {
  group('Auth Provider Tests', () {
    late AuthProvider authProvider;

    setUp(() {
      authProvider = AuthProvider();
    });

    test('should start with not logged in state', () {
      expect(authProvider.isLoggedIn, false);
      expect(authProvider.user, null);
      expect(authProvider.token, null);
      expect(authProvider.isDriver, false);
    });

    test('should update state when user logs in', () {
      // Arrange
      final user = User(
        id: '1',
        name: 'João',
        email: 'joao@email.com',
        phone: '11987654321',
        role: 'passenger',
        isActive: true,
      );
      const token = 'test_token_123';

      // Act
      authProvider.setUser(user, token);

      // Assert
      expect(authProvider.isLoggedIn, true);
      expect(authProvider.user, user);
      expect(authProvider.token, token);
      expect(authProvider.isDriver, false);
    });

    test('should identify driver correctly', () {
      // Arrange
      final driver = User(
        id: '1',
        name: 'Maria',
        email: 'maria@email.com',
        phone: '11987654321',
        role: 'driver',
        isActive: true,
      );

      // Act
      authProvider.setUser(driver, 'token');

      // Assert
      expect(authProvider.isDriver, true);
    });

    test('should clear state when user logs out', () {
      // Arrange
      final user = User(
        id: '1',
        name: 'João',
        email: 'joao@email.com',
        phone: '11987654321',
        role: 'passenger',
        isActive: true,
      );
      authProvider.setUser(user, 'token');

      // Act
      authProvider.logout();

      // Assert
      expect(authProvider.isLoggedIn, false);
      expect(authProvider.user, null);
      expect(authProvider.token, null);
      expect(authProvider.isDriver, false);
    });
  });
}