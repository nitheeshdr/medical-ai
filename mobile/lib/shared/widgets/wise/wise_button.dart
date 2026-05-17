import 'package:flutter/material.dart';

enum WiseButtonStyle { primary, secondary, danger }

/// M3-native button — wraps [FilledButton] / [OutlinedButton] / [FilledButton] with red color.
class WiseButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final WiseButtonStyle style;
  final bool loading;
  final bool isLoading; // alias for backward compat
  final IconData? icon;

  const WiseButton({
    super.key,
    required this.label,
    this.onPressed,
    this.style = WiseButtonStyle.primary,
    this.loading = false,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final _loading = loading || isLoading;
    final child = _loading
        ? const SizedBox(width: 20, height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
        : icon != null
            ? Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(icon, size: 18), const SizedBox(width: 8), Text(label),
              ])
            : Text(label);

    switch (style) {
      case WiseButtonStyle.primary:
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(onPressed: _loading ? null : onPressed, child: child),
        );
      case WiseButtonStyle.secondary:
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(onPressed: _loading ? null : onPressed, child: child),
        );
      case WiseButtonStyle.danger:
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
            ),
            onPressed: _loading ? null : onPressed,
            child: child,
          ),
        );
    }
  }
}
