import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ride_provider.dart';
import '../screens/ride_tracking_screen.dart';
import '../../maps/providers/map_provider.dart';
import '../../auth/providers/auth_provider.dart';

class RideConfirmationSheet extends StatefulWidget {
  const RideConfirmationSheet({super.key});

  @override
  State<RideConfirmationSheet> createState() => _RideConfirmationSheetState();
}

class _RideConfirmationSheetState extends State<RideConfirmationSheet> {
  String _selectedPaymentMethod = 'cash';
  bool _isRequesting = false;
  
  // Dynamic pricing factors
  double _surgeFactor = 1.0; // 1.0 = normal, 1.5 = 50% increase, etc.
  bool _isPeakHour = false;
  bool _isHighDemand = false;
  
  @override
  void initState() {
    super.initState();
    _calculateDynamicPricing();
  }
  
  void _calculateDynamicPricing() {
    final now = DateTime.now();
    
    // Peak hours: 7-9 AM and 5-8 PM on weekdays
    if (now.weekday <= 5) { // Monday to Friday
      if ((now.hour >= 7 && now.hour < 9) || (now.hour >= 17 && now.hour < 20)) {
        _isPeakHour = true;
        _surgeFactor = 1.5; // 50% increase during peak hours
      }
    }
    
    // Simulate high demand (in real app, this would come from backend)
    // For demo, randomly set high demand
    if (DateTime.now().second % 3 == 0) {
      _isHighDemand = true;
      _surgeFactor = _surgeFactor * 1.3; // Additional 30% for high demand
    }
    
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    final rideProvider = context.watch<RideProvider>();
    final mapProvider = context.watch<MapProvider>();
    final authProvider = context.watch<AuthProvider>();
    
    final distance = mapProvider.calculateDistance() ?? 5.0; // Default 5km
    final duration = (distance * 3).toInt(); // Estimate 3 min per km
    
    // Calculate fares
    final baseFare = rideProvider.selectedCategory?.baseFareValue ?? 5.0;
    final perKmRate = rideProvider.selectedCategory?.perKmRateValue ?? 1.5;
    final perMinuteRate = rideProvider.selectedCategory?.perMinuteRateValue ?? 0.3;
    
    double subtotal = baseFare + (distance * perKmRate) + (duration * perMinuteRate);
    final minimumFare = rideProvider.selectedCategory?.minimumFareValue ?? baseFare;
    if (subtotal < minimumFare) {
      subtotal = minimumFare;
    }
    
    // Apply dynamic pricing
    final dynamicFare = subtotal * _surgeFactor;
    final surgeCost = dynamicFare - subtotal;
    
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                ),
                const Expanded(
                  child: Text(
                    'Confirmar corrida',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // Route summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              mapProvider.pickupAddress ?? 'Localização atual',
                              style: const TextStyle(fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 4, top: 4, bottom: 4),
                        width: 1,
                        height: 20,
                        color: Colors.grey[300],
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              mapProvider.destinationAddress ?? 'Destino',
                              style: const TextStyle(fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Vehicle and trip info
                Row(
                  children: [
                    Icon(
                      _getVehicleIcon(rideProvider.selectedCategory?.name ?? ''),
                      size: 40,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rideProvider.selectedCategory?.displayName ?? 
                            rideProvider.selectedCategory?.name ?? 'Econômica',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${distance.toStringAsFixed(1)} km • ~$duration min',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (_surgeFactor > 1.0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.trending_up, size: 14, color: Colors.orange[700]),
                                const SizedBox(width: 4),
                                Text(
                                  '${_surgeFactor.toStringAsFixed(1)}x',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Fare breakdown
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detalhes do valor',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildFareRow('Tarifa base', 'R\$ ${baseFare.toStringAsFixed(2)}'),
                      _buildFareRow('Distância (${distance.toStringAsFixed(1)} km)', 
                                    'R\$ ${(distance * perKmRate).toStringAsFixed(2)}'),
                      _buildFareRow('Tempo (~$duration min)', 
                                    'R\$ ${(duration * perMinuteRate).toStringAsFixed(2)}'),
                      if (_surgeFactor > 1.0) ...[
                        const Divider(),
                        _buildFareRow('Subtotal', 'R\$ ${subtotal.toStringAsFixed(2)}'),
                        if (_isPeakHour)
                          _buildFareRow('Horário de pico', 
                                       '+R\$ ${(surgeCost * 0.6).toStringAsFixed(2)}',
                                       isHighlight: true),
                        if (_isHighDemand)
                          _buildFareRow('Alta demanda', 
                                       '+R\$ ${(surgeCost * 0.4).toStringAsFixed(2)}',
                                       isHighlight: true),
                      ],
                      const Divider(),
                      _buildFareRow(
                        'Total',
                        'R\$ ${dynamicFare.toStringAsFixed(2)}',
                        isBold: true,
                        isLarge: true,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Payment methods
                const Text(
                  'Forma de pagamento',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                _buildPaymentOption(
                  'cash',
                  Icons.money,
                  'Dinheiro',
                  'Pague ao motorista',
                ),
                _buildPaymentOption(
                  'pix',
                  Icons.qr_code,
                  'PIX',
                  'Rápido e seguro',
                ),
                _buildPaymentOption(
                  'card',
                  Icons.credit_card,
                  'Cartão de crédito',
                  '•••• 4242',
                ),
                _buildPaymentOption(
                  'wallet',
                  Icons.account_balance_wallet,
                  'Carteira',
                  'Saldo: R\$ 150,75',
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
          
          // Confirm button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isRequesting ? null : _requestRide,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isRequesting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Confirmar • R\$ ${dynamicFare.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFareRow(String label, String value, 
      {bool isBold = false, bool isLarge = false, bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isLarge ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? Colors.orange[700] : Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isLarge ? 18 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? Colors.orange[700] : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPaymentOption(String value, IconData icon, String title, String subtitle) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: _selectedPaymentMethod == value 
                ? Colors.black 
                : Colors.grey[300]!,
            width: _selectedPaymentMethod == value ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black87),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (_selectedPaymentMethod == value)
              const Icon(Icons.check_circle, color: Colors.black),
          ],
        ),
      ),
    );
  }
  
  void _requestRide() async {
    setState(() {
      _isRequesting = true;
    });
    
    final rideProvider = context.read<RideProvider>();
    final mapProvider = context.read<MapProvider>();
    
    try {
      final success = await rideProvider.requestRide(
        pickupAddress: mapProvider.pickupAddress ?? 'Localização atual',
        pickupLatitude: mapProvider.pickupLocation?.latitude ?? -23.5505,
        pickupLongitude: mapProvider.pickupLocation?.longitude ?? -46.6333,
        destinationAddress: mapProvider.destinationAddress ?? 'Destino',
        destinationLatitude: mapProvider.destinationLocation?.latitude ?? -23.5505,
        destinationLongitude: mapProvider.destinationLocation?.longitude ?? -46.6333,
        paymentMethod: _selectedPaymentMethod,
      );
      
      if (success && mounted) {
        Navigator.pop(context);
        _showSearchingForDriver();
      } else if (mounted) {
        setState(() {
          _isRequesting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(rideProvider.errorMessage ?? 'Erro ao solicitar corrida'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isRequesting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao solicitar corrida'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _showSearchingForDriver() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text(
              'Procurando motorista...',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Isso pode levar alguns segundos',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
    
    // Simulate finding a driver and accepting ride
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pop(context); // Close search dialog
        
        final rideProvider = context.read<RideProvider>();
        final currentRide = rideProvider.currentRide;
        
        if (currentRide != null) {
          // Simulate driver acceptance
          final updatedRide = currentRide.copyWith(
            status: 'accepted',
            driverId: 123, // Demo driver ID
            acceptedAt: DateTime.now(),
          );
          
          // Navigate to ride tracking screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => RideTrackingScreen(rideId: updatedRide.id),
            ),
          );
        }
      }
    });
  }
  
  IconData _getVehicleIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'economy':
      case 'economica':
      case 'econômica':
        return Icons.directions_car;
      case 'comfort':
      case 'confort':
        return Icons.car_rental;
      case 'premium':
        return Icons.directions_car;
      default:
        return Icons.directions_car;
    }
  }
}