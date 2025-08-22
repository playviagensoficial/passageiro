import 'package:flutter/material.dart';

class SimpleMapPlaceholder extends StatelessWidget {
  const SimpleMapPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey[800]!,
            Colors.grey[900]!,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Grid pattern
          CustomPaint(
            size: Size.infinite,
            painter: GridPainter(),
          ),
          
          // Center marker
          const Center(
            child: Icon(
              Icons.location_on,
              color: Color(0xFF00CC00),
              size: 48,
            ),
          ),
          
          // Map info
          const Positioned(
            bottom: 20,
            left: 20,
            child: Card(
              color: Colors.black87,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Mapa simulado\n(Configure Google Maps API)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1;

    const spacing = 40.0;
    
    // Vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    
    // Horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}