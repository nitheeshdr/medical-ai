import '../../shared/widgets/wise/wise_card.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';


class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  bool _sosActivated = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }

  @override
  void dispose() { _pulseCtrl.dispose(); super.dispose(); }

  void _activateSOS() {
    setState(() => _sosActivated = true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('🚨 Emergency alert sent to your contacts and nearby services!'),
      backgroundColor: kErrorRed, duration: Duration(seconds: 4),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(title: const Text('Emergency SOS'), backgroundColor: kBackground, foregroundColor: kPrimaryText),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: GestureDetector(
              onLongPress: _activateSOS,
              child: AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, __) => Container(
                  width: 160, height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kErrorRed,
                    boxShadow: [BoxShadow(
                      color: kErrorRed.withValues(alpha: _pulseCtrl.value * 0.6),
                      blurRadius: 40 * _pulseCtrl.value,
                      spreadRadius: 20 * _pulseCtrl.value,
                    )],
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.emergency_rounded, color: kPrimaryText, size: 48),
                    const SizedBox(height: 4),
                    Text(_sosActivated ? 'ACTIVATED' : 'SOS',
                        style: const TextStyle(color: kPrimaryText, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 2)),
                    const Text('Hold to activate', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ]),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          if (_sosActivated)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: kErrorRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: kErrorRed.withValues(alpha: 0.3))),
              child: const Row(children: [
                Icon(Icons.check_circle_rounded, color: kSuccessGreen, size: 20),
                SizedBox(width: 10),
                Expanded(child: Text('Emergency services and contacts have been notified with your location.', style: TextStyle(color: kPrimaryText, fontSize: 13))),
              ]),
            ),
          const SizedBox(height: 24),
          const Text('Emergency Contacts', style: TextStyle(color: kPrimaryText, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...[
            _Contact('Dr. Sarah Johnson', '+1 (555) 123-4567', Icons.medical_services_rounded),
            _Contact('Jane Johnson (Spouse)', '+1 (555) 987-6543', Icons.favorite_rounded),
            _Contact('Emergency Services', '911', Icons.local_hospital_rounded),
          ].map((c) => WiseCard(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: kBorder, borderRadius: BorderRadius.circular(10)),
                  child: Icon(c.icon, color: kPrimaryText, size: 20)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(c.name, style: const TextStyle(color: kPrimaryText, fontSize: 14, fontWeight: FontWeight.w600)),
                Text(c.phone, style: const TextStyle(color: kSecondaryText, fontSize: 12)),
              ])),
              IconButton(icon: const Icon(Icons.call_rounded, color: kSuccessGreen), onPressed: () {}),
            ]),
          )),
          const SizedBox(height: 20),
          const Text('Nearby Hospitals', style: TextStyle(color: kPrimaryText, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          WiseCard(padding: const EdgeInsets.all(16), child: Column(children: [
            _hospitalRow('City General Hospital', '0.8 km', '5 min'),
            const Divider(color: kBorder, height: 16),
            _hospitalRow('St. Mary\'s Medical Center', '1.4 km', '8 min'),
          ])),
        ],
      ),
    );
  }

  Widget _hospitalRow(String name, String dist, String time) => Row(children: [
    const Icon(Icons.local_hospital_rounded, color: kErrorRed, size: 18),
    const SizedBox(width: 10),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(name, style: const TextStyle(color: kPrimaryText, fontSize: 13, fontWeight: FontWeight.w600)),
      Text('$dist • $time away', style: const TextStyle(color: kSecondaryText, fontSize: 11)),
    ])),
    TextButton(onPressed: () {}, child: const Text('Navigate', style: TextStyle(color: kPrimaryText, fontSize: 12))),
  ]);
}

class _Contact { final String name, phone; final IconData icon; const _Contact(this.name, this.phone, this.icon); }
