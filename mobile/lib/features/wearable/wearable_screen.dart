import '../../shared/widgets/wise/wise_card.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';


class WearableScreen extends StatefulWidget {
  const WearableScreen({super.key});

  @override
  State<WearableScreen> createState() => _WearableScreenState();
}

class _WearableScreenState extends State<WearableScreen> with SingleTickerProviderStateMixin {
  bool _scanning = false;
  late AnimationController _scanCtrl;

  final _paired = [
    _Wearable('Apple Watch Ultra 2', 'watchOS 11.0', Icons.watch_rounded, true, '98%'),
    _Wearable('Fitbit Charge 6', 'Firmware 1.182', Icons.fitness_center_rounded, false, '62%'),
  ];

  @override
  void initState() {
    super.initState();
    _scanCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() { _scanCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(title: const Text('Wearable Devices'), backgroundColor: kBackground, foregroundColor: kPrimaryText),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_paired.isNotEmpty) ...[
            const Text('PAIRED DEVICES', style: TextStyle(color: kTertiaryText, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1)),
            const SizedBox(height: 8),
            ..._paired.map((w) => WiseCard(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: w.connected ? kPrimaryText.withValues(alpha: 0.1) : kElevated,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(w.icon, color: w.connected ? kPrimaryText : kSecondaryText, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(w.name, style: const TextStyle(color: kPrimaryText, fontSize: 14, fontWeight: FontWeight.w600)),
                  Text(w.version, style: const TextStyle(color: kSecondaryText, fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(children: [
                    Container(width: 6, height: 6,
                        decoration: BoxDecoration(
                            color: w.connected ? kSuccessGreen : kTertiaryText,
                            shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(w.connected ? 'Connected' : 'Disconnected',
                        style: TextStyle(color: w.connected ? kSuccessGreen : kTertiaryText, fontSize: 11)),
                    const Spacer(),
                    const Icon(Icons.battery_full_rounded, color: kSecondaryText, size: 14),
                    const SizedBox(width: 2),
                    Text(w.battery, style: const TextStyle(color: kSecondaryText, fontSize: 11)),
                  ]),
                ])),
                PopupMenuButton<String>(
                  color: kElevated,
                  icon: const Icon(Icons.more_vert_rounded, color: kSecondaryText),
                  onSelected: (v) {},
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'sync', child: Text('Sync Now', style: TextStyle(color: kPrimaryText))),
                    const PopupMenuItem(value: 'forget', child: Text('Forget Device', style: TextStyle(color: kErrorRed))),
                  ],
                ),
              ]),
            )),
            const SizedBox(height: 20),
          ],
          // Live metrics from wearable
          const Text('LIVE METRICS', style: TextStyle(color: kTertiaryText, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1)),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.4,
            children: [
              _MetricCard(Icons.favorite_rounded, 'Heart Rate', '72 bpm', kSuccessGreen),
              _MetricCard(Icons.directions_walk_rounded, 'Steps', '6,240', kPrimaryText),
              _MetricCard(Icons.local_fire_department_rounded, 'Calories', '342 kcal', kWarningOrange),
              _MetricCard(Icons.bloodtype_rounded, 'SpO2', '98%', kPrimaryText),
            ],
          ),
          const SizedBox(height: 20),
          // Scan button
          OutlinedButton.icon(
            onPressed: () => setState(() => _scanning = !_scanning),
            icon: _scanning
                ? RotationTransition(turns: _scanCtrl, child: const Icon(Icons.radar_rounded, color: kPrimaryText))
                : const Icon(Icons.bluetooth_searching_rounded, color: kPrimaryText),
            label: Text(_scanning ? 'Scanning...' : 'Scan for Devices',
                style: const TextStyle(color: kPrimaryText)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: kBorder),
              padding: const EdgeInsets.all(14),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _MetricCard(IconData icon, String label, String value, Color color) => WiseCard(
  padding: const EdgeInsets.all(14),
  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(icon, color: color, size: 20),
    const SizedBox(height: 6),
    Text(label, style: const TextStyle(color: kSecondaryText, fontSize: 11)),
    Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w700)),
  ]),
);

class _Wearable {
  final String name, version, battery;
  final IconData icon;
  final bool connected;
  const _Wearable(this.name, this.version, this.icon, this.connected, this.battery);
}
