import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cupertino_native/cupertino_native.dart';
import '../../../core/constants/app_colors.dart';

class AdaptiveButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isPrimary;

  const AdaptiveButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2, color: kPrimaryText),
        ),
      );
    }

    if (Platform.isIOS) {
      return CNButton(
        label: label,
        onPressed: onPressed,
      );
    }

    if (isPrimary) {
      return FilledButton(
        onPressed: onPressed,
        child: Text(label),
      );
    }
    return OutlinedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
