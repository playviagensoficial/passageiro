import 'package:flutter/material.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(
          top: BorderSide(color: Color(0xFF333333), width: 1),
        ),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1A1A1A),
        selectedItemColor: const Color(0xFF00FF00),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: currentIndex,
        onTap: onTap ?? (index) => _handleNavigation(context, index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Carteira',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Corridas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Conta',
          ),
        ],
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    // Evitar navegação desnecessária para a mesma tela
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/welcome');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/wallet');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/ride-history');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }
}