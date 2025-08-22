import 'package:dio/dio.dart';

class ApiService {
  static const String baseUrl = 'http://172.24.181.59:5000/api';
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    headers: {
      'Content-Type': 'application/json',
    },
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
  
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      return _handleResponse(response);
    } catch (e) {
      if (e is DioException) {
        throw Exception('Erro na requisição GET: ${e.message}');
      }
      throw Exception('Erro na requisição GET: $e');
    }
  }
  
  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return _handleResponse(response);
    } catch (e) {
      if (e is DioException) {
        throw Exception('Erro na requisição POST: ${e.message}');
      }
      throw Exception('Erro na requisição POST: $e');
    }
  }
  
  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return _handleResponse(response);
    } catch (e) {
      if (e is DioException) {
        throw Exception('Erro na requisição DELETE: ${e.message}');
      }
      throw Exception('Erro na requisição DELETE: $e');
    }
  }
  
  static Map<String, dynamic> _handleResponse(Response response) {
    if (response.statusCode != null && 
        response.statusCode! >= 200 && 
        response.statusCode! < 300) {
      
      if (response.data is Map<String, dynamic>) {
        return response.data;
      } else {
        return {'success': true, 'data': response.data};
      }
    } else {
      if (response.data is Map<String, dynamic> && response.data['message'] != null) {
        throw Exception(response.data['message']);
      } else {
        throw Exception('Erro HTTP ${response.statusCode}');
      }
    }
  }
}