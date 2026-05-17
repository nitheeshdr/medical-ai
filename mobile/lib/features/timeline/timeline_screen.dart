import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  static const _events = [
    _Event('Blood Test Results', 'All markers within normal range. Vitamin D slightly low.', 'May 10, 2026', Icons.science_rounded, kSuccessGreen, 'Lab Report'),
    _Event('Doctor Visit', 'Annual checkup with Dr. Johnson. BP 118/78, healthy weight.', 'Apr 28, 2026', Icons.medical_services_rounded, kPrimaryText, 'Appointment'),
    _Event('Prescription Added', 'Vitamin D3 2000 IU — 3 months course started', 'Apr 28, 2026', Icons.medication_rounded, kWarningOrange, 'Prescription'),
    _Event('MRI Scan', 'Lumbar spine MRI — no abnormalities detected', 'Mar 15, 2026', Icons.biotech_rounded, kPrimaryText, 'Imaging'),
    _Event('Emergency Visit', 'Severe allergic reaction. Treated with antihistamines. Penicillin allergy confirmed.', 'Feb 3, 2026', Icons.emergency_rounded, kErrorRed, 'Emergency'),
    _Event('Vaccination', 'Flu vaccine administered. Annual booster complete.', 'Jan 20, 2026', Icons.vaccines_rounded, kSuccessGreen, 'Vaccine'),
    _Event('ECG Report', 'Normal sinus rhythm. No cardiac abnormalities.', 'Dec 12, 2025', Icons.monitor_heart_rounded, kSuccessGreen, 'Lab Report'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(title: const Text('Medical Timeline'), backgroundColor: kBackground, foregroundColor: kPrimaryText),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _events.length,
        itemBuilder: (_, i) => _TimelineItem(event: _events[i], isLast: i == _events.length - 1),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final _Event event;
  final bool isLast;
  const _TimelineItem({required this.event, required this.isLast});

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Timeline spine
      SizedBox(width: 40, child: Column(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: event.color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: event.color.withValues(alpha: 0.4)),
          ),
          child: Icon(event.icon, color: event.color, size: 18),
        ),
        if (!isLast) Expanded(child: Container(
          width: 2, margin: const EdgeInsets.symmetric(vertical: 4),
          color: kBorder,
        )),
      ])),
      const SizedBox(width: 14),
      // Content
      Expanded(child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kBorder),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(event.title,
                  style: const TextStyle(color: kPrimaryText, fontSize: 14, fontWeight: FontWeight.w600))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: kElevated, borderRadius: BorderRadius.circular(8)),
                child: Text(event.category,
                    style: const TextStyle(color: kSecondaryText, fontSize: 10, fontWeight: FontWeight.w500)),
              ),
            ]),
            const SizedBox(height: 6),
            Text(event.description, style: const TextStyle(color: kSecondaryText, fontSize: 12, height: 1.4)),
            const SizedBox(height: 8),
            Text(event.date, style: const TextStyle(color: kTertiaryText, fontSize: 11)),
          ]),
        ),
      )),
    ]),
  );
}

class _Event {
  final String title, description, date, category;
  final IconData icon;
  final Color color;
  const _Event(this.title, this.description, this.date, this.icon, this.color, this.category);
}
