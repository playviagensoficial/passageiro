import 'package:flutter/material.dart';
import 'dart:async';
import '../../../core/services/websocket_service.dart';
import '../../../core/api/api_client.dart';
import '../../../core/services/location_service.dart';
import '../../../core/models/ride.dart';
import '../../../core/models/driver_profile.dart';

class DriverProvider with ChangeNotifier {
  final WebSocketService _webSocketService = WebSocketService.instance;
  final ApiClient _apiClient = ApiClient.instance;
  final LocationService _locationService = LocationService.instance;
  
  DriverProfile? _profile;
  List<Ride> _availableRides = [];
  Ride? _currentRide;
  bool _isOnline = false;
  bool _isLoading = false;
  String? _errorMessage;
  double _dailyEarnings = 0.0;
  int _dailyRides = 0;
  Duration _onlineTime = Duration.zero;
  
  StreamSubscription? _rideEventsSubscription;
  StreamSubscription? _locationTrackingSubscription;
  Timer? _onlineTimer;
  DateTime? _onlineStartTime;
  
  DriverProfile? get profile => _profile;
  List<Ride> get availableRides => _availableRides;
  Ride? get currentRide => _currentRide;
  bool get isOnline => _isOnline;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get dailyEarnings => _dailyEarnings;
  int get dailyRides => _dailyRides;
  Duration get onlineTime => _onlineTime;
  bool get hasActiveRide => _currentRide != null && 
                           !_currentRide!.isCompleted && 
                           !_currentRide!.isCancelled;
  
  Future<void> initialize() async {
    await loadProfile();
    await loadCurrentRide();
    _setupWebSocketListeners();
  }
  
  Future<void> loadProfile() async {
    _setLoading(true);
    try {
      final response = await _apiClient.getUserProfile();
      if (response.statusCode == 200) {
        // TODO: Parse driver profile from response
        // _profile = DriverProfile.fromJson(response.data);
      }
    } catch (e) {
      _setError('Erro ao carregar perfil: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> loadCurrentRide() async {
    try {
      final response = await _apiClient.getCurrentRide();
      if (response.statusCode == 200 && response.data != null) {
        _currentRide = Ride.fromServerResponse(response.data);
        if (_currentRide != null) {
          _webSocketService.joinRideRoom(_currentRide!.id);
        }
      }
    } catch (e) {
      print('No current ride or error loading: $e');
    }
    notifyListeners();
  }
  
  Future<void> toggleOnlineStatus() async {
    _setLoading(true);
    try {
      final newStatus = !_isOnline;
      final response = await _apiClient.setDriverOnlineStatus(newStatus);
      
      if (response.statusCode == 200) {
        _isOnline = newStatus;
        
        if (_isOnline) {
          _goOnline();
        } else {
          _goOffline();
        }
        
        notifyListeners();
      }
    } catch (e) {
      _setError('Erro ao alterar status: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  void _goOnline() {
    _onlineStartTime = DateTime.now();
    _startLocationTracking();
    _startOnlineTimer();
    _webSocketService.setDriverOnline();
  }
  
  void _goOffline() {
    _stopLocationTracking();
    _stopOnlineTimer();
    _webSocketService.setDriverOffline();
    _availableRides.clear();
    notifyListeners();
  }
  
  void _startLocationTracking() {
    _locationService.startLocationTracking();
    
    _locationTrackingSubscription = _locationService.getPositionStream().listen(
      (position) async {
        // Update location on server
        try {
          await _apiClient.updateDriverLocation(
            latitude: position.latitude,
            longitude: position.longitude,
          );
          
          // Update via WebSocket for real-time tracking
          _webSocketService.updateDriverLocation(
            position.latitude,
            position.longitude,
          );
        } catch (e) {
          print('Error updating location: $e');
        }
      },
    );
  }
  
  void _stopLocationTracking() {
    _locationService.stopLocationTracking();
    _locationTrackingSubscription?.cancel();
  }
  
  void _startOnlineTimer() {
    _onlineTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_onlineStartTime != null) {
        _onlineTime = DateTime.now().difference(_onlineStartTime!);
        notifyListeners();
      }
    });
  }
  
  void _stopOnlineTimer() {
    _onlineTimer?.cancel();
    if (_onlineStartTime != null) {
      _onlineTime += DateTime.now().difference(_onlineStartTime!);
    }
  }
  
  void _setupWebSocketListeners() {
    // Listen to new ride requests
    _rideEventsSubscription = _webSocketService.on<Map<String, dynamic>>('ride_request').listen((data) {
      if (_isOnline && !hasActiveRide) {
        final ride = Ride.fromServerResponse(data);
        _availableRides.add(ride);
        notifyListeners();
        
        // Auto-remove after 15 seconds
        Timer(const Duration(seconds: 15), () {
          _availableRides.removeWhere((r) => r.id == ride.id);
          notifyListeners();
        });
      }
    });
    
    _webSocketService.on<Map<String, dynamic>>('ride_cancelled').listen((data) {
      final rideId = data['ride_id'];
      _availableRides.removeWhere((r) => r.id == rideId);
      
      if (_currentRide?.id == rideId) {
        _currentRide = null;
      }
      
      notifyListeners();
    });
  }
  
  Future<bool> acceptRide(Ride ride) async {
    _setLoading(true);
    try {
      final response = await _apiClient.acceptRide(ride.id, driverId: _profile!.userId);
      
      if (response.statusCode == 200) {
        _currentRide = Ride.fromServerResponse(response.data);
        _availableRides.clear();
        _webSocketService.joinRideRoom(_currentRide!.id);
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _setError('Erro ao aceitar corrida: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> startRide() async {
    if (_currentRide == null) return false;
    
    _setLoading(true);
    try {
      final response = await _apiClient.startRide(_currentRide!.id);
      
      if (response.statusCode == 200) {
        _currentRide = Ride.fromServerResponse(response.data);
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _setError('Erro ao iniciar corrida: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> completeRide() async {
    if (_currentRide == null) return false;
    
    _setLoading(true);
    try {
      final response = await _apiClient.completeRide(_currentRide!.id);
      
      if (response.statusCode == 200) {
        final completedRide = Ride.fromServerResponse(response.data);
        
        // Update daily stats
        if (completedRide.fare != null) {
          _dailyEarnings += completedRide.fare!;
        }
        _dailyRides++;
        
        _webSocketService.leaveRideRoom(_currentRide!.id);
        _currentRide = null;
        
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _setError('Erro ao completar corrida: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> cancelRide() async {
    if (_currentRide == null) return false;
    
    _setLoading(true);
    try {
      final response = await _apiClient.cancelRide(_currentRide!.id);
      
      if (response.statusCode == 200) {
        _webSocketService.leaveRideRoom(_currentRide!.id);
        _currentRide = null;
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _setError('Erro ao cancelar corrida: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  void dismissRide(Ride ride) {
    _availableRides.removeWhere((r) => r.id == ride.id);
    notifyListeners();
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
  
  @override
  void dispose() {
    _rideEventsSubscription?.cancel();
    _locationTrackingSubscription?.cancel();
    _onlineTimer?.cancel();
    _stopLocationTracking();
    super.dispose();
  }
}