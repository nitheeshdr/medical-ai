import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  static const displayLarge = TextStyle(fontSize: 57, fontWeight: FontWeight.w300, color: kPrimaryText, letterSpacing: -0.25);
  static const displayMedium = TextStyle(fontSize: 45, fontWeight: FontWeight.w300, color: kPrimaryText);
  static const displaySmall = TextStyle(fontSize: 36, fontWeight: FontWeight.w400, color: kPrimaryText);

  static const headlineLarge = TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: kPrimaryText);
  static const headlineMedium = TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: kPrimaryText);
  static const headlineSmall = TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: kPrimaryText);

  static const titleLarge = TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: kPrimaryText);
  static const titleMedium = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kPrimaryText, letterSpacing: 0.15);
  static const titleSmall = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kPrimaryText, letterSpacing: 0.1);

  static const bodyLarge = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: kPrimaryText, letterSpacing: 0.5);
  static const bodyMedium = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: kPrimaryText, letterSpacing: 0.25);
  static const bodySmall = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: kSecondaryText, letterSpacing: 0.4);

  static const labelLarge = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kPrimaryText, letterSpacing: 0.1);
  static const labelMedium = TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: kSecondaryText, letterSpacing: 0.5);
  static const labelSmall = TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kSecondaryText, letterSpacing: 0.5);
}
