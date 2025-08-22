import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

class GoogleMapWidget extends StatefulWidget {
  final LatLng initialPosition;
  final double initialZoom;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final Function(GoogleMapController)? onMapCreated;
  final Function(LatLng)? onTap;
  final Function(LatLng)? onLongPress;
  final Function(CameraPosition)? onCameraMove;
  final Function(CameraPosition)? onCameraIdle;
  final bool myLocationEnabled;
  final bool myLocationButtonEnabled;
  final MapType mapType;
  final bool zoomControlsEnabled;
  final bool compassEnabled;
  final bool mapToolbarEnabled;

  const GoogleMapWidget({
    super.key,
    required this.initialPosition,
    this.initialZoom = 14.0,
    this.markers = const {},
    this.polylines = const {},
    this.onMapCreated,
    this.onTap,
    this.onLongPress,
    this.onCameraMove,
    this.onCameraIdle,
    this.myLocationEnabled = true,
    this.myLocationButtonEnabled = true,
    this.mapType = MapType.normal,
    this.zoomControlsEnabled = false,
    this.compassEnabled = true,
    this.mapToolbarEnabled = false,
  });

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  GoogleMapController? _controller;
  final Completer<GoogleMapController> _completer = Completer();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _controller = controller;
    _completer.complete(controller);
    
    // Set map style for dark theme
    String mapStyle = '''
    [
      {
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#212121"
          }
        ]
      },
      {
        "elementType": "labels.icon",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      },
      {
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#757575"
          }
        ]
      },
      {
        "elementType": "labels.text.stroke",
        "stylers": [
          {
            "color": "#212121"
          }
        ]
      },
      {
        "featureType": "administrative",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#757575"
          }
        ]
      },
      {
        "featureType": "administrative.country",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#9e9e9e"
          }
        ]
      },
      {
        "featureType": "administrative.locality",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#bdbdbd"
          }
        ]
      },
      {
        "featureType": "poi",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#757575"
          }
        ]
      },
      {
        "featureType": "poi.park",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#181818"
          }
        ]
      },
      {
        "featureType": "poi.park",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#616161"
          }
        ]
      },
      {
        "featureType": "poi.park",
        "elementType": "labels.text.stroke",
        "stylers": [
          {
            "color": "#1b1b1b"
          }
        ]
      },
      {
        "featureType": "road",
        "elementType": "geometry.fill",
        "stylers": [
          {
            "color": "#2c2c2c"
          }
        ]
      },
      {
        "featureType": "road",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#8a8a8a"
          }
        ]
      },
      {
        "featureType": "road.arterial",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#373737"
          }
        ]
      },
      {
        "featureType": "road.highway",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#3c3c3c"
          }
        ]
      },
      {
        "featureType": "road.highway.controlled_access",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#4e4e4e"
          }
        ]
      },
      {
        "featureType": "road.local",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#616161"
          }
        ]
      },
      {
        "featureType": "transit",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#757575"
          }
        ]
      },
      {
        "featureType": "water",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#000000"
          }
        ]
      },
      {
        "featureType": "water",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#3d3d3d"
          }
        ]
      }
    ]
    ''';
    
    try {
      await controller.setMapStyle(mapStyle);
    } catch (e) {
      print('Error setting map style: $e');
    }
    
    widget.onMapCreated?.call(controller);
  }

  Future<void> animateToPosition(LatLng position, {double zoom = 16.0}) async {
    final GoogleMapController controller = await _completer.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: position,
          zoom: zoom,
        ),
      ),
    );
  }

  Future<void> animateToFitBounds(LatLngBounds bounds) async {
    final GoogleMapController controller = await _completer.future;
    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: widget.initialPosition,
        zoom: widget.initialZoom,
      ),
      markers: widget.markers,
      polylines: widget.polylines,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onCameraMove: widget.onCameraMove,
      myLocationEnabled: widget.myLocationEnabled,
      myLocationButtonEnabled: widget.myLocationButtonEnabled,
      mapType: widget.mapType,
      zoomControlsEnabled: widget.zoomControlsEnabled,
      compassEnabled: widget.compassEnabled,
      mapToolbarEnabled: widget.mapToolbarEnabled,
      padding: const EdgeInsets.only(bottom: 100),
    );
  }
}