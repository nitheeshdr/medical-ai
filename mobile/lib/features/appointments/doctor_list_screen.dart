import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/doctors_provider.dart';
import '../../routes/route_names.dart';
import '../../shared/widgets/wise/wise_badge.dart';
import '../../shared/widgets/wise/wise_card.dart';

class DoctorListScreen extends ConsumerStatefulWidget {
  const DoctorListScreen({super.key});

  @override
  ConsumerState<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends ConsumerState<DoctorListScreen> {
  String _specialty = 'All';
  String _search = '';

  static const _specialties = ['All', 'Cardiology', 'Neurology', 'General Physician', 'Pediatrics', 'Dermatology', 'Orthopedic'];

  @override
  Widget build(BuildContext context) {
    final doctorsAsync = ref.watch(doctorsProvider(_specialty));

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: kShadowMd,
        surfaceTintColor: Colors.transparent,
        leading: const BackButton(color: kAccent),
        title: const Text('Find a Doctor',
            style: TextStyle(color: kPrimaryText, fontSize: 17, fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kBorder),
                boxShadow: const [BoxShadow(color: kShadowColor, blurRadius: 6, offset: Offset(0, 2))],
              ),
              child: TextField(
                onChanged: (v) => setState(() => _search = v.toLowerCase()),
                style: const TextStyle(color: kPrimaryText, fontSize: 15),
                decoration: const InputDecoration(
                  hintText: 'Search by name or specialty...',
                  hintStyle: TextStyle(color: kTertiaryText, fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded, color: kSecondaryText, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // Specialty filter
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: _specialties.length,
              itemBuilder: (_, i) {
                final s = _specialties[i];
                final selected = _specialty == s;
                return GestureDetector(
                  onTap: () => setState(() => _specialty = s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? kAccent : kSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selected ? kAccent : kBorder),
                      boxShadow: selected
                          ? [BoxShadow(color: kAccent.withValues(alpha: 0.25), blurRadius: 8)]
                          : null,
                    ),
                    child: Text(s,
                        style: TextStyle(
                          color: selected ? Colors.white : kSecondaryText,
                          fontSize: 13,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        )),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // List
          Expanded(
            child: doctorsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: kAccent)),
              error: (e, _) => Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.wifi_off_rounded, size: 48, color: kTertiaryText),
                  const SizedBox(height: 12),
                  const Text('Could not load doctors', style: TextStyle(color: kSecondaryText)),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => ref.invalidate(doctorsProvider),
                    child: const Text('Retry', style: TextStyle(color: kAccent)),
                  ),
                ]),
              ),
              data: (doctors) {
                final filtered = _search.isEmpty
                    ? doctors
                    : doctors.where((d) =>
                        d.name.toLowerCase().contains(_search) ||
                        d.specialty.toLowerCase().contains(_search)).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.search_off_rounded, size: 48, color: kTertiaryText),
                      SizedBox(height: 12),
                      Text('No doctors found', style: TextStyle(color: kSecondaryText)),
                    ]),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _DoctorCard(doctor: filtered[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final Doctor doctor;
  const _DoctorCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return WiseCard(
      onTap: () => context.push(RouteNames.doctorProfile, extra: doctor.id),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(gradient: kBrandGradient, borderRadius: BorderRadius.circular(14)),
            child: Center(
              child: Text(doctor.initials,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(doctor.name,
                    style: const TextStyle(color: kPrimaryText, fontSize: 14, fontWeight: FontWeight.w700)),
                Text(doctor.specialty,
                    style: const TextStyle(color: kSecondaryText, fontSize: 12)),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.star_rounded, color: kWarningOrange, size: 13),
                  const SizedBox(width: 3),
                  Text(doctor.rating.toStringAsFixed(1),
                      style: const TextStyle(color: kPrimaryText, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  Text(doctor.experience, style: const TextStyle(color: kTertiaryText, fontSize: 12)),
                  const SizedBox(width: 8),
                  WiseBadge(
                    label: doctor.available ? 'Available' : 'Busy',
                    type: doctor.available ? WiseBadgeType.success : WiseBadgeType.warning,
                  ),
                ]),
              ],
            ),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(doctor.fee,
                style: const TextStyle(color: kPrimaryText, fontSize: 15, fontWeight: FontWeight.w800)),
            const Text('/session', style: TextStyle(color: kTertiaryText, fontSize: 10)),
          ]),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, color: kTertiaryText, size: 18),
        ],
      ),
    );
  }
}
