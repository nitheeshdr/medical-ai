import '../../shared/widgets/wise/wise_card.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';


class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  String _filter = 'All';
  static const _filters = ['All', 'Reports', 'Prescriptions', 'Insurance', 'Imaging'];

  static const _docs = [
    _Doc('Blood Test Report', 'May 10, 2026', 'PDF', '1.2 MB', Icons.science_rounded, 'Reports', kSuccessGreen),
    _Doc('Metformin Prescription', 'Apr 28, 2026', 'PDF', '0.4 MB', Icons.medication_rounded, 'Prescriptions', kWarningOrange),
    _Doc('MRI Scan - Lumbar', 'Mar 15, 2026', 'DICOM', '48 MB', Icons.biotech_rounded, 'Imaging', kPrimaryText),
    _Doc('Health Insurance Card', 'Jan 1, 2026', 'JPG', '0.8 MB', Icons.health_and_safety_rounded, 'Insurance', kPrimaryText),
    _Doc('ECG Report', 'Dec 12, 2025', 'PDF', '2.1 MB', Icons.monitor_heart_rounded, 'Reports', kSuccessGreen),
    _Doc('Chest X-Ray', 'Nov 5, 2025', 'JPEG', '12 MB', Icons.biotech_rounded, 'Imaging', kPrimaryText),
    _Doc('Vitamin D Prescription', 'Oct 20, 2025', 'PDF', '0.3 MB', Icons.medication_rounded, 'Prescriptions', kWarningOrange),
  ];

  List<_Doc> get _filtered => _filter == 'All' ? _docs : _docs.where((d) => d.category == _filter).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Document Wallet'),
        backgroundColor: kBackground,
        foregroundColor: kPrimaryText,
        actions: [
          IconButton(icon: const Icon(Icons.add_rounded), onPressed: () {}),
        ],
      ),
      body: Column(children: [
        // Storage usage
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
          child: Row(children: [
            const Icon(Icons.cloud_done_rounded, color: kSuccessGreen, size: 20),
            const SizedBox(width: 10),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Cloud Storage', style: TextStyle(color: kPrimaryText, fontSize: 13, fontWeight: FontWeight.w600)),
              Text('64.8 MB of 5 GB used', style: TextStyle(color: kSecondaryText, fontSize: 11)),
            ])),
            const Text('1%', style: TextStyle(color: kSuccessGreen, fontSize: 13, fontWeight: FontWeight.w700)),
          ]),
        ),
        // Filter chips
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: _filters.map((f) => GestureDetector(
              onTap: () => setState(() => _filter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: _filter == f ? kPrimaryText : kElevated,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _filter == f ? kPrimaryText : kBorder),
                ),
                child: Text(f, style: TextStyle(
                    color: _filter == f ? kBlack : kSecondaryText,
                    fontSize: 13, fontWeight: FontWeight.w500)),
              ),
            )).toList(),
          ),
        ),
        // Documents list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: _filtered.length,
            itemBuilder: (ctx, i) => _DocCard(doc: _filtered[i]),
          ),
        ),
      ]),
    );
  }
}

class _DocCard extends StatelessWidget {
  final _Doc doc;
  const _DocCard({required this.doc});

  @override
  Widget build(BuildContext context) => WiseCard(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    child: Row(children: [
      Container(
        width: 48, height: 56,
        decoration: BoxDecoration(
          color: doc.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: doc.color.withValues(alpha: 0.2)),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(doc.icon, color: doc.color, size: 20),
          const SizedBox(height: 2),
          Text(doc.type, style: TextStyle(color: doc.color, fontSize: 8, fontWeight: FontWeight.w700)),
        ]),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(doc.name, style: const TextStyle(color: kPrimaryText, fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text('${doc.date} • ${doc.size}', style: const TextStyle(color: kSecondaryText, fontSize: 12)),
      ])),
      Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(icon: const Icon(Icons.share_outlined, color: kSecondaryText, size: 20), onPressed: () {}),
        IconButton(icon: const Icon(Icons.download_rounded, color: kSecondaryText, size: 20), onPressed: () {}),
      ]),
    ]),
  );
}

class _Doc {
  final String name, date, type, size, category;
  final IconData icon;
  final Color color;
  const _Doc(this.name, this.date, this.type, this.size, this.icon, this.category, this.color);
}
