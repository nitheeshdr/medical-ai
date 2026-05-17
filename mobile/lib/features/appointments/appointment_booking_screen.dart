import '../../shared/widgets/wise/wise_input.dart';
import '../../shared/widgets/wise/wise_button.dart';
import '../../shared/widgets/wise/wise_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../routes/route_names.dart';




class AppointmentBookingScreen extends StatefulWidget {
  final String doctorId;
  const AppointmentBookingScreen({super.key, required this.doctorId});

  @override
  State<AppointmentBookingScreen> createState() => _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  String _type = 'In-Person';
  String? _selectedDate;
  String? _selectedTime;
  final _reasonCtrl = TextEditingController();

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(title: const Text('Book Appointment'), backgroundColor: kBackground, foregroundColor: kPrimaryText),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Consultation Type', style: TextStyle(color: kPrimaryText, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(children: ['In-Person', 'Video Call'].map((t) => Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _type = t),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(right: t == 'In-Person' ? 8 : 0),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _type == t ? kPrimaryText : kElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _type == t ? kPrimaryText : kBorder),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(t == 'In-Person' ? Icons.local_hospital_rounded : Icons.video_call_rounded,
                      color: _type == t ? kBlack : kSecondaryText, size: 18),
                  const SizedBox(width: 8),
                  Text(t, style: TextStyle(color: _type == t ? kBlack : kSecondaryText, fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
          )).toList()),
          const SizedBox(height: 24),
          const Text('Select Date', style: TextStyle(color: kPrimaryText, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              itemBuilder: (_, i) {
                final date = DateTime.now().add(Duration(days: i));
                final label = '${date.day}';
                final dayLabel = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][date.weekday % 7];
                final isSelected = _selectedDate == label;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDate = label),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 56, margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? kPrimaryText : kElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? kPrimaryText : kBorder),
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(dayLabel, style: TextStyle(color: isSelected ? kBlack : kSecondaryText, fontSize: 11)),
                      Text(label, style: TextStyle(color: isSelected ? kBlack : kPrimaryText, fontSize: 18, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          const Text('Select Time', style: TextStyle(color: kPrimaryText, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: ['9:00 AM', '10:30 AM', '2:00 PM', '3:30 PM', '5:00 PM'].map((t) {
            final isSelected = _selectedTime == t;
            return GestureDetector(
              onTap: () => setState(() => _selectedTime = t),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? kPrimaryText : kElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isSelected ? kPrimaryText : kBorder),
                ),
                child: Text(t, style: TextStyle(color: isSelected ? kBlack : kSecondaryText, fontWeight: FontWeight.w500)),
              ),
            );
          }).toList()),
          const SizedBox(height: 20),
          WiseInput(controller: _reasonCtrl, hint: 'Reason for visit (optional)', label: 'Reason', maxLines: 3),
          const SizedBox(height: 24),
          WiseCard(padding: const EdgeInsets.all(16), child: Column(children: [
            _row('Doctor', widget.doctorId),
            const Divider(color: kBorder, height: 16),
            _row('Type', _type),
            const Divider(color: kBorder, height: 16),
            _row('Consultation Fee', '\$120'),
          ])),
          const SizedBox(height: 24),
          WiseButton(label: 'Confirm Booking', onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appointment booked successfully!'), backgroundColor: kSuccessGreen));
            context.go(RouteNames.appointments);
          }),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(label, style: const TextStyle(color: kSecondaryText, fontSize: 14)),
    Text(value, style: const TextStyle(color: kPrimaryText, fontSize: 14, fontWeight: FontWeight.w500)),
  ]);
}
