import 'dart:math';
import 'package:flutter/material.dart';

class AiOrb extends StatefulWidget {
  final double size;
  final bool isActive;

  const AiOrb({super.key, this.size = 60, this.isActive = false});

  @override
  State<AiOrb> createState() => _AiOrbState();
}

class _AiOrbState extends State<AiOrb> with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _rotateCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _rotateCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _rotateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnim, _rotateCtrl]),
      builder: (_, __) => Transform.scale(
        scale: _pulseAnim.value,
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _OrbPainter(_rotateCtrl.value, widget.isActive),
          ),
        ),
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  final double rotation;
  final bool isActive;

  _OrbPainter(this.rotation, this.isActive);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final bgPaint = Paint()
      ..shader = RadialGradient(colors: [
        Colors.white.withValues(alpha: 0.3),
        Colors.white.withValues(alpha: 0.05),
      ]).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, bgPaint);

    for (int i = 0; i < 3; i++) {
      final angle = rotation * 2 * pi + (i * 2 * pi / 3);
      final orbitRadius = radius * 0.6;
      final orbCenter = Offset(
        center.dx + orbitRadius * cos(angle),
        center.dy + orbitRadius * sin(angle),
      );
      canvas.drawCircle(
        orbCenter, radius * 0.15,
        Paint()..color = Colors.white.withValues(alpha: isActive ? 0.8 : 0.4),
      );
    }

    canvas.drawCircle(
      center, radius * 0.35,
      Paint()..color = Colors.white.withValues(alpha: isActive ? 0.9 : 0.6),
    );
  }

  @override
  bool shouldRepaint(_OrbPainter old) => old.rotation != rotation || old.isActive != isActive;
}
