import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class WebSocketService {
  static WebSocketService? _instance;
  static WebSocketService get instance => _instance ??= WebSocketService._internal();
  
  late io.Socket _socket;
  bool _isConnected = false;
  final Map<String, StreamController> _controllers = {};
  
  WebSocketService._internal();
  
  Future<void> connect() async {
    if (_isConnected) return;
    
    // Disable WebSocket completely for Flutter Web and development
    if (kIsWeb) {
      print('🌐 [WebSocket] Disabled for Flutter Web');
      _isConnected = true; // Fake connection to prevent retries
      return;
    }
    
    // Skip WebSocket connection for development - backend doesn't have it configured yet
    print('🔌 [WebSocket] Connection disabled - backend not configured');
    _isConnected = true; // Fake connection to prevent retries
    return;
  }
  
  void _setupEventListeners() {
    // WebSocket disabled - no event listeners needed
    print('🔌 [WebSocket] Event listeners disabled');
  }
  
  void _emitEvent(String event, dynamic data) {
    // WebSocket disabled - no events to emit
    print('🔌 [WebSocket] Event emission disabled for: $event');
  }
  
  // Listen to specific events
  Stream<T> on<T>(String event) {
    if (!_controllers.containsKey(event)) {
      _controllers[event] = StreamController<T>.broadcast();
    }
    return _controllers[event]!.stream.cast<T>();
  }
  
  // Emit events to server
  void emit(String event, dynamic data) {
    print('🔌 [WebSocket] Emit disabled for: $event');
    // WebSocket disabled - no real emission
  }
  
  // Ride-specific methods
  void joinRideRoom(int rideId) {
    emit('join_ride_room', {'ride_id': rideId});
  }
  
  void leaveRideRoom(int rideId) {
    emit('leave_ride_room', {'ride_id': rideId});
  }
  
  void updateDriverLocation(double latitude, double longitude) {
    emit('driver_location_update', {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  void updatePassengerLocation(double latitude, double longitude) {
    emit('passenger_location_update', {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  void sendMessage({
    required int rideId,
    required String message,
    required String senderType, // 'driver' or 'passenger'
  }) {
    emit('send_message', {
      'ride_id': rideId,
      'message': message,
      'sender_type': senderType,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  void setDriverOnline() {
    emit('driver_online', {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  void setDriverOffline() {
    emit('driver_offline', {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  void disconnect() {
    print('🔌 [WebSocket] Disconnect called - cleaning up');
    _isConnected = false;
    
    // Close all stream controllers
    for (final controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
  }
  
  bool get isConnected => _isConnected;
}