import '../../shared/widgets/wise/wise_card.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';


class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<_Notif> _notifs = [
    _Notif('Medicine Reminder', 'Time to take Metformin 500mg', '2 min ago', Icons.medication_rounded, kWarningOrange, false),
    _Notif('Appointment Tomorrow', 'Dr. Sarah Johnson at 10:00 AM', '1 hour ago', Icons.calendar_today_rounded, kPrimaryText, false),
    _Notif('Lab Results Ready', 'Your blood test results are available', '3 hours ago', Icons.science_rounded, kSuccessGreen, true),
    _Notif('Health Tip', 'Drink 8 glasses of water daily for optimal health', '5 hours ago', Icons.lightbulb_rounded, kPrimaryText, true),
    _Notif('Emergency Alert', 'Emergency SOS was activated by Robert Johnson', '1 day ago', Icons.emergency_rounded, kErrorRed, true),
    _Notif('Prescription Scanned', 'AI analysis complete for your prescription', '2 days ago', Icons.document_scanner_rounded, kSuccessGreen, true),
  ];

  @override
  Widget build(BuildContext context) {
    final unread = _notifs.where((n) => !n.read).length;
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: kBackground,
        foregroundColor: kPrimaryText,
        actions: [
          TextButton(
            onPressed: () => setState(() { for (final n in _notifs) n.read = true; }),
            child: const Text('Mark all read', style: TextStyle(color: kSecondaryText, fontSize: 13)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (unread > 0) ...[
            Text('$unread unread', style: const TextStyle(color: kSecondaryText, fontSize: 13)),
            const SizedBox(height: 12),
          ],
          ..._notifs.map((n) => _NotifCard(
            notif: n,
            onTap: () => setState(() => n.read = true),
          )),
        ],
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final _Notif notif;
  final VoidCallback onTap;
  const _NotifCard({required this.notif, required this.onTap});

  @override
  Widget build(BuildContext context) => WiseCard(
    margin: const EdgeInsets.only(bottom: 10),
    padding: EdgeInsets.zero,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: notif.read ? Colors.transparent : kElevated,
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: notif.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(notif.icon, color: notif.color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(notif.title,
                  style: TextStyle(color: kPrimaryText, fontSize: 14,
                      fontWeight: notif.read ? FontWeight.w500 : FontWeight.w700))),
              if (!notif.read)
                Container(width: 8, height: 8,
                    decoration: const BoxDecoration(color: kPrimaryText, shape: BoxShape.circle)),
            ]),
            const SizedBox(height: 4),
            Text(notif.body, style: const TextStyle(color: kSecondaryText, fontSize: 12)),
            const SizedBox(height: 6),
            Text(notif.time, style: const TextStyle(color: kTertiaryText, fontSize: 11)),
          ])),
        ]),
      ),
    ),
  );
}

class _Notif {
  final String title, body, time;
  final IconData icon;
  final Color color;
  bool read;
  _Notif(this.title, this.body, this.time, this.icon, this.color, this.read);
}
