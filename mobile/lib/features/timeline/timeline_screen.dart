import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/network/api_client.dart';
import '../../routes/route_names.dart';

// Fetches user's medical timeline from the backend
final timelineProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final api = ref.read(apiClientProvider);
  try {
    final res = await api.get('/timeline');
    final data = res.data as Map<String, dynamic>;
    final list = data['events'] as List? ?? [];
    return list.cast<Map<String, dynamic>>();
  } catch (_) {
    return [];
  }
});

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final timelineAsync = ref.watch(timelineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Timeline'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(timelineProvider),
          ),
        ],
      ),
      body: timelineAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _EmptyTimeline(cs: cs, tt: tt),
        data: (events) => events.isEmpty
            ? _EmptyTimeline(cs: cs, tt: tt)
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                itemCount: events.length,
                itemBuilder: (_, i) => _TimelineItem(
                  event: events[i],
                  isLast: i == events.length - 1,
                  cs: cs,
                  tt: tt,
                ),
              ),
      ),
    );
  }
}

// Maps backend event type strings to icons and colours
IconData _iconFor(String type) {
  switch (type.toLowerCase()) {
    case 'report':
    case 'lab':
      return Icons.science_rounded;
    case 'appointment':
    case 'visit':
      return Icons.medical_services_rounded;
    case 'prescription':
      return Icons.medication_rounded;
    case 'imaging':
    case 'mri':
    case 'xray':
    case 'ct':
      return Icons.biotech_rounded;
    case 'emergency':
      return Icons.emergency_rounded;
    case 'vaccine':
    case 'vaccination':
      return Icons.vaccines_rounded;
    case 'ecg':
      return Icons.monitor_heart_rounded;
    default:
      return Icons.health_and_safety_rounded;
  }
}

Color _colorFor(String type, ColorScheme cs) {
  switch (type.toLowerCase()) {
    case 'emergency':
      return cs.error;
    case 'appointment':
    case 'visit':
      return cs.primary;
    case 'prescription':
      return cs.tertiary;
    default:
      return cs.secondary;
  }
}

class _TimelineItem extends StatelessWidget {
  final Map<String, dynamic> event;
  final bool isLast;
  final ColorScheme cs;
  final TextTheme tt;
  const _TimelineItem({required this.event, required this.isLast, required this.cs, required this.tt});

  @override
  Widget build(BuildContext context) {
    final title = event['title'] as String? ?? 'Event';
    final description = event['description'] as String? ?? '';
    final category = event['category'] as String? ?? event['type'] as String? ?? '';
    final dateRaw = event['date'] as String? ?? event['createdAt'] as String? ?? '';
    final dateStr = dateRaw.isNotEmpty ? _fmtDate(dateRaw) : '';
    final color = _colorFor(category, cs);
    final icon = _iconFor(category);

    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Spine
        SizedBox(width: 44, child: Column(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          if (!isLast)
            Expanded(child: Container(
              width: 2,
              margin: const EdgeInsets.symmetric(vertical: 4),
              color: cs.outlineVariant,
            )),
        ])),
        const SizedBox(width: 12),
        // Card
        Expanded(child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Card.outlined(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(title,
                      style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
                  if (category.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(category,
                          style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                    ),
                ]),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(description,
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant, height: 1.4)),
                ],
                if (dateStr.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(dateStr, style: tt.labelSmall?.copyWith(color: cs.outline)),
                ],
              ]),
            ),
          ),
        )),
      ]),
    );
  }

  String _fmtDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${months[d.month - 1]} ${d.day}, ${d.year}';
    } catch (_) {
      return iso;
    }
  }
}

class _EmptyTimeline extends StatelessWidget {
  final ColorScheme cs;
  final TextTheme tt;
  const _EmptyTimeline({required this.cs, required this.tt});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: cs.surfaceContainerHighest,
          child: Icon(Icons.history_rounded, size: 36, color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        Text('No medical history yet', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(
          'Your timeline will populate as you upload reports, scan prescriptions, and book appointments.',
          textAlign: TextAlign.center,
          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant, height: 1.5),
        ),
        const SizedBox(height: 24),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          OutlinedButton.icon(
            icon: const Icon(Icons.upload_file_rounded, size: 16),
            label: const Text('Upload Report'),
            onPressed: () => context.push(RouteNames.reports),
            style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          ),
          const SizedBox(width: 10),
          OutlinedButton.icon(
            icon: const Icon(Icons.document_scanner_outlined, size: 16),
            label: const Text('Scan Rx'),
            onPressed: () => context.push(RouteNames.scanner),
            style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          ),
        ]),
      ]),
    ),
  );
}
