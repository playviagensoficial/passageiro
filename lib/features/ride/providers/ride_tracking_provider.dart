import 'package:flutter/material.dart';
import 'dart:async';
import '../../../core/services/websocket_service.dart';
import '../../../core/api/api_client.dart';
import '../../../core/models/driver.dart';
import '../../../core/models/chat_message.dart';

class RideTrackingProvider with ChangeNotifier {
  final WebSocketService _webSocketService = WebSocketService.instance;
  final ApiClient _apiClient = ApiClient.instance;
  
  Driver? _driver;
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _locationUpdateTimer;
  
  // Quick message templates
  final List<String> _quickMessages = [
    'Estou chegando',
    'Já estou no local',
    'Pode descer',
    'Chegamos ao destino',
    'Obrigado pela viagem',
    'Avalie sua corrida',
  ];
  
  Driver? get driver => _driver;
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<String> get quickMessages => _quickMessages;

  Future<void> initializeRideTracking(int rideId, int driverId) async {
    _setLoading(true);
    _clearError();
    
    try {
      // Load driver information
      await _loadDriverInfo(driverId);
      
      // Load chat messages
      await _loadChatMessages(rideId);
      
      // Setup WebSocket listeners for real-time updates
      _setupWebSocketListeners(rideId);
      
      // Start location updates
      _startLocationUpdates(rideId);
      
    } catch (e) {
      _setError('Erro ao carregar informações da corrida: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> _loadDriverInfo(int driverId) async {
    try {
      // For now, using demo data. In production, this would be an API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      _driver = Driver(
        id: driverId,
        name: 'João Silva',
        email: 'joao@email.com',
        phoneNumber: '11987654321',
        profilePhotoUrl: null,
        rating: 4.8,
        totalRides: 1247,
        licenseNumber: '12345678901',
        vehicleId: 1,
        vehiclePlate: 'ABC-1234',
        vehicleModel: 'Honda Civic',
        vehicleColor: 'Branco',
        vehiclePhotoUrl: null,
        currentLatitude: -23.5505,
        currentLongitude: -46.6333,
        isOnline: true,
        isAvailable: false,
      );
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading driver info: $e');
    }
  }
  
  Future<void> _loadChatMessages(int rideId) async {
    try {
      // For now, using demo data. In production, this would be an API call
      await Future.delayed(const Duration(milliseconds: 300));
      
      _messages = [
        ChatMessage(
          id: 1,
          rideId: rideId,
          senderId: _driver?.id ?? 1,
          senderType: 'driver',
          message: 'Oi! Sou o João, seu motorista. Já estou a caminho!',
          isAutomatic: true,
          createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
        ChatMessage(
          id: 2,
          rideId: rideId,
          senderId: _driver?.id ?? 1,
          senderType: 'driver',
          message: 'Previsão de chegada: 3 minutos',
          isAutomatic: true,
          createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
        ),
      ];
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading chat messages: $e');
    }
  }
  
  void _setupWebSocketListeners(int rideId) {
    // Listen for driver location updates
    _webSocketService.on<Map<String, dynamic>>('driver_location_update').listen((data) {
      if (data['ride_id'] == rideId && _driver != null) {
        _driver = _driver!.copyWith(
          currentLatitude: data['latitude']?.toDouble(),
          currentLongitude: data['longitude']?.toDouble(),
        );
        notifyListeners();
      }
    });
    
    // Listen for new chat messages
    _webSocketService.on<Map<String, dynamic>>('new_chat_message').listen((data) {
      if (data['ride_id'] == rideId) {
        final message = ChatMessage.fromJson(data);
        _messages.add(message);
        notifyListeners();
      }
    });
    
    // Listen for ride status changes
    _webSocketService.on<Map<String, dynamic>>('ride_status_changed').listen((data) {
      if (data['ride_id'] == rideId) {
        _sendAutomaticMessage(rideId, data['status']);
      }
    });
  }
  
  void _startLocationUpdates(int rideId) {
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      // In a real app, this would request updated location from the server
      if (_driver != null) {
        // Simulate small location changes
        final randomLat = (_driver!.currentLatitude ?? -23.5505) + 
                         (DateTime.now().millisecondsSinceEpoch % 1000 - 500) / 100000;
        final randomLng = (_driver!.currentLongitude ?? -46.6333) + 
                         (DateTime.now().millisecondsSinceEpoch % 1000 - 500) / 100000;
        
        _driver = _driver!.copyWith(
          currentLatitude: randomLat,
          currentLongitude: randomLng,
        );
        notifyListeners();
      }
    });
  }
  
  Future<void> sendMessage(int rideId, String message) async {
    try {
      final newMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch,
        rideId: rideId,
        senderId: 1, // Current user ID
        senderType: 'passenger',
        message: message,
        isAutomatic: false,
        createdAt: DateTime.now(),
      );
      
      _messages.add(newMessage);
      notifyListeners();
      
      // In production, send to server via WebSocket
      _webSocketService.emit('send_chat_message', {
        'ride_id': rideId,
        'message': message,
        'sender_type': 'passenger',
      });
      
    } catch (e) {
      _setError('Erro ao enviar mensagem: $e');
    }
  }
  
  Future<void> sendQuickMessage(int rideId, String quickMessage) async {
    await sendMessage(rideId, quickMessage);
  }
  
  void _sendAutomaticMessage(int rideId, String status) {
    String message = '';
    
    switch (status) {
      case 'accepted':
        message = 'Corrida aceita! Estou a caminho.';
        break;
      case 'arrived':
        message = 'Chegamos ao local de embarque!';
        break;
      case 'in_progress':
        message = 'Viagem iniciada. Destino: ${_getCurrentDestination()}';
        break;
      case 'completed':
        message = 'Viagem concluída. Obrigado por escolher nossos serviços!';
        break;
      default:
        return;
    }
    
    final automaticMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch,
      rideId: rideId,
      senderId: _driver?.id ?? 1,
      senderType: 'driver',
      message: message,
      isAutomatic: true,
      createdAt: DateTime.now(),
    );
    
    _messages.add(automaticMessage);
    notifyListeners();
  }
  
  String _getCurrentDestination() {
    // In a real app, this would come from the current ride data
    return 'Av. Paulista, 1000';
  }
  
  Future<void> callDriver() async {
    if (_driver != null) {
      // In a real app, this would initiate a phone call
      debugPrint('Calling driver: ${_driver!.formattedPhone}');
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
  
  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    super.dispose();
  }
}