import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

class AppConfig {
  // URLs de configuração
  static const String _ngrokUrl = 'https://seu-ngrok-url.ngrok.io'; // Substitua pela sua URL do ngrok
  static const String _emulatorUrl = 'http://10.0.2.2:5000'; // Emulador Android
  static const String _physicalDeviceUrl = 'http://172.24.181.59:5000'; // IP da máquina para dispositivos físicos
  static const String _localhost = 'http://localhost:5000'; // Web
  static const String _productionUrl = 'https://api.playviagens.com'; // URL de produção futura
  
  // Configuração automática baseada no ambiente
  static String get baseUrl {
    // Prioridade 1: Produção (se definida)
    if (_isProduction) {
      return _productionUrl;
    }
    
    // Prioridade 2: ngrok para testes em redes diferentes
    if (_useNgrok) {
      return _ngrokUrl;
    }
    
    // Prioridade 3: Android - usar IP da máquina para dispositivos físicos
    if (!kIsWeb && Platform.isAndroid) {
      return _physicalDeviceUrl; // Usar IP da máquina para dispositivos físicos reais
    }
    
    // Prioridade 4: localhost para desenvolvimento web
    return _localhost;
  }
  
  static String get websocketUrl {
    return baseUrl;
  }
  
  // Flags de controle
  static const bool _isProduction = false; // Mude para true em produção
  static const bool _useNgrok = false;     // Mude para true para usar ngrok
  
  // Configurações adicionais
  static const int connectTimeout = 15000; // 15 segundos
  static const int receiveTimeout = 15000; // 15 segundos
  
  // App Information
  static const String appName = 'Play Viagens';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.playviagens.passageiro';
  
  // Feature flags para produção
  static const bool enableWebSocket = true;
  static const bool enablePushNotifications = true;
  static const bool enableCrashlytics = false; // Ativar em produção
  static const bool enableAnalytics = false;   // Ativar em produção
  

  static String _getPlatformName() {
    if (kIsWeb) return 'web';
    try {
      if (Platform.isAndroid) return 'android';
      if (Platform.isIOS) return 'ios';
      if (Platform.isWindows) return 'windows';
      if (Platform.isLinux) return 'linux';
      if (Platform.isMacOS) return 'macos';
      return 'unknown';
    } catch (e) {
      return 'unknown';
    }
  }
}