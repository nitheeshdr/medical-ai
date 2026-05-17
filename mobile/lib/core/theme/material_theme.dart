import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

class MaterialAppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kAccent,
        brightness: Brightness.light,
        surface: kSurface,
        onSurface: kPrimaryText,
        primary: kAccent,
        onPrimary: Colors.white,
        secondary: kGradientEnd,
        error: kErrorRed,
        outline: kBorder,
      ),
      scaffoldBackgroundColor: kBackground,
      cardTheme: CardThemeData(
        color: kSurface,
        elevation: 0,
        shadowColor: kShadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: kBorder),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: kSurface,
        foregroundColor: kPrimaryText,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: kShadowColor,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: kPrimaryText, fontSize: 17,
          fontWeight: FontWeight.w600, letterSpacing: -0.3,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: kSurface,
        surfaceTintColor: Colors.transparent,
        shadowColor: kShadowColor,
        elevation: 8,
        indicatorColor: kAccentLight,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final color = states.contains(WidgetState.selected) ? kAccent : kSecondaryText;
          return TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final color = states.contains(WidgetState.selected) ? kAccent : kSecondaryText;
          return IconThemeData(color: color, size: 22);
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: kAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: kAccent,
          side: const BorderSide(color: kBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kAccent, width: 1.5),
        ),
        hintStyle: const TextStyle(color: kTertiaryText, fontSize: 15),
        labelStyle: const TextStyle(color: kSecondaryText, fontSize: 15),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      dividerTheme: const DividerThemeData(color: kBorder, thickness: 0.5, space: 0),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? Colors.white : kTertiaryText),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? kAccent : kElevated),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: kElevated,
        selectedColor: kAccentLight,
        labelStyle: const TextStyle(fontSize: 13, color: kPrimaryText),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: kBorder),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: kSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: kSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(color: kPrimaryText, fontSize: 18, fontWeight: FontWeight.w700),
        contentTextStyle: const TextStyle(color: kSecondaryText, fontSize: 14),
      ),
      textTheme: const TextTheme(
        displayLarge:  AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        displaySmall:  AppTypography.displaySmall,
        headlineLarge: AppTypography.headlineLarge,
        headlineMedium:AppTypography.headlineMedium,
        headlineSmall: AppTypography.headlineSmall,
        titleLarge:    AppTypography.titleLarge,
        titleMedium:   AppTypography.titleMedium,
        titleSmall:    AppTypography.titleSmall,
        bodyLarge:     AppTypography.bodyLarge,
        bodyMedium:    AppTypography.bodyMedium,
        bodySmall:     AppTypography.bodySmall,
        labelLarge:    AppTypography.labelLarge,
        labelMedium:   AppTypography.labelMedium,
        labelSmall:    AppTypography.labelSmall,
      ),
    );
  }

  // Keep dark alias so existing code compiles
  static ThemeData get dark => light;
}
