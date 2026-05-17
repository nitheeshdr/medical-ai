import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/prescriptions_provider.dart';
import '../../routes/route_names.dart';
import '../../shared/widgets/wise/wise_card.dart';

class ScannerResultScreen extends ConsumerWidget {
  final Map<String, dynamic> data;
  const ScannerResultScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanState = ref.watch(prescriptionScanProvider);

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Prescription Analysis'),
        backgroundColor: kBackground,
        foregroundColor: kPrimaryText,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () => context.push(RouteNames.prescriptionHistory),
          ),
        ],
      ),
      body: scanState.when(
        loading: () => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: kAccent),
              SizedBox(height: 16),
              Text('Analyzing prescription...', style: TextStyle(color: kSecondaryText)),
            ],
          ),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: kErrorRed, size: 48),
              const SizedBox(height: 16),
              Text('Analysis failed', style: const TextStyle(color: kPrimaryText, fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(e.toString(), style: const TextStyle(color: kSecondaryText, fontSize: 13), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(backgroundColor: kAccent),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
        data: (prescription) {
          if (prescription == null) {
            return const Center(
              child: Text('No analysis available', style: TextStyle(color: kSecondaryText)),
            );
          }
          return _ResultBody(prescription: prescription);
        },
      ),
    );
  }
}

class _ResultBody extends StatelessWidget {
  final Prescription prescription;
  const _ResultBody({required this.prescription});

  @override
  Widget build(BuildContext context) {
    final analysis = prescription.aiAnalysis;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary card
        WiseCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: kBrandGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.medication_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('AI Analysis Complete', style: TextStyle(color: kTertiaryText, fontSize: 11)),
                    const SizedBox(height: 2),
                    const Text('Prescription Detected', style: TextStyle(color: kPrimaryText, fontSize: 16, fontWeight: FontWeight.w700)),
                  ]),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: kSuccessLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Verified', style: TextStyle(color: kSuccessGreen, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ]),
              if (analysis.summary.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(color: kBorder),
                const SizedBox(height: 12),
                Text(analysis.summary, style: const TextStyle(color: kSecondaryText, fontSize: 13, height: 1.5)),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Medicines
        if (analysis.medicines.isNotEmpty) ...[
          _SectionHeader('Detected Medicines', Icons.medication_liquid_rounded, kAccent),
          const SizedBox(height: 8),
          ...analysis.medicines.map((m) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: WiseCard(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(m.name, style: const TextStyle(color: kPrimaryText, fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Row(children: [
                  _Pill(m.dosage, kAccentLight, kAccent),
                  const SizedBox(width: 8),
                  _Pill(m.frequency, kAccentLight, kAccent),
                  if (m.duration.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    _Pill(m.duration, kElevated, kSecondaryText),
                  ],
                ]),
              ]),
            ),
          )),
          const SizedBox(height: 8),
        ],

        // Side effects
        if (analysis.sideEffects.isNotEmpty) ...[
          _SectionHeader('Possible Side Effects', Icons.warning_amber_rounded, kWarningOrange),
          const SizedBox(height: 8),
          WiseCard(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: analysis.sideEffects.map((e) => _TagChip(e, kWarningOrange)).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Food restrictions
        if (analysis.foodRestrictions.isNotEmpty) ...[
          _SectionHeader('Food Restrictions', Icons.no_food_rounded, kErrorRed),
          const SizedBox(height: 8),
          WiseCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: analysis.foodRestrictions.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  const Icon(Icons.cancel_rounded, color: kErrorRed, size: 16),
                  const SizedBox(width: 10),
                  Expanded(child: Text(r, style: const TextStyle(color: kSecondaryText, fontSize: 13))),
                ]),
              )).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Warnings
        if (analysis.warnings.isNotEmpty) ...[
          _SectionHeader('Important Warnings', Icons.shield_rounded, kErrorRed),
          const SizedBox(height: 8),
          WiseCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: analysis.warnings.map((w) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.info_outline_rounded, color: kErrorRed, size: 16),
                  const SizedBox(width: 10),
                  Expanded(child: Text(w, style: const TextStyle(color: kSecondaryText, fontSize: 13, height: 1.4))),
                ]),
              )).toList(),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Action button
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.alarm_add_rounded),
            label: const Text('Set Medicine Reminders'),
            style: FilledButton.styleFrom(
              backgroundColor: kAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  const _SectionHeader(this.title, this.icon, this.color);

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, color: color, size: 16),
    const SizedBox(width: 8),
    Text(title, style: const TextStyle(color: kPrimaryText, fontSize: 14, fontWeight: FontWeight.w700)),
  ]);
}

class _Pill extends StatelessWidget {
  final String label;
  final Color bg, fg;
  const _Pill(this.label, this.bg, this.fg);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
    child: Text(label, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w500)),
  );
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color color;
  const _TagChip(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Text(label, style: TextStyle(color: color, fontSize: 12)),
  );
}
