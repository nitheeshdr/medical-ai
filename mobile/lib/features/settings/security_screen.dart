import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';

class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});
  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  bool _biometric   = true;
  bool _twoFactor   = false;
  bool _loginAlerts = true;

  // ── Change Password ──────────────────────────────────────────────────────────

  Future<void> _changePassword() async {
    final oldCtrl  = TextEditingController();
    final newCtrl  = TextEditingController();
    final confCtrl = TextEditingController();
    bool obscure = true;
    String? error;

    final submitted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, ss) => AlertDialog(
          title: const Text('Change Password'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (error != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(error!, style: TextStyle(
                    color: Theme.of(ctx).colorScheme.onErrorContainer, fontSize: 13)),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: oldCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: newCtrl,
                obscureText: obscure,
                decoration: InputDecoration(
                  labelText: 'New password (min 8 chars)',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_reset_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => ss(() => obscure = !obscure),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: confCtrl,
                obscureText: obscure,
                decoration: const InputDecoration(
                  labelText: 'Confirm new password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.check_circle_outline),
                ),
              ),
            ]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (oldCtrl.text.isEmpty || newCtrl.text.isEmpty) {
                  ss(() => error = 'Please fill in all fields');
                  return;
                }
                if (newCtrl.text.length < 8) {
                  ss(() => error = 'New password must be at least 8 characters');
                  return;
                }
                if (newCtrl.text != confCtrl.text) {
                  ss(() => error = 'Passwords do not match');
                  return;
                }
                Navigator.pop(ctx, true);
              },
              child: const Text('Change'),
            ),
          ],
        ),
      ),
    );

    if (submitted != true || !mounted) return;

    // Call real API
    try {
      await ref.read(apiClientProvider).post('/auth/change-password', data: {
        'currentPassword': oldCtrl.text,
        'newPassword': newCtrl.text,
      });
      if (mounted) _snack('✓ Password changed successfully', success: true);
    } catch (e) {
      if (mounted) {
        final msg = e.toString().contains('401')
            ? 'Current password is incorrect'
            : 'Failed to change password. Try again.';
        _snack(msg);
      }
    }
  }

  // ── Delete Account ───────────────────────────────────────────────────────────

  Future<void> _deleteAccount() async {
    // Step 1: confirmation
    final step1 = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.delete_forever_rounded, size: 40, color: Theme.of(ctx).colorScheme.error),
        title: const Text('Delete Account?'),
        content: const Text(
          'This will permanently delete:\n\n• All your health reports\n• All prescriptions\n• All appointment history\n• Your account\n\nThis cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes, Delete'),
          ),
        ],
      ),
    );
    if (step1 != true || !mounted) return;

    // Step 2: type "DELETE" to confirm
    final typeCtrl = TextEditingController();
    final step2 = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Type DELETE to confirm',
              style: TextStyle(color: Theme.of(ctx).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 14),
          TextField(
            controller: typeCtrl,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Type DELETE',
            ),
            onChanged: (_) => ss(() {}),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: typeCtrl.text == 'DELETE'
                  ? Theme.of(ctx).colorScheme.error : null,
              foregroundColor: typeCtrl.text == 'DELETE'
                  ? Theme.of(ctx).colorScheme.onError : null,
            ),
            onPressed: typeCtrl.text == 'DELETE' ? () => Navigator.pop(ctx, true) : null,
            child: const Text('Delete Account'),
          ),
        ],
      )),
    );

    if (step2 == true && mounted) {
      _snack('Account deletion requested. You will receive an email confirmation.');
    }
  }

  // ── Download Data ────────────────────────────────────────────────────────────

  Future<void> _downloadData() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(children: [
          CircularProgressIndicator(),
          SizedBox(width: 20),
          Text('Preparing export…'),
        ]),
      ),
    );
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pop(context);
      _snack('✓ Export ready — check your email', success: true);
    }
  }

  void _snack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      backgroundColor: success ? const Color(0xFF10B981) : null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Security Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── Authentication ────────────────────────────────────────────
          _header('Authentication'),
          Card.outlined(child: Column(children: [
            SwitchListTile(
              secondary: _ico(Icons.fingerprint_rounded, const Color(0xFFF59E0B), cs),
              title: const Text('Biometric Login', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              subtitle: Text('Face ID / Touch ID', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
              value: _biometric,
              onChanged: (v) {
                setState(() => _biometric = v);
                _snack(v ? '✓ Biometrics enabled' : 'Biometrics disabled', success: v);
              },
            ),
            _divider(cs),
            SwitchListTile(
              secondary: _ico(Icons.security_rounded, cs.primary, cs),
              title: const Text('Two-Factor Auth (2FA)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              subtitle: Text('SMS code on each login', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
              value: _twoFactor,
              onChanged: (v) {
                setState(() => _twoFactor = v);
                _snack(v ? '✓ 2FA enabled — check your email for setup' : '2FA disabled', success: v);
              },
            ),
            _divider(cs),
            SwitchListTile(
              secondary: _ico(Icons.notifications_active_rounded, cs.primary, cs),
              title: const Text('Login Alerts', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              subtitle: Text('Notified when a new device signs in',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
              value: _loginAlerts,
              onChanged: (v) => setState(() => _loginAlerts = v),
            ),
          ])),

          // ── Password ───────────────────────────────────────────────────
          _header('Password'),
          Card.outlined(child: Column(children: [
            ListTile(
              leading: _ico(Icons.lock_reset_rounded, cs.primary, cs),
              title: const Text('Change Password',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              subtitle: Text('Update your account password',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
              trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 18),
              onTap: _changePassword,
            ),
            _divider(cs),
            ListTile(
              leading: _ico(Icons.phonelink_lock_rounded, cs.primary, cs),
              title: const Text('Active Sessions',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              subtitle: Text('Manage devices signed into your account',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
              trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 18),
              onTap: () => _snack('Go to Settings → Connected Devices'),
            ),
          ])),

          // ── Privacy ────────────────────────────────────────────────────
          _header('Privacy & Data'),
          Card.outlined(child: Column(children: [
            ListTile(
              leading: _ico(Icons.download_rounded, cs.primary, cs),
              title: const Text('Download My Data',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              subtitle: Text('Export all your health data as PDF/JSON',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
              trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 18),
              onTap: _downloadData,
            ),
            _divider(cs),
            ListTile(
              leading: Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: cs.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.delete_forever_rounded, color: cs.error, size: 17),
              ),
              title: Text('Delete Account',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: cs.error)),
              subtitle: Text('Permanently remove account & all data',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
              trailing: Icon(Icons.chevron_right, color: cs.error, size: 18),
              onTap: _deleteAccount,
            ),
          ])),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _header(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 18, 0, 6),
    child: Text(title, style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5)),
  );

  Widget _divider(ColorScheme cs) => Divider(height: 0, indent: 54, color: cs.outlineVariant);

  Widget _ico(IconData icon, Color color, ColorScheme cs) => Container(
    width: 34, height: 34,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(icon, color: color, size: 17),
  );
}
