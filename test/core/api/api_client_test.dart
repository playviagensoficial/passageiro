import 'package:flutter_test/flutter_test.dart';
import 'package:play_viagens_passageiro/core/api/api_client.dart';

void main() {
  group('API Client Tests', () {
    late ApiClient apiClient;

    setUp(() {
      apiClient = ApiClient();
    });

    test('should have correct base URL', () {
      expect(ApiClient.baseUrl, 'http://localhost:5010');
    });

    test('should format login endpoint correctly', () {
      final endpoint = '${ApiClient.baseUrl}/api/auth/login';
      expect(endpoint, 'http://localhost:5010/api/auth/login');
    });

    test('should format register endpoint correctly', () {
      final endpoint = '${ApiClient.baseUrl}/api/auth/register';
      expect(endpoint, 'http://localhost:5010/api/auth/register');
    });

    test('should format rides endpoint correctly', () {
      final endpoint = '${ApiClient.baseUrl}/api/rides/request';
      expect(endpoint, 'http://localhost:5010/api/rides/request');
    });

    test('should format passenger profile endpoint correctly', () {
      final userId = '123';
      final endpoint = '${ApiClient.baseUrl}/api/passengers/$userId/profile';
      expect(endpoint, 'http://localhost:5010/api/passengers/123/profile');
    });
  });
}