import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cupertino_native/cupertino_native.dart';
import '../../../core/constants/app_colors.dart';

/// Wraps CNTabBar (native UIKit Liquid Glass) on iOS,
/// falls back to a BackdropFilter glass pill on other platforms.
class GlassNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<GlassNavItem> items;

  const GlassNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return _NativeTabBar(
        currentIndex: currentIndex,
        onTap: onTap,
        items: items,
      );
    }
    return _FallbackGlassBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: items,
    );
  }
}

// ── Native iOS — real UIKit CNTabBar with Liquid Glass ──────────────────────

class _NativeTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<GlassNavItem> items;

  const _NativeTabBar({
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 83 + bottomPadding,
        child: CNTabBar(
          currentIndex: currentIndex,
          onTap: onTap,
          items: items
              .map((item) => CNTabBarItem(
                    label: item.label,
                    icon: CNSymbol(item.sfSymbol),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

// ── Non-iOS fallback — BackdropFilter pill ───────────────────────────────────

class _FallbackGlassBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<GlassNavItem> items;

  const _FallbackGlassBar({
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 16,
      left: 24,
      right: 24,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: kGlassBorder, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: items.asMap().entries.map((e) {
                final isSelected = e.key == currentIndex;
                return _FallbackNavItem(
                  item: e.value,
                  isSelected: isSelected,
                  onTap: () => onTap(e.key),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _FallbackNavItem extends StatelessWidget {
  final GlassNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _FallbackNavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? item.activeIcon : item.icon,
              color: isSelected ? kPrimaryText : kSecondaryText,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(
                color: isSelected ? kPrimaryText : kSecondaryText,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared data model ────────────────────────────────────────────────────────

class GlassNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  /// SF Symbol name used for CNTabBarItem on iOS (e.g. 'house.fill').
  final String sfSymbol;

  const GlassNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.sfSymbol,
  });
}
