import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/websocket_service.dart';
import '../../../core/models/user.dart';
import '../../../core/config/app_config.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService.instance;
  final WebSocketService _webSocketService = WebSocketService.instance;
  
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isDriver => _currentUser?.isDriver ?? false;
  bool get isPassenger => _currentUser?.isPassenger ?? false;
  String? get currentToken => _authService.currentToken;
  
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _authService.initialize();
      _currentUser = _authService.currentUser;
      
      if (isLoggedIn && !kIsWeb) {
        await _webSocketService.connect();
      }
    } catch (e) {
      _setError('Failed to initialize: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<dynamic> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.login(
        email: email,
        password: password,
      );
      
      if (result.isSuccess) {
        _currentUser = result.user;
        if (!kIsWeb) {
          await _webSocketService.connect();
        }
        notifyListeners();
        return true;
      } else if (result.requiresWhatsApp2FA) {
        // Retornar informações para WhatsApp 2FA
        return {
          'requiresWhatsApp2FA': true,
          'tempToken': result.tempToken,
          'phone': result.phone,
          'user': result.user,
        };
      } else {
        _setError(result.message ?? 'Login failed');
        return false;
      }
    } catch (e) {
      _setError('Unexpected error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<dynamic> register({
    required String email,
    required String password,
    required String phone,
    required String name,
    required String role,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.register(
        email: email,
        password: password,
        phone: phone,
        name: name,
        role: role,
      );
      
      if (result.isSuccess) {
        _currentUser = result.user;
        
        // Only connect websocket if we have a token (user is fully logged in)
        if (_authService.currentToken != null && !kIsWeb) {
          await _webSocketService.connect();
        }
        
        notifyListeners();
        return true;
      } else if (result.requiresWhatsApp2FA) {
        // Retornar informações para WhatsApp 2FA no registro
        notifyListeners();
        return {
          'requiresWhatsApp2FA': true,
          'tempToken': result.tempToken,
          'phone': result.phone,
          'user': result.user,
        };
      } else {
        _setError(result.message ?? 'Registration failed');
        return false;
      }
    } catch (e) {
      print('❌ [AUTH_PROVIDER] Register error: $e');
      _setError('Erro inesperado durante o cadastro');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _webSocketService.disconnect();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _setError('Logout error: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.updateProfile(data);
      
      if (result.isSuccess) {
        _currentUser = result.user;
        notifyListeners();
        return true;
      } else {
        _setError(result.message ?? 'Update failed');
        return false;
      }
    } catch (e) {
      _setError('Unexpected error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> refreshProfile() async {
    try {
      final result = await _authService.refreshProfile();
      
      if (result.isSuccess) {
        _currentUser = result.user;
        notifyListeners();
        return true;
      } else {
        if (result.message == 'Session expired') {
          _currentUser = null;
          notifyListeners();
        }
        return false;
      }
    } catch (e) {
      return false;
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  void clearError() {
    _clearError();
  }

  // WhatsApp 2FA Methods
  Future<bool> sendWhatsAppCode({
    required String phone,
    required String tempToken,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.sendWhatsAppCode(
        phone: phone,
        tempToken: tempToken,
      );
      
      if (result.isSuccess) {
        return true;
      } else {
        _setError(result.message ?? 'Erro ao enviar código');
        return false;
      }
    } catch (e) {
      _setError('Erro inesperado: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> verifyWhatsAppCode({
    required String phoneNumber,
    required String code,
    required String tempToken,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.verifyWhatsAppCode(
        phoneNumber: phoneNumber,
        code: code,
        tempToken: tempToken,
      );
      
      if (result.isSuccess) {
        _currentUser = result.user;
        if (!kIsWeb) {
          await _webSocketService.connect();
        }
        notifyListeners();
        return true;
      } else {
        _setError(result.message ?? 'Código inválido');
        return false;
      }
    } catch (e) {
      _setError('Erro inesperado: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resendWhatsAppCode({
    required String phoneNumber,
    required String tempToken,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.resendWhatsAppCode(
        phoneNumber: phoneNumber,
        tempToken: tempToken,
      );
      
      if (result.isSuccess) {
        return true;
      } else {
        _setError(result.message ?? 'Erro ao reenviar código');
        return false;
      }
    } catch (e) {
      _setError('Erro inesperado: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}