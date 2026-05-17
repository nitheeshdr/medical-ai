import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/network/api_client.dart';
import '../../routes/route_names.dart';

// Provider to fetch family members from API
final familyProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final api = ref.read(apiClientProvider);
  try {
    final res = await api.get('/family');
    final list = (res.data as Map<String, dynamic>)['members'] as List? ?? [];
    return list.cast<Map<String, dynamic>>();
  } catch (_) {
    return [];
  }
});

class FamilyScreen extends ConsumerWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final membersAsync = ref.watch(familyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Healthcare'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(familyProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'family_fab',
        onPressed: () => context.push(RouteNames.addFamilyMember),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Member'),
      ),
      body: membersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _EmptyState(cs: cs, tt: tt),
        data: (members) => members.isEmpty
            ? _EmptyState(cs: cs, tt: tt)
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: members.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _MemberCard(member: members[i], cs: cs, tt: tt),
              ),
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final Map<String, dynamic> member;
  final ColorScheme cs;
  final TextTheme tt;
  const _MemberCard({required this.member, required this.cs, required this.tt});

  @override
  Widget build(BuildContext context) {
    final name = member['name'] as String? ?? 'Member';
    final relation = member['relation'] as String? ?? '';
    final dob = member['dob'] as String? ?? '';
    final bloodType = member['bloodType'] as String? ?? '';
    final conditions = (member['conditions'] as List?)?.cast<String>() ?? [];

    return Card.outlined(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: cs.primaryContainer,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                color: cs.onPrimaryContainer,
                fontSize: 18, fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(
              [if (relation.isNotEmpty) relation, if (dob.isNotEmpty) _age(dob)].join(' · '),
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            if (bloodType.isNotEmpty || conditions.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(spacing: 6, children: [
                if (bloodType.isNotEmpty)
                  _Tag(label: bloodType, cs: cs),
                if (conditions.isNotEmpty && conditions.first != 'None of the above')
                  _Tag(label: conditions.first, cs: cs),
              ]),
            ],
          ])),
          Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
        ]),
      ),
    );
  }

  String _age(String dob) {
    try {
      final birth = DateTime.parse(dob);
      final age = DateTime.now().difference(birth).inDays ~/ 365;
      return '$age yrs';
    } catch (_) {
      return '';
    }
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final ColorScheme cs;
  const _Tag({required this.label, required this.cs});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(label, style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
  );
}

class _EmptyState extends StatelessWidget {
  final ColorScheme cs;
  final TextTheme tt;
  const _EmptyState({required this.cs, required this.tt});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: cs.surfaceContainerHighest,
          child: Icon(Icons.family_restroom_rounded, size: 36, color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        Text('No family members yet', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(
          'Add family members to manage their health, track medications, and book appointments on their behalf.',
          textAlign: TextAlign.center,
          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant, height: 1.5),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          icon: const Icon(Icons.person_add_rounded),
          label: const Text('Add First Member'),
          onPressed: () => context.push(RouteNames.addFamilyMember),
          style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        ),
      ]),
    ),
  );
}
