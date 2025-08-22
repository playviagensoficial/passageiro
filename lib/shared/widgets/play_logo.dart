import 'package:flutter/material.dart';

class PlayLogo extends StatelessWidget {
  final double size;
  final Color? color;
  
  const PlayLogo({
    Key? key,
    this.size = 80.0,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logoColor = color ?? const Color(0xFF00FF00);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Play button triangle
        CustomPaint(
          size: Size(size, size),
          painter: PlayButtonPainter(color: logoColor),
        ),
        const SizedBox(height: 8),
        // Text logo
        Text(
          'play',
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1,
          ),
        ),
        Text(
          'Viagens',
          style: TextStyle(
            fontSize: size * 0.15,
            color: Colors.white,
            height: 0.8,
          ),
        ),
      ],
    );
  }
}

class PlayButtonPainter extends CustomPainter {
  final Color color;
  
  PlayButtonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    // Create play button triangle shape
    path.moveTo(size.width * 0.2, size.height * 0.1);
    path.lineTo(size.width * 0.2, size.height * 0.9);
    path.lineTo(size.width * 0.8, size.height * 0.5);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Horizontal version of the logo for headers
class PlayLogoHorizontal extends StatelessWidget {
  final double height;
  final Color? color;
  
  const PlayLogoHorizontal({
    Key? key,
    this.height = 40.0,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logoColor = color ?? const Color(0xFF00FF00);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Play button triangle
        CustomPaint(
          size: Size(height, height),
          painter: PlayButtonPainter(color: logoColor),
        ),
        const SizedBox(width: 8),
        // Text logo
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'play',
              style: TextStyle(
                fontSize: height * 0.6,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1,
              ),
            ),
            Text(
              'Viagens',
              style: TextStyle(
                fontSize: height * 0.25,
                color: Colors.white,
                height: 0.8,
              ),
            ),
          ],
        ),
      ],
    );
  }
}