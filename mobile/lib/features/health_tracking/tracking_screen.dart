import '../../shared/widgets/wise/wise_card.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';


class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  int _waterGlasses = 6;
  double _sleepHours = 7.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(title: const Text('Health Tracking'), backgroundColor: kBackground, foregroundColor: kPrimaryText),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildWaterTracker(),
          const SizedBox(height: 16),
          _buildSleepCard(),
          const SizedBox(height: 16),
          _buildVitalsGrid(),
          const SizedBox(height: 16),
          _buildStepsCard(),
        ],
      ),
    );
  }

  Widget _buildWaterTracker() => WiseCard(
    padding: const EdgeInsets.all(20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.water_drop_rounded, color: kPrimaryText, size: 20),
        const SizedBox(width: 8),
        const Text('Water Intake', style: TextStyle(color: kPrimaryText, fontSize: 16, fontWeight: FontWeight.w600)),
        const Spacer(),
        Text('$_waterGlasses / 8 glasses', style: const TextStyle(color: kSecondaryText, fontSize: 13)),
      ]),
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(8, (i) => GestureDetector(
          onTap: () => setState(() => _waterGlasses = i + 1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 28, height: 40,
            decoration: BoxDecoration(
              color: i < _waterGlasses ? kPrimaryText : kBorder,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.local_drink_rounded, color: i < _waterGlasses ? kBlack : kElevated, size: 16),
          ),
        )),
      ),
      const SizedBox(height: 12),
      LinearProgressIndicator(value: _waterGlasses / 8, backgroundColor: kBorder, color: kPrimaryText, borderRadius: BorderRadius.circular(4)),
    ]),
  );

  Widget _buildSleepCard() => WiseCard(
    padding: const EdgeInsets.all(20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.bedtime_rounded, color: kPrimaryText, size: 20),
        const SizedBox(width: 8),
        const Text('Sleep', style: TextStyle(color: kPrimaryText, fontSize: 16, fontWeight: FontWeight.w600)),
        const Spacer(),
        Text('${_sleepHours}h', style: const TextStyle(color: kSecondaryText, fontSize: 13)),
      ]),
      const SizedBox(height: 16),
      Slider(
        value: _sleepHours, min: 0, max: 12, divisions: 24,
        activeColor: kPrimaryText, inactiveColor: kBorder,
        onChanged: (v) => setState(() => _sleepHours = (v * 2).round() / 2),
      ),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('0h', style: TextStyle(color: kTertiaryText, fontSize: 11)),
        Text('Recommended: 7-9h', style: TextStyle(color: _sleepHours >= 7 ? kSuccessGreen : kWarningOrange, fontSize: 12)),
        const Text('12h', style: TextStyle(color: kTertiaryText, fontSize: 11)),
      ]),
    ]),
  );

  Widget _buildVitalsGrid() => GridView.count(
    crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
    crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.3,
    children: [
      _vitalCard(Icons.favorite_rounded, 'Heart Rate', '72', 'bpm', kSuccessGreen),
      _vitalCard(Icons.bloodtype_rounded, 'Blood Pressure', '120/80', 'mmHg', kPrimaryText),
      _vitalCard(Icons.thermostat_rounded, 'Temperature', '98.6', '°F', kPrimaryText),
      _vitalCard(Icons.air_rounded, 'SpO2', '98', '%', kSuccessGreen),
    ],
  );

  Widget _vitalCard(IconData icon, String label, String value, String unit, Color color) => WiseCard(
    padding: const EdgeInsets.all(14),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, color: color, size: 22),
      const SizedBox(height: 8),
      Text(label, style: const TextStyle(color: kSecondaryText, fontSize: 11)),
      Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w700)),
      Text(unit, style: const TextStyle(color: kTertiaryText, fontSize: 11)),
    ]),
  );

  Widget _buildStepsCard() => WiseCard(
    padding: const EdgeInsets.all(20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.directions_walk_rounded, color: kPrimaryText, size: 20),
        const SizedBox(width: 8),
        const Text('Steps Today', style: TextStyle(color: kPrimaryText, fontSize: 16, fontWeight: FontWeight.w600)),
      ]),
      const SizedBox(height: 12),
      const Text('6,240', style: TextStyle(color: kPrimaryText, fontSize: 36, fontWeight: FontWeight.w700)),
      const Text('Goal: 10,000 steps', style: TextStyle(color: kSecondaryText, fontSize: 13)),
      const SizedBox(height: 12),
      LinearProgressIndicator(value: 6240 / 10000, backgroundColor: kBorder, color: kPrimaryText, borderRadius: BorderRadius.circular(4)),
      const SizedBox(height: 8),
      const Text('62% of daily goal', style: TextStyle(color: kSecondaryText, fontSize: 12)),
    ]),
  );
}
