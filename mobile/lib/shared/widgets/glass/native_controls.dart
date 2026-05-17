import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cupertino_native/cupertino_native.dart';
import '../../../core/constants/app_colors.dart';

/// Switch — native CNSwitch on iOS, Material Switch elsewhere.
class AdaptiveSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const AdaptiveSwitch({super.key, required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CNSwitch(value: value, onChanged: onChanged ?? (_) {});
    }
    return Switch(
      value: value,
      onChanged: onChanged,
      activeThumbColor: kPrimaryText,
      activeTrackColor: kElevated,
    );
  }
}

/// Slider — native CNSlider on iOS, Material Slider elsewhere.
class AdaptiveSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double>? onChanged;

  const AdaptiveSlider({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CNSlider(value: value, min: min, max: max, onChanged: onChanged ?? (_) {});
    }
    return Slider(
      value: value,
      min: min,
      max: max,
      onChanged: onChanged,
      activeColor: kPrimaryText,
    );
  }
}

/// Segmented control — native CNSegmentedControl on iOS.
class AdaptiveSegmentedControl extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;

  const AdaptiveSegmentedControl({
    super.key,
    required this.labels,
    required this.selectedIndex,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CNSegmentedControl(
        labels: labels,
        selectedIndex: selectedIndex,
        onValueChanged: onChanged ?? (_) {},
      );
    }
    // Material fallback: outlined toggle buttons
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: labels.asMap().entries.map((e) {
        final selected = e.key == selectedIndex;
        return GestureDetector(
          onTap: () => onChanged?.call(e.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? kPrimaryText : Colors.transparent,
              border: Border.all(color: kBorder),
              borderRadius: BorderRadius.horizontal(
                left: e.key == 0 ? const Radius.circular(8) : Radius.zero,
                right: e.key == labels.length - 1 ? const Radius.circular(8) : Radius.zero,
              ),
            ),
            child: Text(
              e.value,
              style: TextStyle(
                color: selected ? kBlack : kSecondaryText,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// SF Symbol icon — CNIcon on iOS, falls back to a Material icon.
class AdaptiveIcon extends StatelessWidget {
  final String sfSymbol;
  final IconData fallbackIcon;
  final double size;
  final Color color;

  const AdaptiveIcon({
    super.key,
    required this.sfSymbol,
    required this.fallbackIcon,
    this.size = 24,
    this.color = kPrimaryText,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CNIcon(symbol: CNSymbol(sfSymbol));
    }
    return Icon(fallbackIcon, size: size, color: color);
  }
}
