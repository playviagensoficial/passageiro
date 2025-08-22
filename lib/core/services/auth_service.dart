import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';
import '../models/user.dart';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._internal();
  
  AuthService._internal();
  
  final ApiClient _apiClient = ApiClient.instance;
  User? _currentUser;
  String? _currentToken;
  
  User? get currentUser => _currentUser;
  String? get currentToken => _currentToken;
  bool get isLoggedIn => _currentUser != null && _currentToken != null;
  
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentToken = prefs.getString('auth_token');
    
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      final userData = jsonDecode(userDataString);
      _currentUser = User.fromJson(userData);
    }
    
    // If we have a token, make sure ApiClient is aware of it
    if (_currentToken != null) {
      await _apiClient.storeAuthToken(_currentToken!);
      print('🔄 [AUTH_SERVICE] Restored token to ApiClient');
    }
  }
  
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.login(
        email: email,
        password: password,
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        
        // Verificar se requer WhatsApp 2FA
        if (data['requiresWhatsApp2FA'] == true) {
          print('🔐 [AUTH_SERVICE] WhatsApp 2FA required');
          return AuthResult.whatsApp2FARequired(
            tempToken: data['tempToken'],
            phone: data['phone'],
            user: User.fromJson(data['user']),
          );
        }
        
        // Login normal
        _currentToken = data['token'];
        _currentUser = User.fromJson(data['user']);
        
        print('✅ [AUTH_SERVICE] Login successful');
        print('✅ [AUTH_SERVICE] Token received: ${_currentToken != null}');
        if (_currentToken != null) {
          print('✅ [AUTH_SERVICE] Token length: ${_currentToken!.length}');
          print('✅ [AUTH_SERVICE] Token preview: ${_currentToken!.substring(0, 20)}...');
        }
        
        await _saveAuthData();
        
        // Also store token in ApiClient for immediate use
        await _apiClient.storeAuthToken(_currentToken!);
        
        print('✅ [AUTH_SERVICE] Auth data saved to SharedPreferences');
        
        return AuthResult.success(user: _currentUser!);
      } else {
        return AuthResult.failure(
          message: response.data['message'] ?? 'Login failed',
        );
      }
    } on DioException catch (e) {
      String message = 'Network error';
      
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          message = 'Timeout de conexão - verifique sua internet';
          break;
        case DioExceptionType.sendTimeout:
          message = 'Timeout ao enviar dados - verifique sua internet';
          break;
        case DioExceptionType.receiveTimeout:
          message = 'Timeout ao receber dados - verifique sua internet';
          break;
        case DioExceptionType.connectionError:
          message = 'Erro de conexão - servidor indisponível';
          break;
        case DioExceptionType.badResponse:
          message = e.response?.data['message'] ?? 'Erro do servidor';
          break;
        default:
          message = e.response?.data['message'] ?? 'Erro de rede';
      }
      
      print('Login DioException: ${e.type} - ${e.message}');
      return AuthResult.failure(message: message);
    } catch (e) {
      print('Login unexpected error: $e');
      return AuthResult.failure(message: 'Erro inesperado: $e');
    }
  }
  
  Future<AuthResult> register({
    required String email,
    required String password,
    required String phone,
    required String name,
    required String role,
  }) async {
    try {
      final response = await _apiClient.register(
        email: email,
        password: password,
        phone: phone,
        name: name,
        role: role,
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        
        print('📋 Register response data: $data');
        
        // Check if requires WhatsApp 2FA
        if (data['requiresWhatsApp2FA'] == true) {
          print('🔐 [AUTH_SERVICE] WhatsApp 2FA required for registration');
          return AuthResult.whatsApp2FARequired(
            tempToken: data['tempToken'],
            phone: data['phone'],
            user: User.fromJson(data['user']),
          );
        }
        
        // Check if we have a token for direct registration
        if (data['token'] != null && data['user'] != null) {
          _currentToken = data['token'];
          _currentUser = User.fromJson(data['user']);
          
          await _saveAuthData();
          
          return AuthResult.success(user: _currentUser!);
        } else if (data['user'] != null) {
          // Response might not include token, treat as success but require login
          return AuthResult.success(user: User.fromJson(data['user']));
        } else {
          return AuthResult.failure(
            message: 'Registration successful but invalid response format',
          );
        }
      } else {
        return AuthResult.failure(
          message: response.data['message'] ?? 'Registration failed',
        );
      }
    } on DioException catch (e) {
      String message = 'Network error';
      
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          message = 'Timeout de conexão - verifique sua internet';
          break;
        case DioExceptionType.sendTimeout:
          message = 'Timeout ao enviar dados - verifique sua internet';
          break;
        case DioExceptionType.receiveTimeout:
          message = 'Timeout ao receber dados - verifique sua internet';
          break;
        case DioExceptionType.connectionError:
          message = 'Erro de conexão - servidor indisponível';
          break;
        case DioExceptionType.badResponse:
          message = e.response?.data['message'] ?? 'Erro do servidor';
          break;
        default:
          message = e.response?.data['message'] ?? 'Erro de rede';
      }
      
      print('Register DioException: ${e.type} - ${e.message}');
      return AuthResult.failure(message: message);
    } catch (e) {
      return AuthResult.failure(message: 'Unexpected error: $e');
    }
  }
  
  Future<void> logout() async {
    try {
      await _apiClient.logout();
    } catch (e) {
      print('Logout error: $e');
    } finally {
      await _clearAuthData();
    }
  }
  
  Future<AuthResult> refreshProfile() async {
    try {
      final response = await _apiClient.getUserProfile();
      
      if (response.statusCode == 200) {
        _currentUser = User.fromJson(response.data);
        await _saveAuthData();
        return AuthResult.success(user: _currentUser!);
      } else {
        return AuthResult.failure(message: 'Failed to refresh profile');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await logout();
        return AuthResult.failure(message: 'Session expired');
      }
      return AuthResult.failure(
        message: e.response?.data['message'] ?? 'Network error',
      );
    } catch (e) {
      return AuthResult.failure(message: 'Unexpected error: $e');
    }
  }
  
  Future<AuthResult> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.updateProfile(data);
      
      if (response.statusCode == 200) {
        _currentUser = User.fromJson(response.data);
        await _saveAuthData();
        return AuthResult.success(user: _currentUser!);
      } else {
        return AuthResult.failure(message: 'Failed to update profile');
      }
    } on DioException catch (e) {
      return AuthResult.failure(
        message: e.response?.data['message'] ?? 'Network error',
      );
    } catch (e) {
      return AuthResult.failure(message: 'Unexpected error: $e');
    }
  }
  
  Future<void> _saveAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentToken != null) {
      await prefs.setString('auth_token', _currentToken!);
      print('💾 [AUTH_SERVICE] Token saved to SharedPreferences: ${_currentToken!.substring(0, 30)}...');
      
      // Verify it was saved
      final savedToken = prefs.getString('auth_token');
      print('✅ [AUTH_SERVICE] Token verification: ${savedToken != null ? 'SUCCESS' : 'FAILED'}');
      if (savedToken != null) {
        print('✅ [AUTH_SERVICE] Saved token preview: ${savedToken.substring(0, 30)}...');
      }
    }
    if (_currentUser != null) {
      await prefs.setString('user_data', jsonEncode(_currentUser!.toJson()));
      print('💾 [AUTH_SERVICE] User data saved to SharedPreferences');
    }
  }
  
  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    _currentToken = null;
    _currentUser = null;
  }

  // WhatsApp 2FA Methods
  Future<AuthResult> sendWhatsAppCode({
    required String phone,
    required String tempToken,
  }) async {
    try {
      await _apiClient.sendWhatsAppCode(
        phone: phone,
        tempToken: tempToken,
      );
      
      return AuthResult.success(user: null);
    } catch (e) {
      return AuthResult.failure(
        message: e.toString().contains('message') 
          ? e.toString() 
          : 'Erro ao enviar código',
      );
    }
  }

  Future<AuthResult> verifyWhatsAppCode({
    required String phoneNumber,
    required String code,
    required String tempToken,
  }) async {
    try {
      final response = await _apiClient.verifyWhatsAppCode(
        phoneNumber: phoneNumber,
        code: code,
        tempToken: tempToken,
      );
      
      final userData = response.data['user'];
      final token = response.data['token'];
      
      if (userData != null && token != null) {
        _currentUser = User.fromJson(userData);
        _currentToken = token;
        await _saveAuthData();
        await _apiClient.storeAuthToken(token);
        
        return AuthResult.success(user: _currentUser);
      } else {
        return AuthResult.failure(message: 'Resposta inválida do servidor');
      }
    } catch (e) {
      return AuthResult.failure(
        message: e.toString().contains('message') 
          ? e.toString() 
          : 'Código inválido',
      );
    }
  }

  Future<AuthResult> resendWhatsAppCode({
    required String phoneNumber,
    required String tempToken,
  }) async {
    try {
      await _apiClient.resendWhatsAppCode(
        phoneNumber: phoneNumber,
        tempToken: tempToken,
      );
      
      return AuthResult.success(user: null);
    } catch (e) {
      return AuthResult.failure(
        message: e.toString().contains('message') 
          ? e.toString() 
          : 'Erro ao reenviar código',
      );
    }
  }
}

class AuthResult {
  final bool isSuccess;
  final String? message;
  final User? user;
  final bool requiresWhatsApp2FA;
  final String? tempToken;
  final String? phone;
  
  AuthResult.success({required this.user})
      : isSuccess = true,
        message = null,
        requiresWhatsApp2FA = false,
        tempToken = null,
        phone = null;
  
  AuthResult.failure({required this.message})
      : isSuccess = false,
        user = null,
        requiresWhatsApp2FA = false,
        tempToken = null,
        phone = null;

  AuthResult.whatsApp2FARequired({
    required this.tempToken,
    required this.phone,
    required this.user,
  })  : isSuccess = false,
        message = null,
        requiresWhatsApp2FA = true;
}