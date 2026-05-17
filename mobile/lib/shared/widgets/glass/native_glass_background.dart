import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';

/// Full-screen or arbitrary-sized frosted glass surface.
/// iOS 26+: UIGlassEffect. iOS 14-25: ultraThinMaterialDark blur.
/// Android: BackdropFilter.
class NativeGlassBackground extends StatelessWidget {
  final Widget? child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  /// "ultraThin" (default) or "thick"
  final String style;

  const NativeGlassBackground({
    super.key,
    this.child,
    this.borderRadius = 0,
    this.padding,
    this.style = 'ultraThin',
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) return _nativeBackground();
    return _flutterBackground();
  }

  Widget _nativeBackground() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        children: [
          Positioned.fill(
            child: UiKitView(
              viewType: 'medinova/glass_background',
              creationParams: {'style': style, 'cornerRadius': borderRadius},
              creationParamsCodec: const StandardMessageCodec(),
            ),
          ),
          if (child != null)
            Padding(
              padding: padding ?? EdgeInsets.zero,
              child: child,
            ),
        ],
      ),
    );
  }

  Widget _flutterBackground() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: padding,
          color: Colors.white.withValues(alpha: 0.07),
          child: child,
        ),
      ),
    );
  }
}

/// Native glass navigation bar chrome (frosted top bar background).
class NativeGlassNavBar extends StatelessWidget {
  final double height;
  final Widget? child;

  const NativeGlassNavBar({super.key, required this.height, this.child});

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return SizedBox(
        height: height,
        child: Stack(
          children: [
            Positioned.fill(
              child: UiKitView(
                viewType: 'medinova/glass_nav_bar',
                creationParamsCodec: const StandardMessageCodec(),
              ),
            ),
            if (child != null) child!,
          ],
        ),
      );
    }
    // Android: solid surface color
    return Container(
      height: height,
      color: kSurface,
      child: child,
    );
  }
}
