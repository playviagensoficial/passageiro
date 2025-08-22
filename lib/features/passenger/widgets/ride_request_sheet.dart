import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../maps/providers/map_provider.dart';
import '../../ride/providers/ride_provider.dart';

class RideRequestSheet extends StatefulWidget {
  const RideRequestSheet({super.key});

  @override
  State<RideRequestSheet> createState() => _RideRequestSheetState();
}

class _RideRequestSheetState extends State<RideRequestSheet> {
  String _selectedPaymentMethod = 'cash';

  Future<void> _requestRide() async {
    final mapProvider = context.read<MapProvider>();
    final rideProvider = context.read<RideProvider>();

    if (mapProvider.pickupLocation == null || mapProvider.destinationLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Defina origem e destino primeiro'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await rideProvider.requestRide(
      pickupAddress: mapProvider.pickupAddress!,
      pickupLatitude: mapProvider.pickupLocation!.latitude,
      pickupLongitude: mapProvider.pickupLocation!.longitude,
      destinationAddress: mapProvider.destinationAddress!,
      destinationLatitude: mapProvider.destinationLocation!.latitude,
      destinationLongitude: mapProvider.destinationLocation!.longitude,
      paymentMethod: _selectedPaymentMethod,
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Corrida solicitada! Procurando motoristas...'),
          backgroundColor: Color(0xFF00CC00),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<MapProvider, RideProvider>(
      builder: (context, mapProvider, rideProvider, child) {
        final distance = mapProvider.calculateDistance();
        final estimatedFare = distance != null && rideProvider.selectedCategory != null
            ? rideProvider.calculateEstimatedFare(distance)
            : 0.0;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'Confirmar viagem',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Route Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.radio_button_checked, 
                               color: Color(0xFF00CC00), size: 16),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            mapProvider.pickupAddress ?? 'Origem',
                            style: const TextStyle(color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red, size: 16),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            mapProvider.destinationAddress ?? 'Destino',
                            style: const TextStyle(color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Vehicle Category
              if (rideProvider.selectedCategory != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00CC00),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Icon(
                          Icons.directions_car,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rideProvider.selectedCategory!.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              rideProvider.selectedCategory!.description,
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'R\$ ${estimatedFare.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFF00CC00),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // Payment Method
              const Text(
                'Forma de pagamento',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _PaymentOption(
                      icon: Icons.money,
                      title: 'Dinheiro',
                      value: 'cash',
                      selectedValue: _selectedPaymentMethod,
                      onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
                    ),
                    _PaymentOption(
                      icon: Icons.credit_card,
                      title: 'Cartão de Crédito',
                      value: 'credit_card',
                      selectedValue: _selectedPaymentMethod,
                      onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
                    ),
                    _PaymentOption(
                      icon: Icons.pix,
                      title: 'PIX',
                      value: 'pix',
                      selectedValue: _selectedPaymentMethod,
                      onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Request Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: rideProvider.isLoading ? null : _requestRide,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00CC00),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: rideProvider.isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text(
                          'SOLICITAR CORRIDA',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String selectedValue;
  final ValueChanged<String?> onChanged;

  const _PaymentOption({
    required this.icon,
    required this.title,
    required this.value,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      activeColor: const Color(0xFF00CC00),
      value: value,
      groupValue: selectedValue,
      onChanged: onChanged,
      title: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}