import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/network/api_client.dart';
import '../../routes/route_names.dart';
import '../../shared/widgets/wise/wise_badge.dart';
import '../../shared/widgets/wise/wise_card.dart';

// ── Provider ──────────────────────────────────────────────────────────────────

final appointmentsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    final api = ref.read(apiClientProvider);
    final res = await api.get('/appointments');
    final body = res.data as Map<String, dynamic>;
    final list = (body['appointments'] ?? body['data'] ?? []) as List<dynamic>;
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  } catch (_) {
    return [];
  }
});

final upcomingAppointmentsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final all = await ref.watch(appointmentsProvider.future);
  return all
      .where((a) =>
          (a['status'] as String? ?? '').toLowerCase() != 'completed' &&
          (a['status'] as String? ?? '').toLowerCase() != 'cancelled')
      .toList();
});

// ── Screen ────────────────────────────────────────────────────────────────────

class AppointmentListScreen extends ConsumerWidget {
  const AppointmentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appointments')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => context.push(RouteNames.doctorList),
        icon: const Icon(Icons.add),
        label: const Text('Book'),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [Tab(text: 'Upcoming'), Tab(text: 'Past')],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _AppointmentTab(upcoming: true),
                  _AppointmentTab(upcoming: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentTab extends ConsumerWidget {
  final bool upcoming;
  const _AppointmentTab({required this.upcoming});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appts = ref.watch(appointmentsProvider);
    return appts.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _FallbackList(upcoming: upcoming),
      data: (list) {
        final filtered = list.where((a) {
          final status = (a['status'] as String? ?? '').toLowerCase();
          return upcoming
              ? status != 'completed' && status != 'cancelled'
              : status == 'completed' || status == 'cancelled';
        }).toList();

        if (filtered.isEmpty) return _FallbackList(upcoming: upcoming);

        return RefreshIndicator(
          onRefresh: () => ref.refresh(appointmentsProvider.future),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _AppointmentCard(appt: filtered[i]),
          ),
        );
      },
    );
  }
}

// ── Static fallback list ──────────────────────────────────────────────────────

class _FallbackList extends StatelessWidget {
  final bool upcoming;
  const _FallbackList({required this.upcoming});

  @override
  Widget build(BuildContext context) {
    final items = upcoming
        ? [
            {'doctorName': 'Dr. Sarah Johnson', 'specialty': 'Cardiologist',     'date': 'Tomorrow, May 17', 'time': '3:00 PM',  'type': 'Video',     'status': 'confirmed'},
            {'doctorName': 'Dr. Priya Sharma',  'specialty': 'General Physician','date': 'May 20, 2026',     'time': '10:30 AM', 'type': 'In-Person', 'status': 'pending'},
          ]
        : [
            {'doctorName': 'Dr. Michael Chen',  'specialty': 'Neurologist',  'date': 'May 5, 2026',  'time': '2:00 PM', 'type': 'Video',     'status': 'completed'},
            {'doctorName': 'Dr. James Wilson',  'specialty': 'Dermatologist','date': 'Apr 28, 2026', 'time': '4:00 PM', 'type': 'In-Person', 'status': 'completed'},
          ];
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _AppointmentCard(appt: items[i]),
    );
  }
}

// ── Single appointment card ───────────────────────────────────────────────────

class _AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appt;
  const _AppointmentCard({required this.appt});

  WiseBadgeType _badgeType(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed': return WiseBadgeType.success;
      case 'pending':   return WiseBadgeType.warning;
      case 'cancelled': return WiseBadgeType.error;
      default:          return WiseBadgeType.neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final tt      = Theme.of(context).textTheme;
    final status  = appt['status'] as String? ?? 'pending';
    final type    = appt['type'] as String? ?? appt['appointmentType'] as String? ?? 'Video';
    final date    = appt['date'] as String? ?? appt['scheduledAt'] as String? ?? '';
    final time    = appt['time'] as String? ?? '';
    final doctor  = appt['doctorName'] as String? ?? appt['doctorId'] as String? ?? 'Doctor';
    final spec    = appt['specialty'] as String? ?? appt['specialization'] as String? ?? '';

    return WiseCard(
      onTap: () {},
      child: Row(children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: cs.primaryContainer,
          child: Icon(
            type.toLowerCase().contains('video')
                ? Icons.video_call_rounded
                : Icons.local_hospital_outlined,
            color: cs.primary,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(doctor, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            Text(spec, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.schedule, size: 13, color: cs.onSurfaceVariant),
              const SizedBox(width: 4),
              Text('$date${time.isNotEmpty ? ' · $time' : ''}',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            ]),
          ],
        )),
        Column(
          children: [
            WiseBadge(label: status[0].toUpperCase() + status.substring(1), type: _badgeType(status)),
            const SizedBox(height: 6),
            Chip(
              label: Text(type, style: tt.labelSmall),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ]),
    );
  }
}
