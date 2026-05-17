import '../../shared/widgets/wise/wise_card.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';


class MedicineDetailScreen extends StatelessWidget {
  final String id;
  const MedicineDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(title: Text(id), backgroundColor: kBackground, foregroundColor: kPrimaryText),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(height: 180, decoration: BoxDecoration(color: kElevated, borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.local_pharmacy_rounded, color: kPrimaryText, size: 60)),
          const SizedBox(height: 16),
          WiseCard(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Description', style: TextStyle(color: kPrimaryText, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Used for treating type 2 diabetes. Works by decreasing glucose production and improving insulin sensitivity.', style: TextStyle(color: kSecondaryText, fontSize: 14, height: 1.6)),
          ])),
          const SizedBox(height: 12),
          WiseCard(padding: const EdgeInsets.all(20), child: Column(children: [
            _infoRow('Manufacturer', 'GenPharma Ltd.'),
            const Divider(color: kBorder, height: 16),
            _infoRow('Stock', 'In Stock (142 units)'),
            const Divider(color: kBorder, height: 16),
            _infoRow('Prescription', 'Required'),
          ])),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(backgroundColor: kPrimaryText, foregroundColor: kBlack, padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('Add to Cart', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          )),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(color: kSecondaryText, fontSize: 14)),
      Text(value, style: const TextStyle(color: kPrimaryText, fontSize: 14, fontWeight: FontWeight.w500)),
    ],
  );
}
