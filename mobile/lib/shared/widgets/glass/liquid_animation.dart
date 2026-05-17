import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class LiquidAnimation extends StatefulWidget {
  final double size;
  final Color color;

  const LiquidAnimation({super.key, this.size = 120, this.color = kPrimaryText});

  @override
  State<LiquidAnimation> createState() => _LiquidAnimationState();
}

class _LiquidAnimationState extends State<LiquidAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _LiquidPainter(_animation.value, widget.color),
      ),
    );
  }
}

class _LiquidPainter extends CustomPainter {
  final double progress;
  final Color color;

  _LiquidPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 2;

    path.moveTo(centerX, centerY - radius);
    for (int i = 0; i <= 360; i++) {
      final angle = i * pi / 180;
      final r = radius + sin(angle * 3 + progress * 2 * pi) * radius * 0.1;
      final x = centerX + r * cos(angle);
      final y = centerY + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(_LiquidPainter old) => old.progress != progress;
}
