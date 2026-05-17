import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../shared/widgets/wise/wise_badge.dart';
import '../../shared/widgets/wise/wise_card.dart';

// ── Provider ───────────────────────────────────────────────────────────────────

final _reportDetailProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, id) async {
  if (id.isEmpty) return {};
  final api = ref.read(apiClientProvider);
  final res = await api.get('/reports/$id');
  final body = res.data as Map<String, dynamic>;
  return Map<String, dynamic>.from(body['data'] ?? body);
});

// ── Screen ─────────────────────────────────────────────────────────────────────

class ReportAnalysisScreen extends ConsumerWidget {
  final String reportId;
  const ReportAnalysisScreen({super.key, required this.reportId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(_reportDetailProvider(reportId));
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Analysis'),
        actions: [
          IconButton(icon: const Icon(Icons.share_rounded), onPressed: () {}),
        ],
      ),
      body: reportAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.error_outline, size: 48, color: cs.error),
            const SizedBox(height: 16),
            Text('Could not load report', style: tt.titleMedium),
            const SizedBox(height: 8),
            Text(e.toString(), style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => ref.invalidate(_reportDetailProvider(reportId)),
              child: const Text('Retry'),
            ),
          ]),
        ),
        data: (report) {
          if (report.isEmpty) return const Center(child: Text('Report not found'));
          final ai       = report['aiAnalysis'] as Map<String, dynamic>? ?? {};
          final summary  = ai['summary'] as String? ?? 'AI analysis pending…';
          final highlights = (ai['highlights'] as List?)?.cast<Map>() ?? [];
          final recs     = (ai['recommendations'] as List?)?.cast<String>() ?? [];
          final needsAttn = ai['needsAttention'] as bool? ?? false;
          final type     = report['type'] as String? ?? 'Report';
          final fileName = report['fileName'] as String? ?? type;
          final createdAt = report['createdAt'] as String? ?? '';
          final date = createdAt.isNotEmpty
              ? DateTime.tryParse(createdAt)?.toLocal().toString().substring(0, 10) ?? ''
              : '';

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              // Header
              Card.filled(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    CircleAvatar(
                      backgroundColor: cs.primaryContainer,
                      child: Icon(Icons.analytics_outlined, color: cs.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(fileName, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text('$type · $date',
                            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                      ],
                    )),
                    if (needsAttn)
                      WiseBadge(label: '⚠ Attention', type: WiseBadgeType.warning)
                    else
                      WiseBadge(label: '✓ Normal', type: WiseBadgeType.success),
                  ]),
                ),
              ),
              const SizedBox(height: 16),

              // AI Summary
              WiseCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.psychology_rounded, color: cs.primary, size: 20),
                      const SizedBox(width: 8),
                      Text('AI Summary',
                          style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    ]),
                    const SizedBox(height: 12),
                    Text(summary,
                        style: tt.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant, height: 1.6)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Highlights
              if (highlights.isNotEmpty) ...[
                Text('Key Values', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                ...highlights.map((h) => _HighlightTile(highlight: h)),
                const SizedBox(height: 16),
              ],

              // Recommendations
              if (recs.isNotEmpty) ...[
                Text('Recommendations',
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                WiseCard(
                  child: Column(
                    children: recs.asMap().entries.map((e) => Padding(
                      padding: EdgeInsets.only(bottom: e.key < recs.length - 1 ? 12 : 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 22, height: 22,
                            decoration: BoxDecoration(
                              color: cs.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text('${e.key + 1}',
                                  style: TextStyle(
                                      color: cs.primary, fontSize: 11, fontWeight: FontWeight.w700)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(e.value,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(height: 1.5)),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

// ── Highlight tile ─────────────────────────────────────────────────────────────

class _HighlightTile extends StatelessWidget {
  final Map highlight;
  const _HighlightTile({required this.highlight});

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final tt     = Theme.of(context).textTheme;
    final status = highlight['status'] as String? ?? 'normal';
    final color  = switch (status) {
      'high'     => cs.error,
      'low'      => Colors.orange,
      'critical' => cs.error,
      _          => const Color(0xFF10B981),
    };
    final badge = switch (status) {
      'high'     => WiseBadgeType.error,
      'low'      => WiseBadgeType.warning,
      'critical' => WiseBadgeType.error,
      _          => WiseBadgeType.success,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: WiseCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(children: [
          Container(width: 4, height: 36,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(highlight['label'] as String? ?? '',
                  style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
              Text(highlight['value'] as String? ?? '',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            ],
          )),
          WiseBadge(label: status[0].toUpperCase() + status.substring(1), type: badge),
        ]),
      ),
    );
  }
}
