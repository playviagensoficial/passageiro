import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/api/api_client.dart';

class PushNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  static String? _fcmToken;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      // Request permission
      await _requestPermissions();
      
      // Initialize local notifications
      await _initializeLocalNotifications();
      
      // Get FCM token
      _fcmToken = await _messaging.getToken();
      print('📱 FCM Token: ${_fcmToken?.substring(0, 20)}...');
      
      // Register token with server
      if (_fcmToken != null) {
        await _registerTokenWithServer(_fcmToken!);
      }
      
      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) async {
        _fcmToken = newToken;
        await _registerTokenWithServer(newToken);
      });
      
      // Configure message handlers
      await _configureMessageHandlers();
      
      _initialized = true;
      print('✅ Push notifications inicializadas');
      
    } catch (error) {
      print('❌ Erro ao inicializar push notifications: $error');
    }
  }

  static Future<void> _requestPermissions() async {
    // Request notification permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Permissão de notificação concedida');
    } else {
      print('❌ Permissão de notificação negada');
    }

    // For Android, also request system notification permission
    if (!kIsWeb && Platform.isAndroid) {
      await Permission.notification.request();
    }
  }

  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    if (!kIsWeb && Platform.isAndroid) {
      await _createNotificationChannels();
    }
  }

  static Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel rideChannel = AndroidNotificationChannel(
      'ride_notifications',
      'Notificações de Corrida',
      description: 'Notificações sobre solicitações e status de corridas',
      importance: Importance.high,
      playSound: true,
    );

    const AndroidNotificationChannel promoChannel = AndroidNotificationChannel(
      'promotion_notifications',
      'Ofertas e Promoções',
      description: 'Notificações sobre descontos e ofertas especiais',
      importance: Importance.defaultImportance,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(rideChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(promoChannel);
  }

  static Future<void> _configureMessageHandlers() async {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📨 Mensagem recebida em foreground: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // Handle background message tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📨 App aberto via notificação: ${message.notification?.title}');
      _handleMessageTap(message);
    });

    // Check if app was opened from a notification (cold start)
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      print('📨 App iniciado via notificação: ${initialMessage.notification?.title}');
      _handleMessageTap(initialMessage);
    }
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'ride_notifications',
      'Notificações de Corrida',
      channelDescription: 'Notificações sobre corridas',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Play Viagens',
      message.notification?.body ?? 'Nova notificação',
      platformChannelSpecifics,
      payload: message.data.toString(),
    );
  }

  static void _onNotificationTapped(NotificationResponse response) {
    print('📱 Notificação local tocada: ${response.payload}');
    // Handle local notification tap
    // Navigate to appropriate screen based on notification data
  }

  static void _handleMessageTap(RemoteMessage message) {
    print('📱 Notificação push tocada: ${message.data}');
    
    final data = message.data;
    final type = data['type'];
    
    switch (type) {
      case 'ride_request':
      case 'ride_accepted':
      case 'ride_started':
      case 'ride_completed':
        // Navigate to ride screen
        _navigateToRide(data['rideId']);
        break;
      case 'promotion':
        // Navigate to promotions screen
        _navigateToPromotions();
        break;
      default:
        // Navigate to home
        _navigateToHome();
    }
  }

  static void _navigateToRide(String? rideId) {
    // TODO: Implement navigation to ride screen
    print('🚗 Navegando para corrida: $rideId');
  }

  static void _navigateToPromotions() {
    // TODO: Implement navigation to promotions screen
    print('🎁 Navegando para promoções');
  }

  static void _navigateToHome() {
    // TODO: Implement navigation to home screen
    print('🏠 Navegando para home');
  }

  static Future<void> _registerTokenWithServer(String token) async {
    try {
      // Register FCM token with your backend
      await ApiClient.instance.registerFCMToken(
        token: token,
        platform: _getPlatformName(),
        deviceId: await _getDeviceId(),
        appVersion: '1.0.0',
      );
      print('✅ Token FCM registrado no servidor');
    } catch (error) {
      print('❌ Erro ao registrar token FCM: $error');
    }
  }

  static Future<String> _getDeviceId() async {
    // Simple device identification
    return '${_getPlatformName()}_device';
  }

  static String _getPlatformName() {
    if (kIsWeb) return 'web';
    try {
      return Platform.isAndroid ? 'android' : 'ios';
    } catch (e) {
      return 'unknown';
    }
  }

  // Public methods for manual notification testing
  static Future<void> sendTestNotification() async {
    await _localNotifications.show(
      999,
      '🧪 Teste - Play Viagens',
      'Esta é uma notificação de teste!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'ride_notifications',
          'Notificações de Corrida',
          importance: Importance.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
    );
  }

  static String? get fcmToken => _fcmToken;
  static bool get isInitialized => _initialized;

  // Method to unregister notifications (for logout)
  static Future<void> unregister() async {
    if (_fcmToken != null) {
      try {
        await ApiClient.instance.unregisterFCMToken(_fcmToken!);
        print('✅ Token FCM removido do servidor');
      } catch (error) {
        print('❌ Erro ao remover token FCM: $error');
      }
    }
    
    _fcmToken = null;
    _initialized = false;
  }
}