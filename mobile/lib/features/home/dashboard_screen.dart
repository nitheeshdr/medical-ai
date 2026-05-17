import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../routes/route_names.dart';
import '../../shared/widgets/wise/wise_badge.dart';
import '../../shared/widgets/wise/wise_card.dart';
import '../appointments/appointment_list_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user    = ref.watch(currentUserProvider);
    final name    = (user?['name'] as String? ?? '').split(' ').firstOrNull ?? 'User';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    final bloodType  = user?['bloodType']  as String? ?? '';
    final conditions = (user?['conditions'] as List?)?.cast<String>() ?? [];
    final primaryGoal = user?['primaryGoal'] as String? ?? '';
    final profileComplete = user?['profileComplete'] as bool? ?? false;

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Greeting based on time of day
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── M3 Large App Bar ──────────────────────────────────────────────
          SliverAppBar.large(
            backgroundColor: cs.surface,
            surfaceTintColor: cs.surfaceTint,
            automaticallyImplyLeading: false,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$greeting, $name 👋',
                    style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                Text('How are you feeling today?',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                tooltip: 'Notifications',
                onPressed: () => context.push(RouteNames.notificationsPage),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => context.push(RouteNames.settings),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: cs.primaryContainer,
                    child: Text(initial,
                        style: TextStyle(
                            color: cs.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                            fontSize: 14)),
                  ),
                ),
              ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: SliverList.list(children: [

              // ── Profile incomplete banner ────────────────────────────────
              if (!profileComplete) ...[
                _ProfileCompleteBanner(cs: cs, tt: tt),
                const SizedBox(height: 16),
              ],

              // ── Health profile card (real data, no hardcoded score) ──────
              _HealthProfileCard(bloodType: bloodType, conditions: conditions, primaryGoal: primaryGoal),
              const SizedBox(height: 24),

              // ── Quick actions ────────────────────────────────────────────
              Text('Quick Actions', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              const _QuickActions(),
              const SizedBox(height: 24),

              // ── Today's vitals — user-entered, no hardcoded numbers ──────
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text("Today's Vitals", style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                TextButton(
                  onPressed: () => context.push(RouteNames.healthTracking),
                  child: const Text('Log vitals'),
                ),
              ]),
              const SizedBox(height: 8),
              const _VitalsEmptyState(),
              const SizedBox(height: 24),

              // ── AI insight — goal-aware, no hardcoded text ───────────────
              _AIGoalBanner(goal: primaryGoal, cs: cs, tt: tt),
              const SizedBox(height: 24),

              // ── Upcoming appointment ─────────────────────────────────────
              Text('Next Appointment', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              const _UpcomingAppointment(),
            ]),
          ),
        ],
      ),
    );
  }
}

// ── Profile incomplete banner ─────────────────────────────────────────────────

class _ProfileCompleteBanner extends StatelessWidget {
  final ColorScheme cs;
  final TextTheme tt;
  const _ProfileCompleteBanner({required this.cs, required this.tt});

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: cs.tertiaryContainer,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        Icon(Icons.person_outline_rounded, color: cs.onTertiaryContainer),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Complete your health profile', style: tt.labelLarge?.copyWith(
                color: cs.onTertiaryContainer, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text('Add your blood type, conditions & goals for personalised AI insights.',
                style: tt.bodySmall?.copyWith(color: cs.onTertiaryContainer)),
          ],
        )),
        const SizedBox(width: 8),
        FilledButton.tonal(
          onPressed: () => context.push(RouteNames.profileSetup),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('Set up'),
        ),
      ]),
    ),
  );
}

// ── Health profile card (no hardcoded score) ──────────────────────────────────

class _HealthProfileCard extends StatelessWidget {
  final String bloodType;
  final List<String> conditions;
  final String primaryGoal;
  const _HealthProfileCard({this.bloodType = '', this.conditions = const [], this.primaryGoal = ''});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final hasData = bloodType.isNotEmpty || conditions.isNotEmpty || primaryGoal.isNotEmpty;

    return Card(
      elevation: 0,
      color: cs.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: hasData
            ? Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: cs.primary.withValues(alpha: 0.15),
              child: Icon(Icons.health_and_safety_rounded, color: cs.primary, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Health Profile',
                      style: tt.bodySmall?.copyWith(color: cs.onPrimaryContainer.withValues(alpha: 0.7))),
                  const SizedBox(height: 4),
                  Wrap(spacing: 8, runSpacing: 6, children: [
                    if (bloodType.isNotEmpty) _Pill(label: 'Blood: $bloodType', cs: cs),
                    if (primaryGoal.isNotEmpty) _Pill(label: primaryGoal, cs: cs),
                    if (conditions.isNotEmpty && conditions.first != 'None of the above')
                      _Pill(label: conditions.first, cs: cs),
                  ]),
                ],
              ),
            ),
          ],
        )
            : Row(children: [
          Icon(Icons.info_outline, color: cs.onPrimaryContainer.withValues(alpha: 0.6), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Complete your profile to unlock personalised AI insights.',
              style: tt.bodySmall?.copyWith(color: cs.onPrimaryContainer),
            ),
          ),
          TextButton(
            onPressed: () => context.push(RouteNames.profileSetup),
            child: const Text('Set up'),
          ),
        ]),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final ColorScheme cs;
  const _Pill({required this.label, required this.cs});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: cs.primary.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(label,
        style: TextStyle(color: cs.onPrimaryContainer, fontSize: 11, fontWeight: FontWeight.w600)),
  );
}

// ── Quick actions ─────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  static const _items = [
    (Icons.document_scanner_outlined, 'Scan Rx',  RouteNames.scanner),
    (Icons.upload_file_outlined,      'Reports',  RouteNames.reports),
    (Icons.video_call_outlined,       'Consult',  RouteNames.doctorList),
    (Icons.spa_outlined,              'Wellness', RouteNames.wellness),
  ];

  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Row(
      children: _items.map((item) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Card.outlined(
            child: InkWell(
              onTap: () => context.push(item.$3),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.$1, color: cs.primary, size: 22),
                    ),
                    const SizedBox(height: 8),
                    Text(item.$2,
                        textAlign: TextAlign.center,
                        style: tt.labelSmall?.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        ),
      )).toList(),
    );
  }
}

// ── Vitals empty state (no hardcoded numbers) ─────────────────────────────────

class _VitalsEmptyState extends StatelessWidget {
  const _VitalsEmptyState();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Card.outlined(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => context.push(RouteNames.healthTracking),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            CircleAvatar(
              backgroundColor: cs.surfaceContainerHighest,
              child: Icon(Icons.monitor_heart_outlined, color: cs.onSurfaceVariant),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('No vitals logged today', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                Text('Tap to log water, sleep, heart rate & more',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
              ]),
            ),
            Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
          ]),
        ),
      ),
    );
  }
}

// ── AI goal banner (goal-aware, not hardcoded) ────────────────────────────────

class _AIGoalBanner extends StatelessWidget {
  final String goal;
  final ColorScheme cs;
  final TextTheme tt;
  const _AIGoalBanner({required this.goal, required this.cs, required this.tt});

  String get _insight {
    if (goal.isEmpty) return 'Complete your health profile to get personalised AI insights tailored to your goals.';
    if (goal.contains('sleep')) return 'To improve sleep quality, try a consistent bedtime routine and avoid screens 30 min before bed.';
    if (goal.contains('weight') || goal.contains('fitness')) return 'Combining 30 min of daily walking with a balanced diet is the most effective first step toward your goal.';
    if (goal.contains('stress')) return 'Even 5 minutes of deep breathing reduces cortisol. Try it before your next stressful meeting.';
    if (goal.contains('condition') || goal.contains('chronic')) return 'Consistent tracking is key for managing chronic conditions. Logging vitals daily helps your doctor too.';
    return 'Based on your goal "$goal" — tap to chat with MediNova AI for personalised advice.';
  }

  @override
  Widget build(BuildContext context) => Card(
    color: cs.secondaryContainer,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: InkWell(
      onTap: () => context.push(RouteNames.chatbot),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          CircleAvatar(
            backgroundColor: cs.secondary,
            child: Icon(Icons.psychology_rounded, color: cs.onSecondary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AI Insight', style: tt.labelLarge?.copyWith(
                  color: cs.onSecondaryContainer, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(_insight, style: tt.bodySmall?.copyWith(color: cs.onSecondaryContainer, height: 1.5)),
            ],
          )),
          Icon(Icons.chevron_right, color: cs.onSecondaryContainer),
        ]),
      ),
    ),
  );
}

// ── Upcoming appointment ──────────────────────────────────────────────────────

class _UpcomingAppointment extends ConsumerWidget {
  const _UpcomingAppointment();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appts = ref.watch(upcomingAppointmentsProvider);

    return appts.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => _NoAppointmentCard(),
      data: (list) => list.isEmpty ? _NoAppointmentCard() : _AppointmentTile(appt: list.first),
    );
  }
}

class _NoAppointmentCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Card.outlined(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => context.push(RouteNames.doctorList),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: cs.surfaceContainerHighest,
              child: Icon(Icons.calendar_month_outlined, color: cs.onSurfaceVariant),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('No upcoming appointments', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                Text('Tap to find a doctor and book a consultation',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
              ],
            )),
            Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
          ]),
        ),
      ),
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  final Map<String, dynamic> appt;
  const _AppointmentTile({required this.appt});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return WiseCard(
      onTap: () => context.push(RouteNames.appointments),
      child: Row(children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: cs.primaryContainer,
          child: Icon(Icons.calendar_month_outlined, color: cs.primary),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(appt['doctorName'] as String? ?? 'Doctor',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            Text('${appt['specialty'] ?? ''} · ${appt['scheduledAt'] ?? ''}',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
          ],
        )),
        WiseBadge(
            label: appt['status'] as String? ?? 'Pending',
            type: (appt['status'] as String? ?? '') == 'confirmed'
                ? WiseBadgeType.success : WiseBadgeType.warning),
      ]),
    );
  }
}
