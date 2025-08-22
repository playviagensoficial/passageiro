import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/ride_tracking_provider.dart';
import '../providers/ride_provider.dart';
import '../../../core/models/ride.dart';
import '../../../core/models/driver.dart';

class RideTrackingScreen extends StatefulWidget {
  final int rideId;
  
  const RideTrackingScreen({
    super.key,
    required this.rideId,
  });

  @override
  State<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends State<RideTrackingScreen> {
  GoogleMapController? _mapController;
  bool _isChatExpanded = false;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final trackingProvider = context.read<RideTrackingProvider>();
      final rideProvider = context.read<RideProvider>();
      final ride = rideProvider.currentRide;
      
      if (ride != null && ride.driverId != null) {
        trackingProvider.initializeRideTracking(widget.rideId, ride.driverId!);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _toggleChat() {
    setState(() {
      _isChatExpanded = !_isChatExpanded;
    });
    
    if (_isChatExpanded) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollToBottom();
      });
    }
  }

  void _scrollToBottom() {
    if (_chatScrollController.hasClients) {
      _chatScrollController.animateTo(
        _chatScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      context.read<RideTrackingProvider>().sendMessage(widget.rideId, message);
      _messageController.clear();
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    }
  }

  void _sendQuickMessage(String message) {
    context.read<RideTrackingProvider>().sendQuickMessage(widget.rideId, message);
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  Future<void> _callDriver(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<RideTrackingProvider, RideProvider>(
        builder: (context, trackingProvider, rideProvider, child) {
          final ride = rideProvider.currentRide;
          final driver = trackingProvider.driver;
          
          if (ride == null) {
            return const Center(
              child: Text('Erro: Corrida não encontrada'),
            );
          }

          return Stack(
            children: [
              // Google Map
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: LatLng(ride.pickupLatitude, ride.pickupLongitude),
                  zoom: 15,
                ),
                markers: {
                  // Pickup marker
                  Marker(
                    markerId: const MarkerId('pickup'),
                    position: LatLng(ride.pickupLatitude, ride.pickupLongitude),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                    infoWindow: InfoWindow(
                      title: 'Origem',
                      snippet: ride.pickupAddress,
                    ),
                  ),
                  // Destination marker
                  Marker(
                    markerId: const MarkerId('destination'),
                    position: LatLng(ride.destinationLatitude, ride.destinationLongitude),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                    infoWindow: InfoWindow(
                      title: 'Destino',
                      snippet: ride.destinationAddress,
                    ),
                  ),
                  // Driver marker (if available)
                  if (driver?.currentLatitude != null && driver?.currentLongitude != null)
                    Marker(
                      markerId: const MarkerId('driver'),
                      position: LatLng(driver!.currentLatitude!, driver.currentLongitude!),
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                      infoWindow: InfoWindow(
                        title: driver.name,
                        snippet: driver.vehicleInfo,
                      ),
                    ),
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              ),

              // Top bar with ride status
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Expanded(
                            child: Text(
                              _getRideStatusText(ride.status),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                      if (ride.status == 'accepted' || ride.status == 'in_progress') ...[
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00CC00)),
                          value: ride.status == 'accepted' ? 0.3 : 0.7,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Driver info card - Official Play Viagens wireframe
              if (driver != null)
                Positioned(
                  bottom: _isChatExpanded ? MediaQuery.of(context).size.height * 0.5 + 16 : 200,
                  left: 16,
                  right: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header - Play Viagens official branding
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Logo
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00CC00),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'play',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      height: 0.9,
                                    ),
                                  ),
                                  Text(
                                    'Viagens',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      height: 0.9,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              const Text(
                                'Seu Motorista',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Driver information - Professional design
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                          child: Column(
                            children: [
                              // Vehicle info section
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF00CC00).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.directions_car,
                                        color: Color(0xFF00CC00),
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            driver.vehicleInfo,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          if (driver.vehicleColor != null && driver.vehiclePlate != null)
                                            Text(
                                              '${driver.vehicleColor} • ${driver.vehiclePlate}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Rating section
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${driver.formattedRating}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '(${driver.totalRides} viagens)',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Action buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _callDriver(driver.phoneNumber),
                                      icon: const Icon(Icons.phone, size: 18),
                                      label: const Text(
                                        'Ligar',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _toggleChat,
                                      icon: Icon(
                                        _isChatExpanded ? Icons.keyboard_arrow_down : Icons.chat,
                                        size: 18,
                                      ),
                                      label: Text(
                                        _isChatExpanded ? 'Fechar' : 'Chat',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF00CC00),
                                        foregroundColor: Colors.black,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Chat interface
              if (_isChatExpanded)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Chat header
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey[200]!),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                'Chat com o motorista',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: _toggleChat,
                                icon: const Icon(Icons.keyboard_arrow_down),
                              ),
                            ],
                          ),
                        ),
                        
                        // Messages list
                        Expanded(
                          child: ListView.builder(
                            controller: _chatScrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: trackingProvider.messages.length,
                            itemBuilder: (context, index) {
                              final message = trackingProvider.messages[index];
                              final isFromDriver = message.isFromDriver;
                              
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  mainAxisAlignment: isFromDriver
                                      ? MainAxisAlignment.start
                                      : MainAxisAlignment.end,
                                  children: [
                                    if (isFromDriver) ...[
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor: Colors.grey[200],
                                        child: Text(
                                          driver?.name.isNotEmpty == true
                                              ? driver!.name[0].toUpperCase()
                                              : 'M',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isFromDriver
                                              ? Colors.grey[200]
                                              : const Color(0xFF00CC00),
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              message.message,
                                              style: TextStyle(
                                                color: isFromDriver
                                                    ? Colors.black
                                                    : Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  message.formattedTime,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: isFromDriver
                                                        ? Colors.grey[600]
                                                        : Colors.white70,
                                                  ),
                                                ),
                                                if (message.isAutomatic) ...[
                                                  const SizedBox(width: 4),
                                                  Icon(
                                                    Icons.smart_toy,
                                                    size: 12,
                                                    color: isFromDriver
                                                        ? Colors.grey[600]
                                                        : Colors.white70,
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (!isFromDriver) ...[
                                      const SizedBox(width: 8),
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor: const Color(0xFF00CC00),
                                        child: const Text(
                                          'E',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        
                        // Quick messages
                        Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: trackingProvider.quickMessages.length,
                            itemBuilder: (context, index) {
                              final quickMessage = trackingProvider.quickMessages[index];
                              return Container(
                                margin: const EdgeInsets.only(right: 8),
                                child: ActionChip(
                                  label: Text(quickMessage),
                                  onPressed: () => _sendQuickMessage(quickMessage),
                                  backgroundColor: Colors.grey[100],
                                  labelStyle: const TextStyle(fontSize: 12),
                                ),
                              );
                            },
                          ),
                        ),
                        
                        // Message input
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.grey[200]!),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  decoration: InputDecoration(
                                    hintText: 'Digite sua mensagem...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                  ),
                                  onSubmitted: (_) => _sendMessage(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: _sendMessage,
                                icon: const Icon(Icons.send),
                                style: IconButton.styleFrom(
                                  backgroundColor: const Color(0xFF00CC00),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // My location button
              if (!_isChatExpanded)
                Positioned(
                  bottom: 320,
                  right: 16,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.white,
                    onPressed: () {
                      // Center map on current location
                    },
                    child: const Icon(Icons.my_location, color: Colors.black),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  String _getRideStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Procurando motorista...';
      case 'accepted':
        return 'Motorista a caminho';
      case 'in_progress':
        return 'Em viagem';
      case 'completed':
        return 'Viagem concluída';
      case 'cancelled':
        return 'Viagem cancelada';
      default:
        return 'Acompanhe sua viagem';
    }
  }
}