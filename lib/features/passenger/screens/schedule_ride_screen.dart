import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../ride/providers/ride_provider.dart';
import '../../maps/providers/map_provider.dart';
import '../widgets/address_autocomplete_field.dart';

class ScheduleRideScreen extends StatefulWidget {
  const ScheduleRideScreen({super.key});

  @override
  State<ScheduleRideScreen> createState() => _ScheduleRideScreenState();
}

class _ScheduleRideScreenState extends State<ScheduleRideScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pickupController = TextEditingController();
  final _destinationController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedVehicleType = 'economy';
  String _paymentMethod = 'pix';
  bool _isLoading = false;

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Set minimum date to today
    _selectedDate = DateTime.now().add(const Duration(hours: 1));
    _selectedTime = TimeOfDay.fromDateTime(_selectedDate!);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RideProvider>().loadVehicleCategories();
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00FF00),
              surface: Color(0xFF2A2A2A),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00FF00),
              surface: Color(0xFF2A2A2A),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _scheduleRide() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione data e horário'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final scheduledDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // Check if scheduled time is at least 30 minutes from now
    final minimumTime = DateTime.now().add(const Duration(minutes: 30));
    if (scheduledDateTime.isBefore(minimumTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agendamento deve ser com pelo menos 30 minutos de antecedência'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final rideProvider = context.read<RideProvider>();
      await rideProvider.scheduleRide(
        pickupAddress: _pickupController.text,
        destinationAddress: _destinationController.text,
        scheduledTime: scheduledDateTime,
        vehicleType: _selectedVehicleType,
        paymentMethod: _paymentMethod,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Viagem agendada com sucesso!'),
            backgroundColor: Color(0xFF00FF00),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao agendar viagem: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Agendar Viagem',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF00FF00), width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00FF00),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.schedule, color: Colors.black),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Agende sua viagem com antecedência e viaje com tranquilidade',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),

                // Pickup Address
                _buildSectionTitle('De onde?'),
                const SizedBox(height: 8),
                AddressAutocompleteField(
                  controller: _pickupController,
                  hintText: 'Endereço de origem',
                  prefixIcon: Icons.my_location,
                  prefixIconColor: const Color(0xFF00FF00),
                  onPlaceSelected: (placeDetails) {
                    _pickupController.text = placeDetails.formattedAddress ?? '';
                  },
                ),
                
                const SizedBox(height: 20),

                // Destination Address
                _buildSectionTitle('Para onde?'),
                const SizedBox(height: 8),
                AddressAutocompleteField(
                  controller: _destinationController,
                  hintText: 'Endereço de destino',
                  prefixIcon: Icons.location_on,
                  prefixIconColor: Colors.red,
                  onPlaceSelected: (placeDetails) {
                    _destinationController.text = placeDetails.formattedAddress ?? '';
                  },
                ),
                
                const SizedBox(height: 20),

                // Date and Time
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Data'),
                          const SizedBox(height: 8),
                          _buildDateTimeButton(
                            text: _selectedDate != null 
                                ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                                : 'Selecionar data',
                            icon: Icons.calendar_today,
                            onTap: _selectDate,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Horário'),
                          const SizedBox(height: 8),
                          _buildDateTimeButton(
                            text: _selectedTime != null 
                                ? _selectedTime!.format(context)
                                : 'Selecionar hora',
                            icon: Icons.access_time,
                            onTap: _selectTime,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),

                // Vehicle Type
                _buildSectionTitle('Tipo de Veículo'),
                const SizedBox(height: 8),
                Consumer<RideProvider>(
                  builder: (context, rideProvider, child) {
                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF00FF00)),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedVehicleType,
                        style: const TextStyle(color: Colors.white),
                        dropdownColor: const Color(0xFF2A2A2A),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          prefixIcon: Icon(Icons.directions_car, color: Color(0xFF00FF00)),
                        ),
                        items: rideProvider.vehicleCategories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category.name,
                            child: Text(
                              category.displayName ?? category.name,
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedVehicleType = newValue;
                            });
                          }
                        },
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 20),

                // Payment Method
                _buildSectionTitle('Forma de Pagamento'),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF00FF00)),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _paymentMethod,
                    style: const TextStyle(color: Colors.white),
                    dropdownColor: const Color(0xFF2A2A2A),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      prefixIcon: Icon(Icons.payment, color: Color(0xFF00FF00)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'pix', child: Text('PIX', style: TextStyle(color: Colors.white))),
                      DropdownMenuItem(value: 'card', child: Text('Cartão', style: TextStyle(color: Colors.white))),
                      DropdownMenuItem(value: 'cash', child: Text('Dinheiro', style: TextStyle(color: Colors.white))),
                      DropdownMenuItem(value: 'wallet', child: Text('Carteira Digital', style: TextStyle(color: Colors.white))),
                    ],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _paymentMethod = newValue;
                        });
                      }
                    },
                  ),
                ),
                
                const SizedBox(height: 20),

                // Notes
                _buildSectionTitle('Observações (Opcional)'),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF00FF00)),
                  ),
                  child: TextFormField(
                    controller: _notesController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Ex: Aguardar na portaria, ligar ao chegar...',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                      prefixIcon: Icon(Icons.note, color: Color(0xFF00FF00)),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),

                // Schedule Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _scheduleRide,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00FF00),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 3,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Agendar Viagem',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 16),

                // Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Agendamentos devem ser feitos com pelo menos 30 minutos de antecedência',
                          style: TextStyle(color: Colors.blue, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildDateTimeButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF00FF00)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF00FF00)),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}