import '../../shared/widgets/wise/wise_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/health_data_provider.dart';

class WearableScreen extends ConsumerStatefulWidget {
  const WearableScreen({super.key});

  @override
  ConsumerState<WearableScreen> createState() => _WearableScreenState();
}

class _WearableScreenState extends ConsumerState<WearableScreen> with SingleTickerProviderStateMixin {
  bool _scanning = false;
  late AnimationController _scanCtrl;

  @override
  void initState() {
    super.initState();
    _scanCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() { _scanCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final healthDataAsync = ref.watch(healthDataProvider);

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Wearable & Health Data'),
        backgroundColor: kBackground,
        foregroundColor: kPrimaryText,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(healthDataProvider),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('SYSTEM HEALTH METRICS', style: TextStyle(color: kTertiaryText, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1)),
          const SizedBox(height: 8),
          healthDataAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error loading health data: $e')),
            data: (data) {
              if (data.containsKey('error')) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, color: kErrorRed, size: 40),
                        const SizedBox(height: 10),
                        Text(data['error']!, style: const TextStyle(color: kErrorRed)),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: () => ref.invalidate(healthDataProvider),
                          child: const Text('Grant Permissions & Retry'),
                        )
                      ],
                    ),
                  ),
                );
              }
              return GridView.count(
                crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.4,
                children: [
                  _MetricCard(Icons.favorite_rounded, 'Heart Rate', '${data['heartRate']} bpm', kErrorRed),
                  _MetricCard(Icons.directions_walk_rounded, 'Steps', data['steps'] ?? '0', kPrimaryText),
                  _MetricCard(Icons.local_fire_department_rounded, 'Calories', '${data['calories']} kcal', kWarningOrange),
                  _MetricCard(Icons.bloodtype_rounded, 'SpO2', data['spo2'] ?? '--', kPrimaryText),
                ],
              );
            },
          ),
          const SizedBox(height: 40),
          const Text('BLUETOOTH DEVICES', style: TextStyle(color: kTertiaryText, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1)),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => setState(() => _scanning = !_scanning),
            icon: _scanning
                ? RotationTransition(turns: _scanCtrl, child: const Icon(Icons.radar_rounded, color: kPrimaryText))
                : const Icon(Icons.bluetooth_searching_rounded, color: kPrimaryText),
            label: Text(_scanning ? 'Scanning for devices...' : 'Scan for Devices',
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
