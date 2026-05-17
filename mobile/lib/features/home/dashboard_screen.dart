import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../routes/route_names.dart';
import '../../shared/widgets/wise/wise_badge.dart';
import '../../shared/widgets/wise/wise_card.dart';
import '../../shared/widgets/wise/wise_stat_card.dart';
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

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── M3 Large App Bar ───────────────────────────────────────────────
          SliverAppBar.large(
            backgroundColor: cs.surface,
            surfaceTintColor: cs.surfaceTint,
            automaticallyImplyLeading: false,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Good morning, $name 👋',
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

              // ── Health score hero ─────────────────────────────────────────
              _HealthHeroCard(bloodType: bloodType, conditions: conditions),
              const SizedBox(height: 24),

              // ── Quick actions ─────────────────────────────────────────────
              Text('Quick Actions', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _QuickActions(),
              const SizedBox(height: 24),

              // ── Today's metrics ───────────────────────────────────────────
              Text("Today's Metrics", style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: const [
                  WiseStatCard(label: 'Heart Rate',  value: '72 bpm',  icon: Icons.favorite_rounded,        accentColor: kErrorRed,     change: -2.1),
                  WiseStatCard(label: 'Steps Today', value: '6,240',   icon: Icons.directions_walk_rounded, accentColor: kSuccessGreen, change: 8.4),
                  WiseStatCard(label: 'Water Intake',value: '6 / 8',   icon: Icons.water_drop_outlined,     accentColor: kAccent,       change: null),
                  WiseStatCard(label: 'Sleep',       value: '7.5 hrs', icon: Icons.bedtime_outlined,        accentColor: Color(0xFF8B5CF6), change: 4.2),
                ],
              ),
              const SizedBox(height: 24),

              // ── AI Insight banner ─────────────────────────────────────────
              _AIInsightBanner(),
              const SizedBox(height: 24),

              // ── Recent Activity ───────────────────────────────────────────
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Recent Activity', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                TextButton(onPressed: () {}, child: const Text('See all')),
              ]),
              const SizedBox(height: 8),
              _RecentActivity(),
              const SizedBox(height: 24),

              // ── Upcoming appointment ──────────────────────────────────────
              Text('Next Appointment', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _UpcomingAppointment(),
            ]),
          ),
        ],
      ),
    );
  }
}

// ── Health hero card ──────────────────────────────────────────────────────────

class _HealthHeroCard extends StatelessWidget {
  final String bloodType;
  final List<String> conditions;
  const _HealthHeroCard({this.bloodType = '', this.conditions = const []});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: cs.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Score ring
            SizedBox(
              width: 80, height: 80,
              child: Stack(alignment: Alignment.center, children: [
                CircularProgressIndicator(
                  value: 0.82,
                  strokeWidth: 8,
                  backgroundColor: cs.primary.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation(cs.primary),
                ),
                Text('82', style: tt.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800, color: cs.onPrimaryContainer)),
              ]),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Health Score', style: tt.bodySmall?.copyWith(color: cs.onPrimaryContainer.withValues(alpha: 0.7))),
                  Text('82 / 100', style: tt.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800, color: cs.onPrimaryContainer)),
                  const SizedBox(height: 4),
                  Text('Excellent — keep it up!', style: tt.bodySmall?.copyWith(
                      color: cs.onPrimaryContainer.withValues(alpha: 0.8))),
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, children: [
                    _Pill(label: '↑ 3% this week', cs: cs),
                    if (bloodType.isNotEmpty) _Pill(label: bloodType, cs: cs),
                    if (conditions.isNotEmpty && conditions.first != 'None')
                      _Pill(label: conditions.first, cs: cs),
                  ]),
                ],
              ),
            ),
          ],
        ),
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
    (Icons.document_scanner_outlined, 'Scan Rx',   RouteNames.scanner),
    (Icons.upload_file_outlined,       'Reports',   RouteNames.reports),
    (Icons.video_call_outlined,        'Consult',   RouteNames.doctorList),
    (Icons.spa_outlined,               'Wellness',  RouteNames.wellness),
  ];

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

// ── AI Insight banner ─────────────────────────────────────────────────────────

class _AIInsightBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Card(
      color: cs.secondaryContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              Text('Your sleep improved 4.2% this week. Reduce caffeine after 3 PM.',
                  style: tt.bodySmall?.copyWith(color: cs.onSecondaryContainer)),
            ],
          )),
          Icon(Icons.chevron_right, color: cs.onSecondaryContainer),
        ]),
      ),
    );
  }
}

// ── Recent activity ───────────────────────────────────────────────────────────

class _RecentActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.analytics_outlined,      'Blood Report Analyzed', 'AI found 2 highlights', '2h ago',   WiseBadgeType.info),
      (Icons.medication_outlined,     'Metformin Taken',       'With breakfast',         '8:00 AM',  WiseBadgeType.success),
      (Icons.calendar_month_outlined, 'Dr. Sarah Johnson',     'Tomorrow 3:00 PM',       'Tomorrow', WiseBadgeType.warning),
    ];

    return WiseCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: items.asMap().entries.map((e) {
          final item  = e.value;
          final isLast = e.key == items.length - 1;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Icon(item.$1, size: 20),
                ),
                title: Text(item.$2, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text(item.$3),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(item.$4, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 4),
                    WiseBadge(label: item.$4 == '2h ago' ? 'New' : item.$4 == 'Tomorrow' ? 'Soon' : 'Done',
                        type: item.$5),
                  ],
                ),
              ),
              if (!isLast) const Divider(height: 0, indent: 70),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ── Upcoming appointment ──────────────────────────────────────────────────────

class _UpcomingAppointment extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appts = ref.watch(upcomingAppointmentsProvider);

    return appts.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => _StaticAppointmentCard(),
      data: (list) => list.isEmpty
          ? _StaticAppointmentCard()
          : _AppointmentTile(appt: list.first),
    );
  }
}

class _StaticAppointmentCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WiseCard(
      onTap: () => context.push(RouteNames.appointments),
      child: Row(children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(Icons.calendar_month_outlined,
              color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dr. Sarah Johnson',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            Text('General Physician · Tomorrow 3:00 PM',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
          ],
        )),
        WiseBadge(label: 'Confirmed', type: WiseBadgeType.success),
      ]),
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
            Text(appt['specialty'] as String? ?? '',
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
