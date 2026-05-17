import '../../shared/widgets/wise/wise_card.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/constants/app_colors.dart';


class WellnessScreen extends StatelessWidget {
  const WellnessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(title: const Text('AI Wellness'), backgroundColor: kBackground, foregroundColor: kPrimaryText),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Overall wellness score
          WiseCard(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(children: [
              const Text('Overall Wellness Score', style: TextStyle(color: kSecondaryText, fontSize: 14)),
              const SizedBox(height: 16),
              SizedBox(
                width: 160, height: 160,
                child: CustomPaint(
                  painter: _RadarPainter(),
                  child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Text('82', style: TextStyle(color: kPrimaryText, fontSize: 42, fontWeight: FontWeight.w800)),
                    const Text('/ 100', style: TextStyle(color: kSecondaryText, fontSize: 16)),
                  ])),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Excellent wellness profile', style: TextStyle(color: kSuccessGreen, fontSize: 14, fontWeight: FontWeight.w600)),
            ]),
          ),
          // Wellness dimensions
          const Text('Wellness Dimensions', style: TextStyle(color: kPrimaryText, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...[
            _WellnessDim('Physical Health', 88, Icons.fitness_center_rounded, kSuccessGreen),
            _WellnessDim('Mental Health', 75, Icons.psychology_rounded, kPrimaryText),
            _WellnessDim('Sleep Quality', 82, Icons.bedtime_rounded, kPrimaryText),
            _WellnessDim('Nutrition', 70, Icons.restaurant_rounded, kWarningOrange),
            _WellnessDim('Stress Level', 65, Icons.spa_rounded, kWarningOrange),
            _WellnessDim('Social Wellness', 90, Icons.people_rounded, kSuccessGreen),
          ].map((d) => _DimensionCard(dim: d)),
          const SizedBox(height: 20),
          // AI Recommendations
          const Text('AI Recommendations', style: TextStyle(color: kPrimaryText, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...[
            ('Boost Nutrition', 'Add more leafy greens to reach your daily fiber goal', Icons.eco_rounded),
            ('Stress Management', 'Try 10-minute meditation before bed to improve sleep', Icons.self_improvement_rounded),
            ('Hydration', "You're 2 glasses short of today's water goal", Icons.water_drop_rounded),
          ].map((r) => WiseCard(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: kElevated, borderRadius: BorderRadius.circular(10)),
                child: Icon(r.$3, color: kPrimaryText, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r.$1, style: const TextStyle(color: kPrimaryText, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(r.$2, style: const TextStyle(color: kSecondaryText, fontSize: 13)),
              ])),
            ]),
          )),
        ],
      ),
    );
  }
}

class _DimensionCard extends StatelessWidget {
  final _WellnessDim dim;
  const _DimensionCard({required this.dim});

  @override
  Widget build(BuildContext context) => WiseCard(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(16),
    child: Row(children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: dim.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(dim.icon, color: dim.color, size: 20),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(dim.label, style: const TextStyle(color: kPrimaryText, fontSize: 14, fontWeight: FontWeight.w500)),
          Text('${dim.score}%', style: TextStyle(color: dim.color, fontSize: 14, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: dim.score / 100,
          backgroundColor: kBorder,
          color: dim.color,
          borderRadius: BorderRadius.circular(4),
        ),
      ])),
    ]),
  );
}

class _WellnessDim {
  final String label;
  final int score;
  final IconData icon;
  final Color color;
  const _WellnessDim(this.label, this.score, this.icon, this.color);
}

class _RadarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = kBorder
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    for (var i = 1; i <= 4; i++) {
      canvas.drawCircle(center, radius * i / 4, paint);
    }
    final fillPaint = Paint()
      ..color = kPrimaryText.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    final scores = [0.88, 0.75, 0.82, 0.70, 0.65, 0.90];
    final path = Path();
    for (var i = 0; i < scores.length; i++) {
      final angle = (i * 2 * math.pi / scores.length) - math.pi / 2;
      final r = radius * scores[i];
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint..color = kPrimaryText.withValues(alpha: 0.6)..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(_) => false;
}
