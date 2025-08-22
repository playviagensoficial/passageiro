import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../maps/providers/map_provider.dart';
import '../../auth/widgets/auth_text_field.dart';

class AddressSearchSheet extends StatefulWidget {
  const AddressSearchSheet({super.key});

  @override
  State<AddressSearchSheet> createState() => _AddressSearchSheetState();
}

class _AddressSearchSheetState extends State<AddressSearchSheet> {
  final _pickupController = TextEditingController();
  final _destinationController = TextEditingController();
  final _pickupFocusNode = FocusNode();
  final _destinationFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final mapProvider = context.read<MapProvider>();
    _pickupController.text = mapProvider.pickupAddress ?? '';
    _destinationController.text = mapProvider.destinationAddress ?? '';
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    _pickupFocusNode.dispose();
    _destinationFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    final mapProvider = context.read<MapProvider>();
    
    if (_pickupController.text.isNotEmpty) {
      await mapProvider.setPickupAddress(_pickupController.text);
    }
    
    if (_destinationController.text.isNotEmpty) {
      await mapProvider.setDestinationAddress(_destinationController.text);
    }
    
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _useCurrentLocation() async {
    final mapProvider = context.read<MapProvider>();
    if (mapProvider.currentLocation != null) {
      // TODO: Implement getting address from current location
      _pickupController.text = 'Localização atual';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    'Definir rota',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48), // Balance the close button
              ],
            ),
          ),

          // Address inputs
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Pickup address
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.radio_button_checked,
                          color: Color(0xFF00CC00),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AuthTextField(
                          controller: _pickupController,
                          labelText: 'Origem',
                          hintText: 'Digite o endereço de origem',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.my_location, color: Color(0xFF00CC00)),
                            onPressed: _useCurrentLocation,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Connecting line
                  Container(
                    width: 2,
                    height: 20,
                    color: Colors.grey[600],
                    margin: const EdgeInsets.only(left: 20),
                  ),

                  const SizedBox(height: 16),

                  // Destination address
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AuthTextField(
                          controller: _destinationController,
                          labelText: 'Destino',
                          hintText: 'Digite o endereço de destino',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Recent addresses (placeholder)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Endereços recentes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView(
                            children: [
                              _RecentAddressItem(
                                icon: Icons.home,
                                title: 'Casa',
                                subtitle: 'Rua das Flores, 123',
                                onTap: () {
                                  _destinationController.text = 'Rua das Flores, 123';
                                },
                              ),
                              _RecentAddressItem(
                                icon: Icons.work,
                                title: 'Trabalho',
                                subtitle: 'Av. Paulista, 1000',
                                onTap: () {
                                  _destinationController.text = 'Av. Paulista, 1000';
                                },
                              ),
                              _RecentAddressItem(
                                icon: Icons.history,
                                title: 'Shopping Center',
                                subtitle: 'Rua do Comércio, 500',
                                onTap: () {
                                  _destinationController.text = 'Rua do Comércio, 500';
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Confirm button
          Consumer<MapProvider>(
            builder: (context, mapProvider, child) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: mapProvider.isLoading ? null : _handleConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00CC00),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: mapProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            'CONFIRMAR ROTA',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RecentAddressItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RecentAddressItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[400]),
      ),
      onTap: onTap,
    );
  }
}