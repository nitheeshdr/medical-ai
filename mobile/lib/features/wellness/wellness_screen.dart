import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/network/api_client.dart';
import '../../routes/route_names.dart';

// Fetches AI wellness insights from backend
final wellnessProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiClientProvider);
  try {
    final res = await api.get('/wellness/summary');
    return Map<String, dynamic>.from(res.data as Map? ?? {});
  } catch (_) {
    return {};
  }
});

class WellnessScreen extends ConsumerWidget {
  const WellnessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final wellnessAsync = ref.watch(wellnessProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Wellness'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(wellnessProvider),
          ),
        ],
      ),
      body: wellnessAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _WellnessContent(data: const {}, cs: cs, tt: tt),
        data: (data) => _WellnessContent(data: data, cs: cs, tt: tt),
      ),
    );
  }
}

class _WellnessContent extends StatelessWidget {
  final Map<String, dynamic> data;
  final ColorScheme cs;
  final TextTheme tt;
  const _WellnessContent({required this.data, required this.cs, required this.tt});

  bool get _hasData => data.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final score = (data['overallScore'] as num?)?.toInt();
    final insights = (data['insights'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final dimensions = (data['dimensions'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        // ── Score card ───────────────────────────────────────────────────
        Card(
          elevation: 0,
          color: cs.primaryContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: score != null
                ? Column(children: [
                    Text('Overall Wellness Score',
                        style: tt.bodySmall?.copyWith(color: cs.onPrimaryContainer.withValues(alpha: 0.7))),
                    const SizedBox(height: 16),
                    Stack(alignment: Alignment.center, children: [
                      SizedBox(
                        width: 120, height: 120,
                        child: CircularProgressIndicator(
                          value: score / 100,
                          strokeWidth: 10,
                          backgroundColor: cs.primary.withValues(alpha: 0.15),
                          valueColor: AlwaysStoppedAnimation(cs.primary),
                        ),
                      ),
                      Column(mainAxisSize: MainAxisSize.min, children: [
                        Text('$score', style: tt.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800, color: cs.onPrimaryContainer)),
                        Text('/ 100', style: tt.bodySmall?.copyWith(
                            color: cs.onPrimaryContainer.withValues(alpha: 0.6))),
                      ]),
                    ]),
                    const SizedBox(height: 12),
                    Text(
                      score >= 80 ? 'Excellent wellness profile 🎉'
                          : score >= 60 ? 'Good — keep improving!'
                          : 'Needs attention — log more data',
                      style: tt.bodySmall?.copyWith(
                        color: score >= 80 ? cs.primary : cs.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ])
                : _NoDataPrompt(cs: cs, tt: tt),
          ),
        ),
        const SizedBox(height: 20),

        // ── Wellness dimensions (from API) ───────────────────────────────
        if (dimensions.isNotEmpty) ...[
          Text('Wellness Dimensions', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...dimensions.map((d) => _DimensionCard(dim: d, cs: cs, tt: tt)),
          const SizedBox(height: 20),
        ],

        // ── AI recommendations (from API) ────────────────────────────────
        Text('AI Recommendations', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),

        if (insights.isEmpty)
          _InsightEmptyState(cs: cs, tt: tt)
        else
          ...insights.map((r) => _InsightCard(insight: r, cs: cs, tt: tt)),
      ],
    );
  }
}

class _NoDataPrompt extends StatelessWidget {
  final ColorScheme cs;
  final TextTheme tt;
  const _NoDataPrompt({required this.cs, required this.tt});

  @override
  Widget build(BuildContext context) => Column(children: [
    Icon(Icons.bar_chart_rounded, size: 40, color: cs.onPrimaryContainer.withValues(alpha: 0.4)),
    const SizedBox(height: 12),
    Text('No wellness data yet', style: tt.bodyMedium?.copyWith(
        color: cs.onPrimaryContainer, fontWeight: FontWeight.w600)),
    const SizedBox(height: 6),
    Text(
      'Log your vitals, sleep, and water daily to unlock your personalised wellness score.',
      textAlign: TextAlign.center,
      style: tt.bodySmall?.copyWith(color: cs.onPrimaryContainer.withValues(alpha: 0.7), height: 1.5),
    ),
    const SizedBox(height: 16),
    OutlinedButton.icon(
      icon: const Icon(Icons.monitor_heart_outlined, size: 16),
      label: const Text('Go to Health Tracking'),
      onPressed: () => context.push(RouteNames.healthTracking),
      style: OutlinedButton.styleFrom(
        foregroundColor: cs.onPrimaryContainer,
        side: BorderSide(color: cs.onPrimaryContainer.withValues(alpha: 0.4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  ]);
}

class _DimensionCard extends StatelessWidget {
  final Map<String, dynamic> dim;
  final ColorScheme cs;
  final TextTheme tt;
  const _DimensionCard({required this.dim, required this.cs, required this.tt});

  @override
  Widget build(BuildContext context) {
    final label = dim['label'] as String? ?? '';
    final score = (dim['score'] as num?)?.toInt() ?? 0;
    final color = score >= 80 ? cs.primary : score >= 60 ? cs.tertiary : cs.error;

    return Card.outlined(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text('$score', style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 14)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: score / 100,
                minHeight: 6,
                backgroundColor: cs.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ])),
          const SizedBox(width: 8),
          Text('$score%', style: tt.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final Map<String, dynamic> insight;
  final ColorScheme cs;
  final TextTheme tt;
  const _InsightCard({required this.insight, required this.cs, required this.tt});

  @override
  Widget build(BuildContext context) {
    final title = insight['title'] as String? ?? '';
    final body = insight['body'] as String? ?? '';
    return Card.outlined(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: cs.secondaryContainer,
            child: Icon(Icons.psychology_rounded, color: cs.secondary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(body, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant, height: 1.5)),
          ])),
        ]),
      ),
    );
  }
}

class _InsightEmptyState extends StatelessWidget {
  final ColorScheme cs;
  final TextTheme tt;
  const _InsightEmptyState({required this.cs, required this.tt});

  @override
  Widget build(BuildContext context) => Card.outlined(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Icon(Icons.lightbulb_outline_rounded, color: cs.onSurfaceVariant, size: 32),
        const SizedBox(height: 10),
        Text('No AI insights yet', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(
          'Log vitals and health data for a few days. The AI will then generate personalised wellness insights for you.',
          textAlign: TextAlign.center,
          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant, height: 1.5),
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
          label: const Text('Ask the AI Assistant'),
          onPressed: () => context.push(RouteNames.chatbot),
          style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        ),
      ]),
    ),
  );
}
