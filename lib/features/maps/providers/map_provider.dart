import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/services/location_service.dart';
import '../../../core/models/ride.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MapProvider with ChangeNotifier {
  final LocationService _locationService = LocationService.instance;
  static const String _googleMapsApiKey = 'AIzaSyCz9sfN_WuNMY7LmMAB0HgOvKHlhd4j5hg';
  
  LatLng? _currentLocation;
  LatLng? _pickupLocation;
  LatLng? _destinationLocation;
  String? _pickupAddress;
  String? _destinationAddress;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isLoading = false;
  String? _errorMessage;
  
  // Route data
  double? _routeDistance; // in kilometers
  int? _routeDuration; // in minutes
  List<LatLng> _routePoints = [];
  
  LatLng? get currentLocation => _currentLocation;
  LatLng? get pickupLocation => _pickupLocation;
  LatLng? get destinationLocation => _destinationLocation;
  String? get pickupAddress => _pickupAddress;
  String? get destinationAddress => _destinationAddress;
  Set<Marker> get markers => _markers;
  Set<Polyline> get polylines => _polylines;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double? get routeDistance => _routeDistance;
  int? get routeDuration => _routeDuration;
  
  Future<void> getCurrentLocation() async {
    _setLoading(true);
    _clearError();
    
    try {
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        _currentLocation = LatLng(position.latitude, position.longitude);
        await _updateCurrentLocationMarker();
        notifyListeners();
      } else {
        _setError('Não foi possível obter a localização atual');
      }
    } catch (e) {
      _setError('Erro ao obter localização: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> setPickupLocation(LatLng location) async {
    _pickupLocation = location;
    
    // Get address from coordinates
    final address = await _locationService.getAddressFromCoordinates(
      location.latitude,
      location.longitude,
    );
    _pickupAddress = address ?? 'Endereço não encontrado';
    
    await _updateMarkers();
    notifyListeners();
  }
  
  // Public method to get address from coordinates
  Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    return await _locationService.getAddressFromCoordinates(latitude, longitude);
  }

  Future<void> setDestinationLocation(LatLng location) async {
    _destinationLocation = location;
    
    // Get address from coordinates
    final address = await _locationService.getAddressFromCoordinates(
      location.latitude,
      location.longitude,
    );
    _destinationAddress = address ?? 'Endereço não encontrado';
    
    await _updateMarkers();
    notifyListeners();
  }
  
  Future<void> setPickupAddress(String address) async {
    _setLoading(true);
    try {
      final locations = await _locationService.getCoordinatesFromAddress(address);
      if (locations != null && locations.isNotEmpty) {
        _pickupLocation = LatLng(locations.first.latitude, locations.first.longitude);
        _pickupAddress = address;
        await _updateMarkers();
      } else {
        _setError('Endereço de origem não encontrado');
      }
    } catch (e) {
      _setError('Erro ao buscar endereço de origem: $e');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }
  
  Future<void> setDestinationAddress(String address) async {
    _setLoading(true);
    try {
      final locations = await _locationService.getCoordinatesFromAddress(address);
      if (locations != null && locations.isNotEmpty) {
        _destinationLocation = LatLng(locations.first.latitude, locations.first.longitude);
        _destinationAddress = address;
        await _updateMarkers();
      } else {
        _setError('Endereço de destino não encontrado');
      }
    } catch (e) {
      _setError('Erro ao buscar endereço de destino: $e');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }
  
  Future<void> _updateCurrentLocationMarker() async {
    if (_currentLocation == null) return;
    
    final marker = Marker(
      markerId: const MarkerId('current_location'),
      position: _currentLocation!,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: const InfoWindow(title: 'Sua localização'),
    );
    
    _markers = _markers.where((m) => m.markerId.value != 'current_location').toSet();
    _markers.add(marker);
  }
  
  Future<void> _updateMarkers() async {
    Set<Marker> newMarkers = {};
    
    // Add current location marker if exists
    if (_currentLocation != null) {
      newMarkers.add(Marker(
        markerId: const MarkerId('current_location'),
        position: _currentLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Sua localização'),
      ));
    }
    
    // Add pickup marker if exists
    if (_pickupLocation != null) {
      newMarkers.add(Marker(
        markerId: const MarkerId('pickup'),
        position: _pickupLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: 'Origem', snippet: _pickupAddress),
      ));
    }
    
    // Add destination marker if exists
    if (_destinationLocation != null) {
      newMarkers.add(Marker(
        markerId: const MarkerId('destination'),
        position: _destinationLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: 'Destino', snippet: _destinationAddress),
      ));
    }
    
    _markers = newMarkers;
  }
  
  void addDriverMarker(int driverId, LatLng position, String driverName) {
    final marker = Marker(
      markerId: MarkerId('driver_$driverId'),
      position: position,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      infoWindow: InfoWindow(title: 'Motorista', snippet: driverName),
    );
    
    _markers = _markers.where((m) => m.markerId.value != 'driver_$driverId').toSet();
    _markers.add(marker);
    notifyListeners();
  }
  
  void removeDriverMarker(int driverId) {
    _markers = _markers.where((m) => m.markerId.value != 'driver_$driverId').toSet();
    notifyListeners();
  }
  
  void updateRideRoute(Ride ride) {
    // Clear existing route
    _polylines.clear();
    
    // Add route polyline (simplified - in real app, use Google Directions API)
    if (_pickupLocation != null && _destinationLocation != null) {
      final polyline = Polyline(
        polylineId: const PolylineId('route'),
        points: [_pickupLocation!, _destinationLocation!],
        color: const Color(0xFF00CC00),
        width: 5,
      );
      _polylines.add(polyline);
    }
    
    notifyListeners();
  }
  
  double? calculateDistance() {
    if (_routeDistance != null) {
      return _routeDistance; // Return real distance from Google Maps API
    }
    
    // Fallback to straight-line distance if route not calculated yet
    if (_pickupLocation == null || _destinationLocation == null) return null;
    
    return _locationService.calculateDistance(
      _pickupLocation!.latitude,
      _pickupLocation!.longitude,
      _destinationLocation!.latitude,
      _destinationLocation!.longitude,
    ) / 1000; // Convert to kilometers
  }
  
  Future<void> calculateRoute() async {
    if (_pickupLocation == null || _destinationLocation == null) return;
    
    try {
      _setLoading(true);
      
      final String origin = '${_pickupLocation!.latitude},${_pickupLocation!.longitude}';
      final String destination = '${_destinationLocation!.latitude},${_destinationLocation!.longitude}';
      
      final String url = 'https://maps.googleapis.com/maps/api/directions/json?'
          'origin=$origin'
          '&destination=$destination'
          '&key=$_googleMapsApiKey'
          '&mode=driving'
          '&traffic_model=best_guess'
          '&departure_time=now';
      
      final response = await http.get(Uri.parse(url));
      
      debugPrint('Directions API URL: $url');
      debugPrint('Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        debugPrint('API Response status: ${data['status']}');
        
        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final leg = route['legs'][0];
          
          // Extract distance and duration
          _routeDistance = (leg['distance']['value'] / 1000).toDouble(); // Convert to km
          _routeDuration = (leg['duration']['value'] / 60).round(); // Convert to minutes
          
          // Extract route points for polyline
          final String encodedPolyline = route['overview_polyline']['points'];
          _routePoints = _decodePolyline(encodedPolyline);
          
          // Update polyline with actual route
          _updateRoutePolyline();
          
          debugPrint('Route calculated: ${_routeDistance?.toStringAsFixed(2)} km, ${_routeDuration} minutes');
        } else {
          String errorMsg = 'Não foi possível calcular a rota';
          
          // Handle specific Google Maps API errors
          switch (data['status']) {
            case 'NOT_FOUND':
              errorMsg = 'Endereço não encontrado';
              break;
            case 'ZERO_RESULTS':
              errorMsg = 'Nenhuma rota encontrada entre os endereços';
              break;
            case 'MAX_WAYPOINTS_EXCEEDED':
              errorMsg = 'Muitos pontos de parada';
              break;
            case 'INVALID_REQUEST':
              errorMsg = 'Requisição inválida';
              break;
            case 'OVER_QUERY_LIMIT':
              errorMsg = 'Limite de consultas excedido';
              break;
            case 'REQUEST_DENIED':
              errorMsg = 'API key inválida ou serviço não habilitado';
              break;
            case 'UNKNOWN_ERROR':
              errorMsg = 'Erro interno do Google Maps';
              break;
          }
          
          _setError(errorMsg);
          debugPrint('Google Maps API error: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}');
          debugPrint('Full response: ${response.body}');
        }
      } else {
        _setError('Erro na conexão com o Google Maps (${response.statusCode})');
        debugPrint('HTTP error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      _setError('Erro ao calcular rota');
      debugPrint('Route calculation error: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;
    
    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;
      
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      
      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    
    return points;
  }
  
  void _updateRoutePolyline() {
    _polylines.clear();
    if (_routePoints.isNotEmpty) {
      final polyline = Polyline(
        polylineId: const PolylineId('route'),
        points: _routePoints,
        color: const Color(0xFF00CC00),
        width: 4,
        patterns: [],
      );
      _polylines.add(polyline);
    }
    notifyListeners();
  }
  
  void clearRoute() {
    _pickupLocation = null;
    _destinationLocation = null;
    _pickupAddress = null;
    _destinationAddress = null;
    _routeDistance = null;
    _routeDuration = null;
    _routePoints.clear();
    _polylines.clear();
    _updateMarkers();
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
}