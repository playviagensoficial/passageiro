import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService._internal();
  
  LocationService._internal();
  
  StreamSubscription<Position>? _positionStreamSubscription;
  Position? _currentPosition;
  
  Position? get currentPosition => _currentPosition;
  
  Future<bool> requestPermissions() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }
      
      // Request permission
      PermissionStatus permission = await Permission.location.request();
      if (permission.isDenied) {
        permission = await Permission.location.request();
        if (permission.isDenied) {
          return false;
        }
      }
      
      if (permission.isPermanentlyDenied) {
        return false;
      }
      
      return permission.isGranted;
    } catch (e) {
      print('Error requesting location permissions: $e');
      return false;
    }
  }
  
  Future<Position?> getCurrentPosition() async {
    try {
      bool hasPermission = await requestPermissions();
      if (!hasPermission) {
        throw Exception('Location permission denied');
      }
      
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      _currentPosition = position;
      return position;
    } catch (e) {
      print('Error getting current position: $e');
      return null;
    }
  }
  
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    );
  }
  
  void startLocationTracking() {
    _positionStreamSubscription = getPositionStream().listen(
      (Position position) {
        _currentPosition = position;
        print('Location updated: ${position.latitude}, ${position.longitude}');
      },
      onError: (error) {
        print('Location tracking error: $error');
      },
    );
  }
  
  void stopLocationTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }
  
  Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      // Validate coordinates
      if (latitude.isNaN || longitude.isNaN || latitude == 0.0 && longitude == 0.0) {
        print('Invalid coordinates provided: $latitude, $longitude');
        return 'Localização inválida';
      }
      
      // Try to get address using geocoding
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        List<String> addressParts = [];
        
        // Build address parts only if they are not null or empty
        if (place.street?.isNotEmpty == true) {
          addressParts.add(place.street!);
        }
        
        if (place.subThoroughfare?.isNotEmpty == true) {
          addressParts.add(place.subThoroughfare!);
        }
        
        if (place.subLocality?.isNotEmpty == true) {
          addressParts.add(place.subLocality!);
        }
        
        if (place.locality?.isNotEmpty == true) {
          addressParts.add(place.locality!);
        }
        
        if (place.administrativeArea?.isNotEmpty == true) {
          addressParts.add(place.administrativeArea!);
        }
        
        String address = addressParts.join(', ');
        return address.isNotEmpty ? address : 'Localização selecionada';
      }
      
      return 'Localização selecionada';
    } catch (e) {
      print('Error getting address from coordinates: $e');
      // Return coordinates as fallback instead of null
      return 'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}';
    }
  }
  
  Future<List<Location>?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      return locations;
    } catch (e) {
      print('Error getting coordinates from address: $e');
      return null;
    }
  }
  
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }
  
  double calculateBearing(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.bearingBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }
  
  void dispose() {
    stopLocationTracking();
  }
}