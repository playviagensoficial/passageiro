import 'package:dio/dio.dart';
import '../config/app_config.dart';

class GoogleMapsService {
  static const String _apiKey = 'AIzaSyCz9sfN_WuNMY7LmMAB0HgOvKHlhd4j5hg';
  static const String _placesBaseUrl = 'https://maps.googleapis.com/maps/api/place';
  static const String _geocodingBaseUrl = 'https://maps.googleapis.com/maps/api/geocode';
  static const String _directionsBaseUrl = 'https://maps.googleapis.com/maps/api/directions';
  static const String _distanceMatrixBaseUrl = 'https://maps.googleapis.com/maps/api/distancematrix';
  
  // Usar o backend principal para evitar problemas de CORS
  static String get _localPlacesBaseUrl => '${AppConfig.baseUrl}/api-proxy/places';
  static String get _localDirectionsBaseUrl => '${AppConfig.baseUrl}/api-proxy/directions';
  static String get _localGeocodingBaseUrl => '${AppConfig.baseUrl}/api-proxy/geocoding';
  static String get _localDistanceMatrixBaseUrl => '${AppConfig.baseUrl}/api-proxy/distance-matrix';
  
  static final Dio _dio = Dio();

  // Google Places Autocomplete
  static Future<List<PlaceAutocomplete>> getPlaceAutocomplete(String input) async {
    if (input.length < 3) return [];
    
    try {
      final response = await _dio.get(
        '$_localPlacesBaseUrl/autocomplete',
        queryParameters: {
          'input': input,
        },
      );

      if (response.statusCode == 200 && response.data is Map) {
        final apiStatus = response.data['status'].toString();
        
        if (apiStatus == 'OK') {
          final predictions = response.data['predictions'] as List;
          return predictions.map((p) => PlaceAutocomplete.fromJson(p)).toList();
        }
      }
    } catch (e) {
      print('❌ Erro na busca de lugares: $e');
    }
    
    return [];
  }

  // Get Place Details
  static Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    try {
      final response = await _dio.get(
        '$_localPlacesBaseUrl/details',
        queryParameters: {
          'place_id': placeId,
        },
      );

      if (response.statusCode == 200) {
        final apiStatus = response.data['status'].toString();
        if (apiStatus == 'OK') {
          return PlaceDetails.fromJson(response.data['result']);
        } else {
          print('❌ Place Details API retornou status: $apiStatus');
        }
      }
    } catch (e) {
      print('❌ Erro ao buscar detalhes do lugar: $e');
    }
    
    return null;
  }

  // Reverse Geocoding
  static Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    try {
      print('🔄 Fazendo geocodificação reversa para: $lat,$lng');
      final response = await _dio.get(
        _localGeocodingBaseUrl,
        queryParameters: {
          'latlng': '$lat,$lng',
        },
      );

      print('📡 Geocoding response status: ${response.statusCode}');
      if (response.statusCode == 200 && response.data['status'] == 'OK') {
        final results = response.data['results'] as List;
        if (results.isNotEmpty) {
          final address = results[0]['formatted_address'];
          print('✅ Endereço encontrado: $address');
          return address;
        }
      }
    } catch (e) {
      print('❌ Erro na geocodificação reversa: $e');
    }
    
    return null;
  }

  // Calculate Distance and Duration
  static Future<RouteInfo?> getRouteInfo({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    try {
      print('🗺️ Calculando rota de ($originLat,$originLng) para ($destLat,$destLng)');
      final response = await _dio.get(
        _localDirectionsBaseUrl,
        queryParameters: {
          'origin': '$originLat,$originLng',
          'destination': '$destLat,$destLng',
        },
      );

      print('📡 Directions response status: ${response.statusCode}');
      if (response.statusCode == 200 && response.data['status'] == 'OK') {
        final routes = response.data['routes'] as List;
        if (routes.isNotEmpty) {
          final route = routes[0];
          final leg = route['legs'][0];
          
          final routeInfo = RouteInfo(
            distance: leg['distance']['text'],
            duration: leg['duration']['text'],
            durationValue: leg['duration']['value'],
            distanceValue: leg['distance']['value'],
            polyline: route['overview_polyline']['points'],
          );
          
          print('✅ Rota calculada: ${routeInfo.distance}, ${routeInfo.duration}');
          return routeInfo;
        }
      } else {
        print('❌ Directions API retornou status: ${response.data['status']}');
      }
    } catch (e) {
      print('❌ Erro ao calcular rota: $e');
    }
    
    return null;
  }

  // Calculate Distance Matrix for Multiple Destinations
  static Future<List<DistanceInfo>> getDistanceMatrix({
    required double originLat,
    required double originLng,
    required List<Map<String, double>> destinations,
  }) async {
    try {
      final destString = destinations
          .map((dest) => '${dest['lat']},${dest['lng']}')
          .join('|');
      
      print('🔢 Calculando matriz de distância para ${destinations.length} destinos');
      final response = await _dio.get(
        _localDistanceMatrixBaseUrl,
        queryParameters: {
          'origins': '$originLat,$originLng',
          'destinations': destString,
        },
      );

      print('📡 Distance Matrix response status: ${response.statusCode}');
      if (response.statusCode == 200 && response.data['status'] == 'OK') {
        final elements = response.data['rows'][0]['elements'] as List;
        final distanceInfos = elements.map((element) => DistanceInfo.fromJson(element)).toList();
        print('✅ Matriz de distância calculada: ${distanceInfos.length} resultados');
        return distanceInfos;
      } else {
        print('❌ Distance Matrix API retornou status: ${response.data['status']}');
      }
    } catch (e) {
      print('❌ Erro na matriz de distância: $e');
    }
    
    return [];
  }

  // Get Nearby Places (for drivers to find passengers)
  static Future<List<NearbyPlace>> getNearbyPlaces({
    required double lat,
    required double lng,
    String type = 'establishment',
    int radius = 1000,
  }) async {
    try {
      final response = await _dio.get(
        '$_placesBaseUrl/nearbysearch/json',
        queryParameters: {
          'location': '$lat,$lng',
          'radius': radius,
          'type': type,
          'key': _apiKey,
          'language': 'pt-BR',
        },
      );

      if (response.statusCode == 200 && response.data['status'] == 'OK') {
        final results = response.data['results'] as List;
        return results.map((r) => NearbyPlace.fromJson(r)).toList();
      }
    } catch (e) {
      print('❌ Erro ao buscar lugares próximos: $e');
    }
    
    return [];
  }

  // Reverse Geocoding - Get address from coordinates
  static Future<String?> getReverseGeocode(double lat, double lng) async {
    try {
      final response = await _dio.get(
        '$_localGeocodingBaseUrl/reverse',
        queryParameters: {
          'lat': lat,
          'lng': lng,
        },
      );

      if (response.statusCode == 200 && response.data is Map) {
        final apiStatus = response.data['status'].toString();
        
        if (apiStatus == 'OK') {
          final results = response.data['results'] as List;
          if (results.isNotEmpty) {
            return results[0]['formatted_address'] as String;
          }
        }
      }
    } catch (e) {
      print('❌ Erro no geocoding reverso: $e');
    }
    
    return null;
  }

  // Calculate Passenger Fare Estimate
  static double calculatePassengerFareEstimate({
    required int distanceMeters,
    required int durationSeconds,
    required String vehicleCategory,
    double surgePricing = 1.0,
  }) {
    // Passenger fare structure (what passenger pays)
    Map<String, Map<String, double>> fareStructure = {
      'economy': {
        'baseFare': 3.50,
        'perKm': 1.20,
        'perMinute': 0.25,
        'minimumFare': 5.00,
      },
      'comfort': {
        'baseFare': 4.50,
        'perKm': 1.80,
        'perMinute': 0.35,
        'minimumFare': 7.00,
      },
      'premium': {
        'baseFare': 6.00,
        'perKm': 2.50,
        'perMinute': 0.50,
        'minimumFare': 10.00,
      },
    };

    final fare = fareStructure[vehicleCategory.toLowerCase()] ?? fareStructure['economy']!;
    
    final distanceKm = distanceMeters / 1000.0;
    final durationMinutes = durationSeconds / 60.0;
    
    double totalFare = fare['baseFare']! + 
                      (distanceKm * fare['perKm']!) + 
                      (durationMinutes * fare['perMinute']!);
    
    // Apply surge pricing
    totalFare *= surgePricing;
    
    // Ensure minimum fare
    if (totalFare < fare['minimumFare']!) {
      totalFare = fare['minimumFare']!;
    }
    
    return double.parse(totalFare.toStringAsFixed(2));
  }

  // Calculate Driver Fare Estimate
  static double calculateDriverFareEstimate({
    required int distanceMeters,
    required int durationSeconds,
    required String vehicleCategory,
    double surgePricing = 1.0,
  }) {
    // Driver fare structure (what driver receives after commission)
    Map<String, Map<String, double>> driverFareStructure = {
      'economy': {
        'baseFare': 2.50,      // Driver gets 70% of passenger fare
        'perKm': 0.84,
        'perMinute': 0.175,
        'minimumFare': 3.50,
        'commission': 0.25,    // 25% commission to platform
      },
      'comfort': {
        'baseFare': 3.15,
        'perKm': 1.26,
        'perMinute': 0.245,
        'minimumFare': 4.90,
        'commission': 0.25,
      },
      'premium': {
        'baseFare': 4.20,
        'perKm': 1.75,
        'perMinute': 0.35,
        'minimumFare': 7.00,
        'commission': 0.25,
      },
    };

    final fare = driverFareStructure[vehicleCategory.toLowerCase()] ?? driverFareStructure['economy']!;
    
    final distanceKm = distanceMeters / 1000.0;
    final durationMinutes = durationSeconds / 60.0;
    
    double totalFare = fare['baseFare']! + 
                      (distanceKm * fare['perKm']!) + 
                      (durationMinutes * fare['perMinute']!);
    
    // Apply surge pricing
    totalFare *= surgePricing;
    
    // Ensure minimum fare
    if (totalFare < fare['minimumFare']!) {
      totalFare = fare['minimumFare']!;
    }
    
    return double.parse(totalFare.toStringAsFixed(2));
  }

  // Get fare breakdown for transparency
  static Map<String, dynamic> getFareBreakdown({
    required int distanceMeters,
    required int durationSeconds,
    required String vehicleCategory,
    required String userType, // 'driver' or 'passenger'
    double surgePricing = 1.0,
  }) {
    final isDriver = userType == 'driver';
    final fareStructure = isDriver ? {
      'economy': {
        'baseFare': 2.50,
        'perKm': 0.84,
        'perMinute': 0.175,
        'minimumFare': 3.50,
        'commission': 0.25,
      },
      'comfort': {
        'baseFare': 3.15,
        'perKm': 1.26,
        'perMinute': 0.245,
        'minimumFare': 4.90,
        'commission': 0.25,
      },
      'premium': {
        'baseFare': 4.20,
        'perKm': 1.75,
        'perMinute': 0.35,
        'minimumFare': 7.00,
        'commission': 0.25,
      },
    } : {
      'economy': {
        'baseFare': 3.50,
        'perKm': 1.20,
        'perMinute': 0.25,
        'minimumFare': 5.00,
      },
      'comfort': {
        'baseFare': 4.50,
        'perKm': 1.80,
        'perMinute': 0.35,
        'minimumFare': 7.00,
      },
      'premium': {
        'baseFare': 6.00,
        'perKm': 2.50,
        'perMinute': 0.50,
        'minimumFare': 10.00,
      },
    };

    final fare = fareStructure[vehicleCategory.toLowerCase()] ?? fareStructure['economy']!;
    
    final distanceKm = distanceMeters / 1000.0;
    final durationMinutes = durationSeconds / 60.0;
    
    final baseFareAmount = fare['baseFare']!;
    final distanceFareAmount = distanceKm * fare['perKm']!;
    final timeFareAmount = durationMinutes * fare['perMinute']!;
    
    double subtotal = baseFareAmount + distanceFareAmount + timeFareAmount;
    
    // Apply surge pricing
    final surgeAmount = subtotal * (surgePricing - 1.0);
    subtotal *= surgePricing;
    
    // Check minimum fare
    final isMinimumApplied = subtotal < fare['minimumFare']!;
    if (isMinimumApplied) {
      subtotal = fare['minimumFare']!;
    }

    return {
      'baseFare': double.parse(baseFareAmount.toStringAsFixed(2)),
      'distanceFare': double.parse(distanceFareAmount.toStringAsFixed(2)),
      'timeFare': double.parse(timeFareAmount.toStringAsFixed(2)),
      'surgeAmount': double.parse(surgeAmount.toStringAsFixed(2)),
      'surgePricing': surgePricing,
      'minimumFareApplied': isMinimumApplied,
      'minimumFare': fare['minimumFare'],
      'subtotal': double.parse(subtotal.toStringAsFixed(2)),
      'commission': isDriver ? fare['commission'] : null,
      'distanceKm': double.parse(distanceKm.toStringAsFixed(2)),
      'durationMinutes': double.parse(durationMinutes.toStringAsFixed(1)),
      'category': vehicleCategory,
      'userType': userType,
    };
  }
}

// Data Models
class PlaceAutocomplete {
  final String description;
  final String placeId;
  final String mainText;
  final String secondaryText;

  PlaceAutocomplete({
    required this.description,
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
  });

  factory PlaceAutocomplete.fromJson(Map<String, dynamic> json) {
    return PlaceAutocomplete(
      description: json['description'] ?? '',
      placeId: json['place_id'] ?? '',
      mainText: json['structured_formatting']?['main_text'] ?? '',
      secondaryText: json['structured_formatting']?['secondary_text'] ?? '',
    );
  }
}

class PlaceDetails {
  final String placeId;
  final String name;
  final String formattedAddress;
  final double lat;
  final double lng;

  PlaceDetails({
    required this.placeId,
    required this.name,
    required this.formattedAddress,
    required this.lat,
    required this.lng,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    final location = json['geometry']['location'];
    return PlaceDetails(
      placeId: json['place_id'] ?? '',
      name: json['name'] ?? '',
      formattedAddress: json['formatted_address'] ?? '',
      lat: location['lat']?.toDouble() ?? 0.0,
      lng: location['lng']?.toDouble() ?? 0.0,
    );
  }
}

class RouteInfo {
  final String distance;
  final String duration;
  final int durationValue;
  final int distanceValue;
  final String polyline;

  RouteInfo({
    required this.distance,
    required this.duration,
    required this.durationValue,
    required this.distanceValue,
    required this.polyline,
  });
}

class DistanceInfo {
  final String distance;
  final String duration;
  final int durationValue;
  final int distanceValue;
  final String status;

  DistanceInfo({
    required this.distance,
    required this.duration,
    required this.durationValue,
    required this.distanceValue,
    required this.status,
  });

  factory DistanceInfo.fromJson(Map<String, dynamic> json) {
    return DistanceInfo(
      distance: json['distance']?['text'] ?? '',
      duration: json['duration']?['text'] ?? '',
      durationValue: json['duration']?['value'] ?? 0,
      distanceValue: json['distance']?['value'] ?? 0,
      status: json['status'] ?? '',
    );
  }
}

class NearbyPlace {
  final String placeId;
  final String name;
  final double lat;
  final double lng;
  final double rating;
  final String vicinity;

  NearbyPlace({
    required this.placeId,
    required this.name,
    required this.lat,
    required this.lng,
    required this.rating,
    required this.vicinity,
  });

  factory NearbyPlace.fromJson(Map<String, dynamic> json) {
    final location = json['geometry']['location'];
    return NearbyPlace(
      placeId: json['place_id'] ?? '',
      name: json['name'] ?? '',
      lat: location['lat']?.toDouble() ?? 0.0,
      lng: location['lng']?.toDouble() ?? 0.0,
      rating: json['rating']?.toDouble() ?? 0.0,
      vicinity: json['vicinity'] ?? '',
    );
  }
}