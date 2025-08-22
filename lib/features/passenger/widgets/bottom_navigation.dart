import 'package:flutter/material.dart';

class UberBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const UberBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home,
                label: 'Início',
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.receipt_long,
                label: 'Atividade',
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.person,
                label: 'Conta',
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 60,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24,
                color: isActive ? Colors.black : Colors.grey[600],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive ? Colors.black : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}