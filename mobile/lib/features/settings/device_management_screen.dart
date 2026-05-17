import 'package:flutter/material.dart';

class DeviceManagementScreen extends StatefulWidget {
  const DeviceManagementScreen({super.key});
  @override
  State<DeviceManagementScreen> createState() => _DeviceManagementScreenState();
}

class _DeviceManagementScreenState extends State<DeviceManagementScreen> {
  final List<_Device> _devices = [
    _Device('iPhone 15 Pro', 'iOS 18.3', 'Current device', Icons.phone_iphone_rounded, isCurrent: true),
    _Device('MacBook Pro', 'macOS 15.2', '2 hours ago', Icons.laptop_mac_rounded),
    _Device('Apple Watch Ultra', 'watchOS 11', '5 min ago', Icons.watch_rounded),
    _Device('iPad Air', 'iOS 18.3', '3 days ago', Icons.tablet_mac_rounded),
  ];

  Future<void> _removeDevice(_Device d) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove ${d.name}?'),
        content: const Text('This will sign out the session on that device.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      setState(() => _devices.remove(d));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${d.name} removed'), behavior: SnackBarBehavior.floating));
    }
  }

  Future<void> _signOutAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.logout_rounded, size: 36, color: Theme.of(ctx).colorScheme.error),
        title: const Text('Sign out all devices?'),
        content: const Text('This will sign you out from all other devices except this one.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out All'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      setState(() => _devices.removeWhere((d) => !d.isCurrent));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed out from all other devices'),
            behavior: SnackBarBehavior.floating));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Connected Devices')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Active Sessions',
              style: tt.labelMedium?.copyWith(
                  color: cs.primary, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Card.outlined(
            child: Column(
              children: _devices.asMap().entries.map((e) {
                final d      = e.value;
                final isLast = e.key == _devices.length - 1;
                return Column(mainAxisSize: MainAxisSize.min, children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: d.isCurrent ? cs.primaryContainer : cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(d.icon,
                          color: d.isCurrent ? cs.primary : cs.onSurfaceVariant, size: 22),
                    ),
                    title: Row(children: [
                      Text(d.name,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      if (d.isCurrent) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('This device',
                              style: TextStyle(color: Color(0xFF10B981),
                                  fontSize: 10, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ]),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.os, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                        Text(d.lastSeen, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
                      ],
                    ),
                    trailing: d.isCurrent
                        ? null
                        : TextButton(
                            onPressed: () => _removeDevice(d),
                            style: TextButton.styleFrom(foregroundColor: cs.error),
                            child: const Text('Remove'),
                          ),
                  ),
                  if (!isLast) Divider(height: 0, indent: 72, color: cs.outlineVariant),
                ]);
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _signOutAll,
              style: OutlinedButton.styleFrom(
                foregroundColor: cs.error,
                side: BorderSide(color: cs.error),
              ),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign out all other devices'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _Device {
  final String name, os, lastSeen;
  final IconData icon;
  final bool isCurrent;
  _Device(this.name, this.os, this.lastSeen, this.icon, {this.isCurrent = false});
}
