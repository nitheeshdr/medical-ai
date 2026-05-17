import '../../shared/widgets/wise/wise_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../routes/route_names.dart';


class DoctorProfileScreen extends StatelessWidget {
  final String doctorId;
  const DoctorProfileScreen({super.key, required this.doctorId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200, pinned: true,
            backgroundColor: kBackground, foregroundColor: kPrimaryText,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: kElevated,
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const SizedBox(height: 60),
                  CircleAvatar(backgroundColor: kBorder, radius: 40, child: Text(doctorId[4].toUpperCase(), style: const TextStyle(color: kPrimaryText, fontSize: 32, fontWeight: FontWeight.w700))),
                  const SizedBox(height: 12),
                  Text(doctorId, style: const TextStyle(color: kPrimaryText, fontSize: 18, fontWeight: FontWeight.w700)),
                  const Text('Cardiologist • 12 years experience', style: TextStyle(color: kSecondaryText, fontSize: 13)),
                ]),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(children: [
                  _StatChip('4.9', Icons.star_rounded, const Color(0xFFF59E0B)),
                  const SizedBox(width: 12),
                  _StatChip('1.2K', Icons.people_rounded, kPrimaryText),
                  const SizedBox(width: 12),
                  _StatChip('12yr', Icons.work_rounded, kPrimaryText),
                ]),
                const SizedBox(height: 20),
                WiseCard(padding: const EdgeInsets.all(16), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('About', style: TextStyle(color: kPrimaryText, fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Text('Specialist in interventional cardiology with expertise in heart failure, arrhythmia, and preventive cardiology. Completed fellowship at Johns Hopkins.', style: TextStyle(color: kSecondaryText, fontSize: 14, height: 1.6)),
                ])),
                const SizedBox(height: 16),
                const Text('Available Slots', style: TextStyle(color: kPrimaryText, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8, children: ['9:00 AM', '10:30 AM', '2:00 PM', '3:30 PM', '5:00 PM']
                    .map((t) => _TimeSlot(time: t)).toList()),
                const SizedBox(height: 24),
                SizedBox(width: double.infinity, child: FilledButton(
                  onPressed: () => context.push(RouteNames.bookAppointment, extra: doctorId),
                  style: FilledButton.styleFrom(backgroundColor: kPrimaryText, foregroundColor: kBlack, padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text('Book Appointment', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                )),
                const SizedBox(height: 12),
                SizedBox(width: double.infinity, child: OutlinedButton.icon(
                  onPressed: () => context.push(RouteNames.telemedicine, extra: doctorId),
                  icon: const Icon(Icons.video_call_rounded),
                  label: const Text('Video Consultation'),
                  style: OutlinedButton.styleFrom(foregroundColor: kPrimaryText, side: const BorderSide(color: kBorder), padding: const EdgeInsets.symmetric(vertical: 16)),
                )),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String value;
  final IconData icon;
  final Color color;
  const _StatChip(this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(color: kElevated, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
    child: Row(children: [
      Icon(icon, color: color, size: 16),
      const SizedBox(width: 6),
      Text(value, style: const TextStyle(color: kPrimaryText, fontWeight: FontWeight.w600)),
    ]),
  );
}

class _TimeSlot extends StatefulWidget {
  final String time;
  const _TimeSlot({required this.time});

  @override
  State<_TimeSlot> createState() => _TimeSlotState();
}

class _TimeSlotState extends State<_TimeSlot> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => setState(() => _selected = !_selected),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _selected ? kPrimaryText : kElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _selected ? kPrimaryText : kBorder),
      ),
      child: Text(widget.time, style: TextStyle(color: _selected ? kBlack : kSecondaryText, fontWeight: FontWeight.w500, fontSize: 13)),
    ),
  );
}
