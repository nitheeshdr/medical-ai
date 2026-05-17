import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../../routes/route_names.dart';

const _storage = FlutterSecureStorage();

class EmergencyScreen extends ConsumerStatefulWidget {
  const EmergencyScreen({super.key});

  @override
  ConsumerState<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends ConsumerState<EmergencyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  bool _sosActivated = false;
  Map<String, dynamic>? _emergencyContact;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
    _loadContact();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadContact() async {
    final raw = await _storage.read(key: AppConstants.userKey);
    if (raw != null) {
      final user = jsonDecode(raw) as Map<String, dynamic>;
      final ec = user['emergencyContact'] as Map<String, dynamic>?;
      if (mounted) setState(() => _emergencyContact = ec);
    }
  }

  Future<void> _call(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _activateSOS() {
    setState(() => _sosActivated = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _emergencyContact?['phone'] != null
              ? '🚨 Alert sent to ${_emergencyContact!['name']} & emergency services!'
              : '🚨 Emergency alert sent! Please set an emergency contact in your profile.',
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final hasContact = _emergencyContact != null &&
        (_emergencyContact!['name'] as String? ?? '').isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Emergency SOS')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // ── SOS button ──────────────────────────────────────────────────
          Center(
            child: GestureDetector(
              onLongPress: _activateSOS,
              child: AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, __) => Container(
                  width: 160, height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.error,
                    boxShadow: [
                      BoxShadow(
                        color: cs.error.withValues(alpha: _pulseCtrl.value * 0.5),
                        blurRadius: 40 * _pulseCtrl.value,
                        spreadRadius: 20 * _pulseCtrl.value,
                      ),
                    ],
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.emergency_rounded, color: cs.onError, size: 48),
                    const SizedBox(height: 4),
                    Text(
                      _sosActivated ? 'ACTIVATED' : 'SOS',
                      style: TextStyle(
                        color: cs.onError, fontSize: 20,
                        fontWeight: FontWeight.w800, letterSpacing: 2,
                      ),
                    ),
                    Text('Hold to activate',
                        style: TextStyle(color: cs.onError.withValues(alpha: 0.7), fontSize: 11)),
                  ]),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Activated confirmation ───────────────────────────────────────
          if (_sosActivated)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: cs.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                Icon(Icons.check_circle_rounded, color: cs.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Emergency services and your contact have been notified with your location.',
                    style: tt.bodySmall?.copyWith(color: cs.onErrorContainer),
                  ),
                ),
              ]),
            ),

          // ── No contact warning ───────────────────────────────────────────
          if (!hasContact) ...[
            Card(
              color: cs.tertiaryContainer,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  Icon(Icons.warning_amber_rounded, color: cs.onTertiaryContainer, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No emergency contact set. Add one in your health profile so we can alert them during SOS.',
                      style: tt.bodySmall?.copyWith(color: cs.onTertiaryContainer),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => Navigator.of(context)
                        .pushNamed(RouteNames.profileSetup),
                    child: const Text('Set up'),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // ── Emergency contacts ───────────────────────────────────────────
          Text('Emergency Contacts', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),

          // Always show 112 / 911
          _ContactCard(
            cs: cs, tt: tt,
            name: 'Emergency Services',
            subtitle: 'Ambulance, Police, Fire',
            number: '112',
            icon: Icons.local_hospital_rounded,
            onCall: () => _call('112'),
          ),
          const SizedBox(height: 10),

          if (hasContact)
            _ContactCard(
              cs: cs, tt: tt,
              name: _emergencyContact!['name'] as String,
              subtitle: _emergencyContact!['relation'] as String? ?? 'Emergency contact',
              number: _emergencyContact!['phone'] as String? ?? '',
              icon: Icons.person_rounded,
              onCall: () => _call(_emergencyContact!['phone'] as String? ?? ''),
            )
          else
            Card.outlined(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: cs.surfaceContainerHighest,
                  child: Icon(Icons.person_add_outlined, color: cs.onSurfaceVariant),
                ),
                title: Text('Add emergency contact',
                    style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                onTap: () => Navigator.of(context).pushNamed(RouteNames.profileSetup),
              ),
            ),

          const SizedBox(height: 24),

          // ── Nearby help ──────────────────────────────────────────────────
          Text('Nearby Help', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Card.outlined(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_searching_rounded, color: cs.onSurfaceVariant, size: 20),
                  const SizedBox(height: 8),
                  Text(
                    'Enable location to see nearby hospitals, clinics, and pharmacies.',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant, height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.map_outlined, size: 16),
                      label: const Text('Find Nearby Hospitals'),
                      onPressed: () async {
                        final uri = Uri.parse('https://maps.google.com/?q=hospital+near+me');
                        if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
                      },
                      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final ColorScheme cs;
  final TextTheme tt;
  final String name, subtitle, number;
  final IconData icon;
  final VoidCallback onCall;
  const _ContactCard({required this.cs, required this.tt, required this.name, required this.subtitle, required this.number, required this.icon, required this.onCall});

  @override
  Widget build(BuildContext context) => Card.outlined(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        CircleAvatar(
          backgroundColor: cs.primaryContainer,
          child: Icon(icon, color: cs.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          Text(subtitle, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          if (number.isNotEmpty) Text(number, style: tt.bodySmall?.copyWith(color: cs.primary, fontWeight: FontWeight.w500)),
        ])),
        IconButton(
          icon: Icon(Icons.call_rounded, color: cs.primary),
          onPressed: number.isNotEmpty ? onCall : null,
          tooltip: 'Call',
        ),
      ]),
    ),
  );
}
