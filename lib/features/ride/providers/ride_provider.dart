import 'package:flutter/material.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import '../../../core/services/websocket_service.dart';
import '../../../core/api/api_client.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/google_maps_service.dart';
import '../../../core/models/ride.dart';
import '../../../core/models/vehicle_category.dart';
import '../screens/ride_searching_screen.dart';
import '../screens/ride_tracking_uber_style_screen.dart';

class RideProvider with ChangeNotifier {
  final WebSocketService _webSocketService = WebSocketService.instance;
  final ApiClient _apiClient = ApiClient.instance;
  final AuthService _authService = AuthService.instance;
  
  List<VehicleCategory> _vehicleCategories = [];
  VehicleCategory? _selectedCategory;
  Ride? _currentRide;
  List<Ride> _rideHistory = [];
  bool _isLoading = false;
  String? _errorMessage;
  RouteInfo? _currentRoute;
  double _estimatedFare = 0.0;
  Map<String, dynamic>? _fareBreakdown;
  
  StreamSubscription? _rideEventsSubscription;
  StreamSubscription? _locationUpdatesSubscription;
  
  // Navigation context for automatic screen transitions
  BuildContext? _navigationContext;
  
  List<VehicleCategory> get vehicleCategories => _vehicleCategories;
  VehicleCategory? get selectedCategory => _selectedCategory;
  Ride? get currentRide => _currentRide;
  List<Ride> get rideHistory => _rideHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasActiveRide => _currentRide != null && !_currentRide!.isCompleted && !_currentRide!.isCancelled;
  RouteInfo? get currentRoute => _currentRoute;
  double get estimatedFare => _estimatedFare;
  Map<String, dynamic>? get fareBreakdown => _fareBreakdown;

  void selectCategory(VehicleCategory category) {
    _selectedCategory = category;
    notifyListeners();
  }
  
  void clearSelection() {
    _selectedCategory = null;
    notifyListeners();
  }
  
  Future<void> initialize() async {
    await loadVehicleCategories();
    await loadCurrentRide();
    await loadRideHistory();
    _setupWebSocketListeners();
  }
  
  Future<void> loadVehicleCategories() async {
    _setLoading(true);
    try {
      final response = await _apiClient.getVehicleCategories();
      if (response.statusCode == 200) {
        _vehicleCategories = (response.data as List)
            .map((json) => VehicleCategory.fromJson(json))
            .where((category) => category.isActive)
            .toList();
        
        if (_vehicleCategories.isNotEmpty) {
          _selectedCategory = _vehicleCategories.first;
        }
      }
    } catch (e) {
      // Fallback to demo data if API fails
      _loadDemoVehicleCategories();
      debugPrint('API failed, using demo data: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  void _loadDemoVehicleCategories() {
    _vehicleCategories = [
      VehicleCategory(
        id: 1,
        name: 'Economy',
        displayName: 'Economy',
        baseFare: '5.00',
        perKmRate: '2.50',
        perMinuteRate: '0.30',
        minimumFare: '8.00',
        maxCapacity: 4,
        isActive: true,
        iconUrl: '',
        description: 'Opção econômica',
      ),
      VehicleCategory(
        id: 2,
        name: 'Comfort',
        displayName: 'Comfort',
        baseFare: '8.00',
        perKmRate: '3.20',
        perMinuteRate: '0.45',
        minimumFare: '12.00',
        maxCapacity: 4,
        isActive: true,
        iconUrl: '',
        description: 'Viagem confortável',
      ),
      VehicleCategory(
        id: 3,
        name: 'Premium',
        displayName: 'Premium',
        baseFare: '12.00',
        perKmRate: '4.50',
        perMinuteRate: '0.60',
        minimumFare: '18.00',
        maxCapacity: 6,
        isActive: true,
        iconUrl: '',
        description: 'Máximo conforto',
      ),
    ];
    
    if (_vehicleCategories.isNotEmpty) {
      _selectedCategory = _vehicleCategories.first;
    }
    
    notifyListeners();
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
      // No current ride is acceptable
      print('No current ride or error loading: $e');
    }
    notifyListeners();
  }
  
  Future<void> loadRideHistory() async {
    try {
      final response = await _apiClient.getRideHistory();
      if (response.statusCode == 200) {
        _rideHistory = (response.data as List)
            .map((json) => Ride.fromServerResponse(json))
            .toList();
      }
    } catch (e) {
      print('Error loading ride history: $e');
    }
    notifyListeners();
  }
  
  void selectVehicleCategory(VehicleCategory category) {
    _selectedCategory = category;
    notifyListeners();
  }
  
  // Calculate route and fare estimate
  Future<void> calculateRouteAndFare({
    required double pickupLatitude,
    required double pickupLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
  }) async {
    if (_selectedCategory == null) return;
    
    try {
      // Get route information from Google Maps
      final route = await GoogleMapsService.getRouteInfo(
        originLat: pickupLatitude,
        originLng: pickupLongitude,
        destLat: destinationLatitude,
        destLng: destinationLongitude,
      );
      
      if (route != null) {
        _currentRoute = route;
        
        // Calculate passenger fare using Google Maps Service
        _estimatedFare = GoogleMapsService.calculatePassengerFareEstimate(
          distanceMeters: route.distanceValue,
          durationSeconds: route.durationValue,
          vehicleCategory: _selectedCategory!.name,
          surgePricing: 1.0, // Can be dynamic based on demand
        );
        
        // Get detailed fare breakdown
        _fareBreakdown = GoogleMapsService.getFareBreakdown(
          distanceMeters: route.distanceValue,
          durationSeconds: route.durationValue,
          vehicleCategory: _selectedCategory!.name,
          userType: 'passenger',
          surgePricing: 1.0,
        );
        
        notifyListeners();
      }
    } catch (e) {
      print('Erro ao calcular rota e tarifa: $e');
    }
  }

  Future<bool> requestRide({
    required String pickupAddress,
    required double pickupLatitude,
    required double pickupLongitude,
    required String destinationAddress,
    required double destinationLatitude,
    required double destinationLongitude,
    String? paymentMethod,
  }) async {
    if (_selectedCategory == null) {
      _setError('Selecione uma categoria de veículo');
      return false;
    }
    
    _setLoading(true);
    _clearError();
    
    print('🎯 [RIDE_PROVIDER] Requesting ride with category: ${_selectedCategory!.name} (ID: ${_selectedCategory!.id})');
    
    try {
      // First calculate route and fare
      await calculateRouteAndFare(
        pickupLatitude: pickupLatitude,
        pickupLongitude: pickupLongitude,
        destinationLatitude: destinationLatitude,
        destinationLongitude: destinationLongitude,
      );
      
      final response = await _apiClient.requestRide(
        pickupAddress: pickupAddress,
        pickupLatitude: pickupLatitude,
        pickupLongitude: pickupLongitude,
        destinationAddress: destinationAddress,
        destinationLatitude: destinationLatitude,
        destinationLongitude: destinationLongitude,
        vehicleCategory: _selectedCategory!.id,
        paymentMethod: paymentMethod,
        estimatedFare: _estimatedFare,
        estimatedDistance: _currentRoute?.distance,
        estimatedDuration: _currentRoute?.duration,
      );
      
      if (response.statusCode == 201) {
        print('✅ [RIDE_PROVIDER] Ride created successfully, response: ${response.data}');
        try {
          _currentRide = Ride.fromServerResponse(response.data);
          print('✅ [RIDE_PROVIDER] Ride object created: ${_currentRide!.id}');
          _webSocketService.joinRideRoom(_currentRide!.id);
          
          // Navigate to searching screen after successful ride creation
          _navigateToSearchingScreen();
          
          return true;
        } catch (parseError) {
          print('❌ [RIDE_PROVIDER] Failed to parse ride response: $parseError');
          print('❌ [RIDE_PROVIDER] Response data: ${response.data}');
          _setError('Erro ao processar resposta da corrida: $parseError');
          return false;
        }
      } else {
        _setError(response.data['message'] ?? 'Erro ao solicitar corrida');
        return false;
      }
    } catch (e) {
      _setError('Erro ao solicitar corrida: $e');
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
        await loadRideHistory();
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
  
  Future<bool> acceptRide(int rideId) async {
    _setLoading(true);
    try {
      final response = await _apiClient.acceptRide(rideId, driverId: _authService.currentUser!.id);
      if (response.statusCode == 200) {
        _currentRide = Ride.fromServerResponse(response.data);
        _webSocketService.joinRideRoom(_currentRide!.id);
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
        _webSocketService.leaveRideRoom(_currentRide!.id);
        await loadRideHistory();
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
  
  Future<bool> rateRide(int rideId, double rating, {String? comment}) async {
    _setLoading(true);
    try {
      final response = await _apiClient.rateRide(
        rideId,
        rating: rating,
        comment: comment,
      );
      
      if (response.statusCode == 200) {
        await loadRideHistory();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Erro ao avaliar corrida: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  void _setupWebSocketListeners() {
    print('🔌 [RIDE_PROVIDER] Setting up WebSocket listeners for real-time ride updates');
    
    // Listen to ride accepted events
    _rideEventsSubscription = _webSocketService.on<Map<String, dynamic>>('ride_accepted').listen((data) {
      print('✅ [RIDE_PROVIDER] Ride accepted event received: $data');
      if (_currentRide?.id == data['ride_id']) {
        _currentRide = _currentRide!.copyWith(
          status: 'accepted',
          acceptedAt: DateTime.now(),
          driverId: data['driver_id'],
        );
        notifyListeners();
        
        // Navigate to tracking screen when ride is accepted
        _navigateToTrackingScreen();
      }
    });
    
    // Listen to ride started events
    _webSocketService.on<Map<String, dynamic>>('ride_started').listen((data) {
      print('🚗 [RIDE_PROVIDER] Ride started event received: $data');
      if (_currentRide?.id == data['ride_id']) {
        _currentRide = _currentRide!.copyWith(
          status: 'in_progress',
          startedAt: DateTime.now(),
        );
        notifyListeners();
        
        // Update tracking screen if already there, no navigation needed
        print('🚗 [RIDE_PROVIDER] Ride status updated to in_progress');
      }
    });
    
    // Listen to ride completed events
    _webSocketService.on<Map<String, dynamic>>('ride_completed').listen((data) {
      print('🏁 [RIDE_PROVIDER] Ride completed event received: $data');
      if (_currentRide?.id == data['ride_id']) {
        _currentRide = _currentRide!.copyWith(
          status: 'completed',
          completedAt: DateTime.now(),
        );
        notifyListeners();
        
        // Show rating dialog automatically after 2 seconds
        Timer(const Duration(seconds: 2), () {
          if (_currentRide?.status == 'completed' && _navigationContext != null) {
            _showAutomaticRatingDialog();
          }
        });
        
        // Auto-clear ride after rating or 30 seconds
        Timer(const Duration(seconds: 30), () {
          if (_currentRide?.isCompleted == true) {
            _currentRide = null;
            notifyListeners();
            _navigateToHome();
          }
        });
      }
    });
    
    // Listen to ride cancelled events
    _webSocketService.on<Map<String, dynamic>>('ride_cancelled').listen((data) {
      print('❌ [RIDE_PROVIDER] Ride cancelled event received: $data');
      if (_currentRide?.id == data['ride_id']) {
        _currentRide = _currentRide!.copyWith(
          status: 'cancelled',
          cancelledAt: DateTime.now(),
        );
        notifyListeners();
        
        // Show cancellation message and navigate back
        _showCancellationMessage();
        
        // Auto-clear after 3 seconds and navigate home
        Timer(const Duration(seconds: 3), () {
          if (_currentRide?.isCancelled == true) {
            _currentRide = null;
            notifyListeners();
            _navigateToHome();
          }
        });
      }
    });
    
    // Listen to driver location updates
    _webSocketService.on<Map<String, dynamic>>('driver_location_updated').listen((data) {
      if (_currentRide?.id == data['ride_id'] && _currentRide?.status == 'accepted') {
        // Update driver location for real-time tracking
        print('📍 [RIDE_PROVIDER] Driver location updated: lat=${data['latitude']}, lng=${data['longitude']}');
        // This would update the map in real-time
        notifyListeners();
      }
    });
  }
  
  void _navigateToSearchingScreen() {
    // Add delay to ensure widget is properly mounted before navigation
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_navigationContext != null && _navigationContext!.mounted) {
        print('🔍 [RIDE_PROVIDER] Navigating to searching screen');
        // Use pushReplacement to avoid widget mounting issues
        Navigator.of(_navigationContext!).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const RideSearchingScreen(),
          ),
        );
      } else {
        print('❌ [RIDE_PROVIDER] Navigation context not available for searching screen');
      }
    });
  }
  
  void _navigateToTrackingScreen() {
    // Add small delay to ensure previous navigation is complete
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_navigationContext != null && _navigationContext!.mounted) {
        print('🧭 [RIDE_PROVIDER] Navigating to tracking screen');
        Navigator.of(_navigationContext!).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const RideTrackingUberStyleScreen(),
          ),
        );
      }
    });
  }
  
  void _navigateToHome() {
    if (_navigationContext != null && _navigationContext!.mounted) {
      print('🏠 [RIDE_PROVIDER] Navigating back to home');
      Navigator.of(_navigationContext!).popUntil((route) => route.isFirst);
    }
  }
  
  void _showAutomaticRatingDialog() {
    if (_navigationContext != null && _navigationContext!.mounted) {
      print('⭐ [RIDE_PROVIDER] Showing automatic rating dialog');
      showDialog(
        context: _navigationContext!,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text(
            'Corrida finalizada!',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Como foi sua viagem? Avalie o motorista.',
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to rating screen or show rating widget
                _showRatingWidget();
              },
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF00FF00)),
              child: const Text('Avaliar agora', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _currentRide = null;
                notifyListeners();
                _navigateToHome();
              },
              child: const Text('Pular', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      );
    }
  }
  
  void _showRatingWidget() {
    // This would show the rating component that's already in RideTrackingUberStyleScreen
    // For now, we'll just show a simple rating dialog
    if (_navigationContext != null && _navigationContext!.mounted) {
      showDialog(
        context: _navigationContext!,
        barrierDismissible: false,
        builder: (context) => _RatingDialog(rideProvider: this),
      );
    }
  }
  
  void _showCancellationMessage() {
    if (_navigationContext != null && _navigationContext!.mounted) {
      ScaffoldMessenger.of(_navigationContext!).showSnackBar(
        const SnackBar(
          content: Text('Corrida cancelada'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
  
  double calculateEstimatedFare(double distanceKm) {
    if (_selectedCategory == null) return 0.0;
    
    double fare = _selectedCategory!.baseFareValue + 
                  (distanceKm * _selectedCategory!.perKmRateValue);
    
    return fare < _selectedCategory!.minimumFareValue 
        ? _selectedCategory!.minimumFareValue 
        : fare;
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
  
  // Set navigation context for automatic screen transitions
  void setNavigationContext(BuildContext context) {
    _navigationContext = context;
  }
  
  // Clear navigation context
  void clearNavigationContext() {
    _navigationContext = null;
  }
  
  // Schedule a ride for later
  Future<void> scheduleRide({
    required String pickupAddress,
    required String destinationAddress,
    required DateTime scheduledTime,
    required String vehicleType,
    required String paymentMethod,
    String? notes,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiClient.scheduleRide(
        pickupAddress: pickupAddress,
        destinationAddress: destinationAddress,
        scheduledTime: scheduledTime,
        vehicleType: vehicleType,
        paymentMethod: paymentMethod,
        notes: notes,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [RIDE_PROVIDER] Ride scheduled successfully');
        // Optionally reload scheduled rides list
        // await loadScheduledRides();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to schedule ride');
      }
    } catch (e) {
      print('❌ [RIDE_PROVIDER] Error scheduling ride: $e');
      _setError('Erro ao agendar corrida: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  @override
  void dispose() {
    _rideEventsSubscription?.cancel();
    _locationUpdatesSubscription?.cancel();
    super.dispose();
  }
}

// Simple rating dialog component for automatic rating
class _RatingDialog extends StatefulWidget {
  final RideProvider rideProvider;

  const _RatingDialog({required this.rideProvider});

  @override
  State<_RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<_RatingDialog> {
  double _rating = 5.0;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Driver info
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF00FF00),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FF00).withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                color: Colors.black,
                size: 40,
              ),
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              'Como foi sua viagem?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Star rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _rating = (index + 1).toDouble();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: const Color(0xFF00FF00),
                      size: 40,
                    ),
                  ),
                );
              }),
            ),
            
            const SizedBox(height: 24),
            
            // Comment field
            TextField(
              controller: _commentController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Deixe um comentário (opcional)',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade600),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF00FF00)),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Submit button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => _submitRating(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FF00),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Enviar Avaliação',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitRating() async {
    if (widget.rideProvider._currentRide != null) {
      await widget.rideProvider.rateRide(
        widget.rideProvider._currentRide!.id,
        _rating,
        comment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
      );
    }
    
    Navigator.pop(context);
    widget.rideProvider._currentRide = null;
    widget.rideProvider.notifyListeners();
    widget.rideProvider._navigateToHome();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Obrigado pela avaliação!'),
        backgroundColor: Color(0xFF00FF00),
      ),
    );
  }
}