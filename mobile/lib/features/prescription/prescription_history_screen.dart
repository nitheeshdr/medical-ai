import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/prescriptions_provider.dart';
import '../../routes/route_names.dart';
import '../../shared/widgets/wise/wise_card.dart';

class PrescriptionHistoryScreen extends ConsumerWidget {
  const PrescriptionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prescriptionsAsync = ref.watch(prescriptionsProvider);

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Prescription History'),
        backgroundColor: kBackground,
        foregroundColor: kPrimaryText,
        elevation: 0,
        leading: BackButton(color: kAccent, onPressed: () => context.pop()),
      ),
      body: prescriptionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: kAccent)),
        error: (e, _) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline_rounded, color: kErrorRed, size: 48),
            const SizedBox(height: 12),
            const Text('Could not load prescriptions', style: TextStyle(color: kSecondaryText)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => ref.invalidate(prescriptionsProvider),
              child: const Text('Retry', style: TextStyle(color: kAccent)),
            ),
          ]),
        ),
        data: (prescriptions) {
          if (prescriptions.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: kBrandGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.document_scanner_outlined, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 20),
                const Text('No prescriptions yet', style: TextStyle(color: kPrimaryText, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                const Text('Scan your first prescription to get started', style: TextStyle(color: kSecondaryText, fontSize: 13)),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: const Text('Scan Prescription'),
                  style: FilledButton.styleFrom(backgroundColor: kAccent, foregroundColor: Colors.white),
                ),
              ]),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemCount: prescriptions.length,
            itemBuilder: (_, i) => _PrescriptionCard(prescription: prescriptions[i]),
          );
        },
      ),
    );
  }
}

class _PrescriptionCard extends StatelessWidget {
  final Prescription prescription;
  const _PrescriptionCard({required this.prescription});

  @override
  Widget build(BuildContext context) {
    final analysis = prescription.aiAnalysis;
    final medicines = analysis.medicines;
    final date = prescription.createdAt;
    final dateStr = '${date.day}/${date.month}/${date.year}';

    return WiseCard(
      onTap: () => context.push(
        RouteNames.scannerResult,
        extra: {'prescriptionId': prescription.id},
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              gradient: kBrandGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.medication_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicines.isNotEmpty ? medicines.first.name : 'Prescription',
                  style: const TextStyle(color: kPrimaryText, fontSize: 14, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                if (medicines.length > 1)
                  Text(
                    '+${medicines.length - 1} more medicine${medicines.length > 2 ? 's' : ''}',
                    style: const TextStyle(color: kSecondaryText, fontSize: 12),
                  ),
                if (analysis.summary.isNotEmpty)
                  Text(
                    analysis.summary,
                    style: const TextStyle(color: kTertiaryText, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(dateStr, style: const TextStyle(color: kTertiaryText, fontSize: 11)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: kSuccessLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('Analyzed', style: TextStyle(color: kSuccessGreen, fontSize: 10, fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, color: kTertiaryText, size: 18),
        ],
      ),
    );
  }
}
