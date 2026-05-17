import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../routes/route_names.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notifications = true;
  bool _biometrics = true;
  bool _signingOut = false;

  Future<void> _signOut() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.logout_rounded, size: 36, color: Theme.of(ctx).colorScheme.error),
        title: const Text('Sign out?'),
        content: const Text('You will need to sign in again to access your health data.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _signingOut = true);
    await ref.read(authControllerProvider.notifier).signOut();
    if (mounted) context.go(RouteNames.login);
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));

  @override
  Widget build(BuildContext context) {
    final user    = ref.watch(currentUserProvider);
    final name    = user?['name'] as String? ?? 'User';
    final email   = user?['email'] as String? ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Profile hero
          Card.filled(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: cs.primaryContainer,
                  child: Text(initial, style: TextStyle(
                    color: cs.onPrimaryContainer, fontSize: 22, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  if (email.isNotEmpty)
                    Text(email, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                ])),
                FilledButton.tonal(
                  onPressed: () => context.push(RouteNames.profileSetup),
                  child: const Text('Edit'),
                ),
              ]),
            ),
          ),

          // Account
          _SettingsSection(title: 'Account', tiles: [
            _SettingsTile(icon: Icons.medical_information_outlined, color: const Color(0xFF8B5CF6),
              title: 'Medical Profile', subtitle: 'Blood type, allergies, conditions',
              onTap: () => context.push(RouteNames.profileSetup)),
            _SettingsTile(icon: Icons.credit_card_rounded, color: const Color(0xFF10B981),
              title: 'Subscription & Billing', subtitle: 'Manage your plan',
              onTap: () => context.push(RouteNames.subscription)),
            _SwitchSettingsTile(icon: Icons.notifications_outlined, color: cs.primary,
              title: 'Push Notifications', subtitle: 'Reminders & appointment alerts',
              value: _notifications, onChanged: (v) => setState(() => _notifications = v)),
          ]),

          // Privacy & Security
          _SettingsSection(title: 'Privacy & Security', tiles: [
            _SettingsTile(icon: Icons.security_rounded, color: cs.error,
              title: 'Security Settings', subtitle: '2FA, password, active sessions',
              onTap: () => context.push(RouteNames.security)),
            _SwitchSettingsTile(icon: Icons.fingerprint_rounded, color: const Color(0xFFF59E0B),
              title: 'Biometric Auth', subtitle: 'Face ID / Touch ID',
              value: _biometrics, onChanged: (v) => setState(() => _biometrics = v)),
            _SettingsTile(icon: Icons.devices_rounded, color: cs.primary,
              title: 'Connected Devices', subtitle: 'Manage active sessions',
              onTap: () => context.push(RouteNames.deviceManagement)),
          ]),

          // Health
          _SettingsSection(title: 'Health Features', tiles: [
            _SettingsTile(icon: Icons.document_scanner_outlined, color: cs.primary,
              title: 'Prescription Scanner', onTap: () => context.push(RouteNames.scanner)),
            _SettingsTile(icon: Icons.analytics_outlined, color: const Color(0xFF10B981),
              title: 'Health Reports', subtitle: 'Upload & analyze',
              onTap: () => context.push(RouteNames.reports)),
            _SettingsTile(icon: Icons.monitor_heart_outlined, color: cs.error,
              title: 'Health Tracking', onTap: () => context.push(RouteNames.healthTracking)),
            _SettingsTile(icon: Icons.family_restroom_rounded, color: const Color(0xFF8B5CF6),
              title: 'Family Health', onTap: () => context.push(RouteNames.family)),
            _SettingsTile(icon: Icons.spa_outlined, color: const Color(0xFF10B981),
              title: 'Wellness', onTap: () => context.push(RouteNames.wellness)),
            _SettingsTile(icon: Icons.book_outlined, color: const Color(0xFF8B5CF6),
              title: 'Health Journal', onTap: () => context.push(RouteNames.journal)),
            _SettingsTile(icon: Icons.watch_rounded, color: cs.primary,
              title: 'Wearable Devices', onTap: () => context.push(RouteNames.wearable)),
            _SettingsTile(icon: Icons.folder_zip_outlined, color: cs.primary,
              title: 'Document Wallet', onTap: () => context.push(RouteNames.documentWallet)),
          ]),

          // App
          _SettingsSection(title: 'App', tiles: [
            _SettingsTile(icon: Icons.language_rounded, color: cs.onSurfaceVariant,
              title: 'Language', subtitle: 'English', onTap: () => _snack('Coming soon!')),
            _SettingsTile(icon: Icons.storage_rounded, color: cs.onSurfaceVariant,
              title: 'Data & Storage', subtitle: 'Clear cache',
              onTap: () => showDialog(context: context, builder: (_) => AlertDialog(
                title: const Text('Clear Cache'),
                content: const Text('Remove cached data? Your health data stays safe.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  FilledButton(onPressed: () { Navigator.pop(context); _snack('Cache cleared'); },
                    child: const Text('Clear')),
                ],
              ))),
          ]),

          // Support
          _SettingsSection(title: 'Support', tiles: [
            _SettingsTile(icon: Icons.help_outline_rounded, color: cs.primary,
              title: 'Help Center', onTap: () => _snack('Coming soon!')),
            _SettingsTile(icon: Icons.star_outline_rounded, color: const Color(0xFFF59E0B),
              title: 'Rate MediNova', onTap: () => _snack('Coming soon!')),
            _SettingsTile(icon: Icons.info_outline_rounded, color: cs.onSurfaceVariant,
              title: 'About MediNova', subtitle: 'v1.0.0',
              onTap: () => showAboutDialog(
                context: context,
                applicationName: 'MediNova AI',
                applicationVersion: 'v1.0.0',
                applicationIcon: const FlutterLogo(size: 48),
                children: const [Text('AI-powered personal health companion.\nPowered by NVIDIA NIM & Llama 3.1.')],
              )),
          ]),

          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity, height: 52,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: cs.errorContainer,
                  foregroundColor: cs.onErrorContainer,
                ),
                onPressed: _signingOut ? null : _signOut,
                icon: _signingOut
                    ? SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: cs.onErrorContainer))
                    : const Icon(Icons.logout_rounded),
                label: Text(_signingOut ? 'Signing out…' : 'Sign Out'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('MediNova AI · v1.0.0', textAlign: TextAlign.center,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Section ────────────────────────────────────────────────────────────────────
class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> tiles;
  const _SettingsSection({required this.title, required this.tiles});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(title, style: tt.labelMedium?.copyWith(
            color: cs.primary, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
      ),
      Card.outlined(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: tiles.asMap().entries.map((e) {
            final isLast = e.key == tiles.length - 1;
            return Column(mainAxisSize: MainAxisSize.min, children: [
              e.value,
              if (!isLast) Divider(height: 0, indent: 54, color: cs.outlineVariant),
            ]);
          }).toList(),
        ),
      ),
    ]);
  }
}

// ── Tile ──────────────────────────────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  const _SettingsTile({required this.icon, required this.color,
    required this.title, this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      leading: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color, size: 17),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)) : null,
      trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 18),
      onTap: onTap,
    );
  }
}

// ── Switch Tile ────────────────────────────────────────────────────────────────
class _SwitchSettingsTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchSettingsTile({required this.icon, required this.color,
    required this.title, this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      leading: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color, size: 17),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)) : null,
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}
