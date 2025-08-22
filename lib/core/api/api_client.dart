import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

class ApiClient {
  // Usar configuração centralizada
  static String get baseUrl => AppConfig.baseUrl;
  late final Dio _dio;
  
  // Cache do token em memória como fallback
  String? _cachedToken;
  
  static ApiClient? _instance;
  static ApiClient get instance => _instance ??= ApiClient._internal();
  
  ApiClient._internal() {
    print('🌐 [API_CLIENT] ===== CONFIGURATION DEBUG =====');
    print('🌐 [API_CLIENT] Base URL configured: $baseUrl');
    print('🌐 [API_CLIENT] Platform: ${kIsWeb ? 'WEB' : 'MOBILE'}');
    print('🌐 [API_CLIENT] Connect timeout: ${AppConfig.connectTimeout}ms');
    print('🌐 [API_CLIENT] ================================');
    
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(milliseconds: AppConfig.connectTimeout),
      receiveTimeout: Duration(milliseconds: AppConfig.receiveTimeout),
      sendTimeout: Duration(milliseconds: AppConfig.connectTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': '${AppConfig.appName}/${AppConfig.appVersion}',
      },
    ));
    
    // Cookies não funcionam no Flutter Web
    // Vamos usar headers de sessão ao invés de cookies para web
    if (!kIsWeb) {
      // Mobile: usar cookie manager quando disponível
      try {
        // Tenta importar dinamicamente cookie manager se disponível
        // Para web isso será ignorado
      } catch (e) {
        print('Cookie manager não disponível: $e');
      }
    }
    
    _setupInterceptors();
  }
  
  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        print('🔐 [API_CLIENT] ===== REQUEST DEBUG =====');
        print('🔐 [API_CLIENT] Request to: ${options.method} ${options.path}');
        
        String? authToken;
        
        // Try multiple sources for the token
        try {
          // 1. Try cached token first (fastest)
          if (_cachedToken != null) {
            authToken = _cachedToken;
            print('🔐 [API_CLIENT] Token source: MEMORY_CACHE');
          } else {
            // 2. Try SharedPreferences
            final prefs = await SharedPreferences.getInstance();
            authToken = prefs.getString('auth_token');
            print('🔐 [API_CLIENT] Token source: SHARED_PREFERENCES');
            print('🔐 [API_CLIENT] All SharedPreferences keys: ${prefs.getKeys()}');
            
            // Cache it for next time if found
            if (authToken != null) {
              _cachedToken = authToken;
            }
          }
        } catch (e) {
          print('❌ [API_CLIENT] Error getting token: $e');
        }
        
        print('🔐 [API_CLIENT] Auth token found: ${authToken != null ? 'YES' : 'NO'}');
        
        if (authToken != null) {
          print('🔐 [API_CLIENT] Token length: ${authToken.length}');
          print('🔐 [API_CLIENT] Token preview: ${authToken.substring(0, math.min(30, authToken.length))}...');
          options.headers['Authorization'] = 'Bearer $authToken';
          print('🔐 [API_CLIENT] Authorization header set successfully');
        } else {
          print('❌ [API_CLIENT] No auth token available from any source');
        }
        
        print('🔐 [API_CLIENT] Final headers: ${options.headers}');
        print('🔐 [API_CLIENT] ===========================');
        handler.next(options);
      },
      onError: (error, handler) async {
        print('API Error: ${error.type}');
        print('API Error Message: ${error.message}');
        print('API Error Response: ${error.response?.data}');
        print('API Error Status Code: ${error.response?.statusCode}');
        print('API Error Headers: ${error.response?.headers}');
        if (error.type == DioExceptionType.unknown) {
          print('Unknown Error Details: ${error.error}');
        }
        
        if (error.response?.statusCode == 401) {
          await _handleUnauthorized();
        }
        handler.next(error);
      },
    ));
  }
  
  Future<void> _handleUnauthorized() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }

  Future<void> storeAuthToken(String token) async {
    // Store in memory cache first
    _cachedToken = token;
    print('💾 [API_CLIENT] Token cached in memory: ${token.substring(0, math.min(30, token.length))}...');
    
    // Store in SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      print('💾 [API_CLIENT] Token saved to SharedPreferences successfully');
    } catch (e) {
      print('❌ [API_CLIENT] Failed to save token to SharedPreferences: $e');
    }
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> clearAuthToken() async {
    // Clear memory cache
    _cachedToken = null;
    print('🗑️ [API_CLIENT] Token cleared from memory cache');
    
    // Clear SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      print('🗑️ [API_CLIENT] Token cleared from SharedPreferences');
    } catch (e) {
      print('❌ [API_CLIENT] Failed to clear token from SharedPreferences: $e');
    }
  }
  
  // Auth endpoints
  Future<Response> login({
    required String email,
    required String password,
  }) async {
    print('🔑 [API_CLIENT] LOGIN to: $baseUrl/api/auth/login');
    print('🔑 [API_CLIENT] Email: $email');
    
    return await _dio.post('/api/auth/login', data: {
      'email': email,
      'password': password,
    });
  }
  
  Future<Response> register({
    required String email,
    required String password,
    required String phone,
    required String name,
    required String role,
  }) async {
    return await _dio.post('/api/auth/register', data: {
      'email': email,
      'password': password,
      'phone': phone,
      'name': name,
      'role': role,
    });
  }
  
  Future<Response> logout() async {
    return await _dio.post('/api/auth/logout');
  }
  
  // Passenger endpoints
  Future<Response> requestRide({
    required String pickupAddress,
    required double pickupLatitude,
    required double pickupLongitude,
    required String destinationAddress,
    required double destinationLatitude,
    required double destinationLongitude,
    required int vehicleCategory,
    String? paymentMethod,
    double? estimatedFare,
    String? estimatedDistance,
    String? estimatedDuration,
  }) async {
    print('🚗 [API_CLIENT] Requesting ride with vehicleCategoryId: $vehicleCategory');
    
    final requestData = {
      'pickupAddress': pickupAddress,
      'pickupLat': pickupLatitude,
      'pickupLng': pickupLongitude,
      'destinationAddress': destinationAddress,
      'destinationLat': destinationLatitude,
      'destinationLng': destinationLongitude,
      'vehicleCategoryId': vehicleCategory,
      'paymentMethod': paymentMethod,
      'estimatedFare': estimatedFare,
      'estimatedDistance': estimatedDistance,
      'estimatedDuration': estimatedDuration,
    };
    
    print('🚗 [API_CLIENT] Request data: $requestData');
    
    try {
      final response = await _dio.post('/api/rides', data: requestData);
      print('✅ [API_CLIENT] Ride request successful: ${response.statusCode}');
      return response;
    } catch (e) {
      print('❌ [API_CLIENT] Ride request failed: $e');
      rethrow;
    }
  }
  
  Future<Response> getRideDetails(int rideId) async {
    return await _dio.get('/api/rides/$rideId');
  }
  
  Future<Response> cancelRide(int rideId) async {
    return await _dio.post('/api/rides/$rideId/cancel');
  }
  
  Future<Response> rateRide(int rideId, {
    required double rating,
    String? comment,
  }) async {
    return await _dio.post('/api/rides/$rideId/rate', data: {
      'rating': rating,
      'comment': comment,
    });
  }
  
  // Driver endpoints
  Future<Response> acceptRide(int rideId, {required int driverId}) async {
    return await _dio.post('/api/rides/$rideId/accept', data: {'driverId': driverId});
  }
  
  Future<Response> startRide(int rideId) async {
    return await _dio.post('/api/rides/$rideId/status', data: {'status': 'in_progress'});
  }
  
  Future<Response> completeRide(int rideId) async {
    return await _dio.post('/api/rides/$rideId/status', data: {'status': 'completed'});
  }
  
  Future<Response> updateDriverLocation({
    required double latitude,
    required double longitude,
  }) async {
    return await _dio.put('/api/drivers/location', data: {
      'latitude': latitude,
      'longitude': longitude,
    });
  }
  
  Future<Response> setDriverOnlineStatus(bool isOnline) async {
    return await _dio.put('/api/drivers/status', data: {
      'is_online': isOnline,
    });
  }
  
  // Common endpoints
  Future<Response> getVehicleCategories() async {
    return await _dio.get('/api/vehicle-categories');
  }
  
  Future<Response> getRideHistory() async {
    return await _dio.get('/api/rides/history');
  }
  
  Future<Response> getCurrentRide() async {
    return await _dio.get('/api/rides/current');
  }
  
  Future<Response> getUserProfile() async {
    return await _dio.get('/api/profile');
  }
  
  Future<Response> updateProfile(Map<String, dynamic> data) async {
    return await _dio.put('/api/profile', data: data);
  }

  // Push notification endpoints
  Future<Response> registerFCMToken({
    required String token,
    required String platform,
    required String deviceId,
    required String appVersion,
  }) async {
    return await _dio.post('/api/notifications/register-token', data: {
      'token': token,
      'platform': platform,
      'deviceId': deviceId,
      'appVersion': appVersion,
    });
  }

  Future<Response> unregisterFCMToken(String token) async {
    return await _dio.post('/api/notifications/unregister-token', data: {
      'token': token,
    });
  }

  // Payment endpoints
  Future<Response> createPaymentIntent({
    required double amount,
    required String currency,
    required int rideId,
  }) async {
    return await _dio.post('/api/payments/create-intent', data: {
      'amount': amount,
      'currency': currency,
      'rideId': rideId,
    });
  }

  Future<Response> generatePixPayment({
    required int rideId,
    required double amount,
  }) async {
    return await _dio.post('/api/payments/pix', data: {
      'rideId': rideId,
      'amount': amount,
    });
  }

  Future<Response> registerCashPayment({
    required int rideId,
    required double amount,
  }) async {
    return await _dio.post('/api/payments/cash', data: {
      'rideId': rideId,
      'amount': amount,
    });
  }

  Future<Response> processWalletPayment({
    required int rideId,
    required double amount,
  }) async {
    return await _dio.post('/api/payments/wallet', data: {
      'rideId': rideId,
      'amount': amount,
    });
  }

  // Schedule ride for later
  Future<Response> scheduleRide({
    required String pickupAddress,
    required String destinationAddress,
    required DateTime scheduledTime,
    required String vehicleType,
    required String paymentMethod,
    String? notes,
  }) async {
    return await _dio.post('/api/rides/schedule', data: {
      'pickupAddress': pickupAddress,
      'destinationAddress': destinationAddress,
      'scheduledTime': scheduledTime.toIso8601String(),
      'vehicleType': vehicleType,
      'paymentMethod': paymentMethod,
      'notes': notes,
    });
  }

  Future<Response> getPaymentMethods() async {
    return await _dio.get('/api/payments/methods');
  }

  Future<Response> getWalletBalance() async {
    return await _dio.get('/api/wallet/balance');
  }

  Future<Response> addMoneyToWallet({
    required double amount,
    String? paymentMethodId,
  }) async {
    return await _dio.post('/api/wallet/add-money', data: {
      'amount': amount,
      'paymentMethodId': paymentMethodId,
    });
  }
  
  // Upload endpoints
  Future<Response> uploadPhoto(String filePath) async {
    String fileName = filePath.split('/').last;
    FormData formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(filePath, filename: fileName),
    });
    
    return await _dio.post('/api/upload/photo', data: formData);
  }
  
  Future<Response> uploadDocument({
    required String documentType,
    required String filePath,
  }) async {
    String fileName = filePath.split('/').last;
    FormData formData = FormData.fromMap({
      'document_type': documentType,
      'document': await MultipartFile.fromFile(filePath, filename: fileName),
    });
    
    return await _dio.post('/api/upload/document', data: formData);
  }

  // Generic HTTP methods
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, dynamic data, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.post(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> put(String path, dynamic data, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.put(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await _dio.delete(path, data: data, queryParameters: queryParameters);
  }

  // WhatsApp 2FA Methods
  Future<Response> sendWhatsAppCode({
    required String phone,
    required String tempToken,
  }) async {
    return await _dio.post('/api/auth/send-whatsapp-code', data: {
      'phone': phone,
      'tempToken': tempToken,
    });
  }

  Future<Response> verifyWhatsAppCode({
    required String phoneNumber,
    required String code,
    required String tempToken,
  }) async {
    return await _dio.post('/api/auth/verify-whatsapp', data: {
      'phone': phoneNumber,
      'code': code,
      'tempToken': tempToken,
      'platform': 'passenger-flutter',
    });
  }

  Future<Response> resendWhatsAppCode({
    required String phoneNumber,
    required String tempToken,
  }) async {
    return await _dio.post('/api/auth/resend-whatsapp-code', data: {
      'phone': phoneNumber,
      'tempToken': tempToken,
    });
  }
}