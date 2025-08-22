import 'package:flutter/material.dart';
import '../widgets/bottom_navigation.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  void _onBottomNavTap(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/passenger-home');
        break;
      case 1:
        // Already on activity
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/account');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Atividade',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Seu histórico de viagens',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Suas viagens aparecerão aqui',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: UberBottomNavigation(
        currentIndex: 1,
        onTap: _onBottomNavTap,
      ),
    );
  }
}