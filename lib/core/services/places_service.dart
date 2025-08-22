import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlacesService {
  static const String _googleMapsApiKey = 'AIzaSyCz9sfN_WuNMY7LmMAB0HgOvKHlhd4j5hg';
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api';
  
  final Dio _dio = Dio();

  // Get autocomplete predictions
  Future<List<PlacePrediction>> getAutocompletePredictions(String input, {LatLng? location}) async {
    if (input.length < 2) return [];

    try {
      final queryParams = {
        'input': input,
        'key': _googleMapsApiKey,
        'language': 'pt-BR',
        'components': 'country:br',
        if (location != null) ...{
          'location': '${location.latitude},${location.longitude}',
          'radius': '50000', // 50km radius
        },
        'types': 'establishment|geocode',
      };
      
      print('🔍 Places API Request: $_baseUrl/place/autocomplete/json');
      print('📋 Query params: $queryParams');
      
      final response = await _dio.get(
        '$_baseUrl/place/autocomplete/json',
        queryParameters: queryParams,
      );

      print('📡 Places API Response Status: ${response.statusCode}');
      print('📄 Places API Response Data: ${response.data}');

      if (response.data['status'] == 'OK') {
        final predictions = (response.data['predictions'] as List)
            .map((prediction) => PlacePrediction.fromJson(prediction))
            .toList();
        print('✅ Found ${predictions.length} predictions');
        return predictions;
      } else {
        print('❌ API Status: ${response.data['status']}');
        print('❌ API Error: ${response.data['error_message'] ?? 'No error message'}');
      }
      return [];
    } catch (e) {
      print('💥 Error getting autocomplete predictions: $e');
      return [];
    }
  }

  // Get place details by place_id
  Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/place/details/json',
        queryParameters: {
          'place_id': placeId,
          'key': _googleMapsApiKey,
          'language': 'pt-BR',
          'fields': 'place_id,formatted_address,geometry,name',
        },
      );

      if (response.data['status'] == 'OK') {
        return PlaceDetails.fromJson(response.data['result']);
      }
      return null;
    } catch (e) {
      print('Error getting place details: $e');
      return null;
    }
  }

  // Reverse geocoding to get address from coordinates
  Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/geocode/json',
        queryParameters: {
          'latlng': '$lat,$lng',
          'key': _googleMapsApiKey,
          'language': 'pt-BR',
        },
      );

      if (response.data['status'] == 'OK') {
        final results = response.data['results'] as List;
        if (results.isNotEmpty) {
          return results[0]['formatted_address'];
        }
      }
      return null;
    } catch (e) {
      print('Error getting address from coordinates: $e');
      return null;
    }
  }
}

class PlacePrediction {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;
  final List<String> types;

  PlacePrediction({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
    required this.types,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    return PlacePrediction(
      placeId: json['place_id'] ?? '',
      description: json['description'] ?? '',
      mainText: json['structured_formatting']?['main_text'] ?? '',
      secondaryText: json['structured_formatting']?['secondary_text'] ?? '',
      types: List<String>.from(json['types'] ?? []),
    );
  }
}

class PlaceDetails {
  final String placeId;
  final String formattedAddress;
  final String name;
  final LatLng location;

  PlaceDetails({
    required this.placeId,
    required this.formattedAddress,
    required this.name,
    required this.location,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry']['location'];
    return PlaceDetails(
      placeId: json['place_id'] ?? '',
      formattedAddress: json['formatted_address'] ?? '',
      name: json['name'] ?? '',
      location: LatLng(
        geometry['lat']?.toDouble() ?? 0.0,
        geometry['lng']?.toDouble() ?? 0.0,
      ),
    );
  }
}