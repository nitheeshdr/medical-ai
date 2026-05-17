import 'package:flutter/material.dart';

enum WiseBadgeType { success, warning, error, info, neutral }

/// M3-native badge — uses a styled [Chip] or [Container].
class WiseBadge extends StatelessWidget {
  final String label;
  final WiseBadgeType type;

  const WiseBadge({super.key, required this.label, this.type = WiseBadgeType.neutral});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Color bg;
    Color fg;

    switch (type) {
      case WiseBadgeType.success:
        bg = const Color(0xFFD1FAE5); fg = const Color(0xFF065F46);
      case WiseBadgeType.warning:
        bg = const Color(0xFFFEF3C7); fg = const Color(0xFF92400E);
      case WiseBadgeType.error:
        bg = cs.errorContainer; fg = cs.onErrorContainer;
      case WiseBadgeType.info:
        bg = cs.primaryContainer; fg = cs.onPrimaryContainer;
      case WiseBadgeType.neutral:
        bg = cs.surfaceContainerHighest; fg = cs.onSurface;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
