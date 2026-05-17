import 'package:flutter/material.dart';

// ── MediNova SaaS Design System — Light Palette ───────────────────────────────

/// Page / screen background
const kBackground    = Color(0xFFF7F8FA);

/// Card / panel surface (pure white)
const kSurface       = Color(0xFFFFFFFF);

/// Subtly elevated element (inner sections, pressed states)
const kElevated      = Color(0xFFF1F3F6);

/// Border / divider
const kBorder        = Color(0xFFE5E9EF);

// ── Typography ────────────────────────────────────────────────────────────────

const kPrimaryText   = Color(0xFF111827); // gray-900
const kSecondaryText = Color(0xFF6B7280); // gray-500
const kTertiaryText  = Color(0xFF9CA3AF); // gray-400

// ── Brand accent — modern SaaS indigo ────────────────────────────────────────

const kAccent        = Color(0xFF6366F1); // indigo-500
const kAccentDark    = Color(0xFF4F46E5); // indigo-600 (gradient end)
const kAccentLight   = Color(0xFFEEF2FF); // indigo-50
const kAccentMid     = Color(0xFFC7D2FE); // indigo-200 (badges, highlights)

// ── Gradient helpers ──────────────────────────────────────────────────────────

const kGradientStart = kAccent;
const kGradientEnd   = Color(0xFF8B5CF6); // violet-500

const kBrandGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [kGradientStart, kGradientEnd],
);

const kCardGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
);

// ── Semantic colors ───────────────────────────────────────────────────────────

const kSuccessGreen  = Color(0xFF10B981); // emerald-500
const kSuccessLight  = Color(0xFFD1FAE5); // emerald-100
const kWarningOrange = Color(0xFFF59E0B); // amber-500
const kWarningLight  = Color(0xFFFEF3C7); // amber-100
const kErrorRed      = Color(0xFFEF4444); // red-500
const kErrorLight    = Color(0xFFFEE2E2); // red-100

// ── Shadows ───────────────────────────────────────────────────────────────────

const kShadowColor   = Color(0x0D000000); // 5% black — very subtle
const kShadowMd      = Color(0x1A000000); // 10% black

// ── Legacy aliases ────────────────────────────────────────────────────────────

const kBlack      = Color(0xFF111827);
const kGlassBorder = Color(0xFFE5E9EF);
const kGlassWhite  = Color(0xFFF7F8FA);
const kAccentGlow  = kAccent;
