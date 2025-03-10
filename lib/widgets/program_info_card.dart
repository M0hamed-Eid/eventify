import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProgramInfoCard extends StatelessWidget {
  const ProgramInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[700]!,
            Colors.blue[900]!,
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.blue[900]!.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            // Subtle background pattern
            Positioned.fill(
              child: _buildBackgroundPattern(),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(context),

                  const SizedBox(height: 16),

                  // Info Items
                  ..._buildInfoItems(),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildBackgroundPattern() {
    return Opacity(
      opacity: 0.1,
      child: CustomPaint(
        painter: _PatternPainter(),
        child: Container(),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.info_outline_rounded,
          color: Colors.white,
          size: 28,
        ),
        const SizedBox(width: 12),
        Text(
          'PROGRAM INFORMATION',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildInfoItems() {
    return [
      _buildInfoItem(
        Icons.videocam_outlined,
        'Online program via Zoom',
        Colors.cyan[200]!,
      ),
      _buildInfoItem(
        Icons.location_on_outlined,
        '@ACC: In-person program',
        Colors.green[200]!,
      ),
      _buildInfoItem(
        Icons.public_outlined,
        'Open to the Public',
        Colors.orange[200]!,
      ),
      _buildInfoItem(
        Icons.group_outlined,
        'ACC Members Only',
        Colors.purple[200]!,
      ),
    ];
  }

  Widget _buildInfoItem(IconData icon, String text, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for background pattern
class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw diagonal lines
    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(size.width, i),
        paint,
      );
      canvas.drawLine(
        Offset(0, i),
        Offset(i, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}