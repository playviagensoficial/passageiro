import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ride/providers/ride_provider.dart';

class VehicleCategorySelector extends StatelessWidget {
  const VehicleCategorySelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RideProvider>(
      builder: (context, rideProvider, child) {
        if (rideProvider.vehicleCategories.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 140,
          color: Colors.grey[900],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Escolha sua categoria',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: rideProvider.vehicleCategories.length,
                  itemBuilder: (context, index) {
                    final category = rideProvider.vehicleCategories[index];
                    final isSelected = rideProvider.selectedCategory?.id == category.id;

                    return GestureDetector(
                      onTap: () => rideProvider.selectCategory(category),
                      child: Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF00CC00) : Colors.grey[800],
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected 
                              ? Border.all(color: const Color(0xFF00CC00), width: 2)
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getIconFromString(category.iconUrl ?? category.icon ?? 'car'),
                              size: 32,
                              color: isSelected ? Colors.black : Colors.white,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              category.displayName ?? category.name,
                              style: TextStyle(
                                color: isSelected ? Colors.black : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            if (category.baseFareValue > 0)
                              Text(
                                'R\$ ${category.baseFareValue.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: isSelected ? Colors.black54 : Colors.grey[400],
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'car':
        return Icons.directions_car;
      case 'car_rental':
        return Icons.car_rental;
      case 'directions_car':
        return Icons.directions_car;
      case 'local_taxi':
        return Icons.local_taxi;
      case 'motorcycle':
        return Icons.motorcycle;
      default:
        return Icons.directions_car;
    }
  }
}