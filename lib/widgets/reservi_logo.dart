import 'package:flutter/material.dart';
import 'dart:math' as math;

class ReserviLogo extends StatelessWidget {
  final double? iconSize;
  final double? fontSize;
  final Color? textColor;
  final bool showText;

  const ReserviLogo({
    Key? key,
    this.iconSize,
    this.fontSize,
    this.textColor,
    this.showText = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double iconSizeValue = iconSize ?? 48;
    final double fontSizeValue = fontSize ?? 28;
    final Color textColorValue = textColor ?? Colors.white;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Gradient square with star and sparkles
        Container(
          width: iconSizeValue,
          height: iconSizeValue,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF9333EA), // Purple
                Color(0xFF2563EB), // Blue
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Main star (4-pointed, aligned with cardinal directions)
              CustomPaint(
                size: Size(iconSizeValue * 0.5, iconSizeValue * 0.5),
                painter: _StarPainter(),
              ),
              // Small circle sparkle (bottom-left of star center)
              Positioned(
                bottom: iconSizeValue * 0.25,
                left: iconSizeValue * 0.25,
                child: Container(
                  width: iconSizeValue * 0.08,
                  height: iconSizeValue * 0.08,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Small plus sign sparkle (top-right of star center)
              Positioned(
                top: iconSizeValue * 0.25,
                right: iconSizeValue * 0.25,
                child: CustomPaint(
                  size: Size(iconSizeValue * 0.12, iconSizeValue * 0.12),
                  painter: _PlusSignPainter(),
                ),
              ),
            ],
          ),
        ),
        if (showText) ...[
          SizedBox(width: 12),
          Text(
            'Reservi',
            style: TextStyle(
              fontSize: fontSizeValue,
              fontWeight: FontWeight.bold,
              color: textColorValue,
              letterSpacing: 1,
            ),
          ),
        ],
      ],
    );
  }
}

// Custom painter for 4-pointed star aligned with cardinal directions
class _StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 * 0.65;
    final innerRadius = size.width / 2 * 0.25;

    final path = Path();
    
    // Draw 4-pointed star aligned with cardinal directions (top, right, bottom, left)
    // Start from top point
    path.moveTo(center.dx, center.dy - outerRadius);
    
    // Top-right to right point
    path.lineTo(center.dx + innerRadius, center.dy - innerRadius);
    path.lineTo(center.dx + outerRadius, center.dy);
    
    // Right-bottom to bottom point
    path.lineTo(center.dx + innerRadius, center.dy + innerRadius);
    path.lineTo(center.dx, center.dy + outerRadius);
    
    // Bottom-left to left point
    path.lineTo(center.dx - innerRadius, center.dy + innerRadius);
    path.lineTo(center.dx - outerRadius, center.dy);
    
    // Left-top back to top
    path.lineTo(center.dx - innerRadius, center.dy - innerRadius);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for plus sign sparkle
class _PlusSignPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final lineLength = size.width * 0.4;

    // Draw horizontal line
    canvas.drawLine(
      Offset(center.dx - lineLength / 2, center.dy),
      Offset(center.dx + lineLength / 2, center.dy),
      paint,
    );

    // Draw vertical line
    canvas.drawLine(
      Offset(center.dx, center.dy - lineLength / 2),
      Offset(center.dx, center.dy + lineLength / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

