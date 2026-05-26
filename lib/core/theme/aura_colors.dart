import 'package:flutter/material.dart';

/// Single source of truth for AURA color tokens.
///
/// Rule: no other file in the app references hex codes directly.
/// All UI consumes colors through this class (or through Theme.of(context),
/// which is built from these tokens in AuraTheme).
abstract final class AuraColors {
  AuraColors._();

  // ---- Surfaces — deep aubergine family, never pure black ----------------
  static const Color bgBase = Color(0xFF1A1625);
  static const Color bgRaised = Color(0xFF241F33);
  static const Color bgElevated = Color(0xFF2E2845);
  static const Color border = Color(0xFF3B3556);

  // ---- Text — never pure white, gradient for hierarchy -------------------
  static const Color textPrimary = Color(0xFFECE9F5);
  static const Color textSecondary = Color(0xFFB8B0D4);
  static const Color textMuted = Color(0xFF7E7796);
  static const Color textDisabled = Color(0xFF514B6B);

  // ---- Accent — the "aura" lilac ----------------------------------------
  static const Color accent = Color(0xFFA78BFA);
  static const Color accentDim = Color(0xFF8B6DEE);
  static const Color accentBg = Color(0x33A78BFA);

  // ---- Intensity scale (calendar heat + PDF chart bars) -----------------
  static const Color intensityLow = Color(0xFF86EFAC);
  static const Color intensityMed = Color(0xFFFCD34D);
  static const Color intensityHigh = Color(0xFFFB7185);

  // ---- Semantic ----------------------------------------------------------
  static const Color error = Color(0xFFFB7185);
  static const Color success = Color(0xFF86EFAC);
  static const Color warning = Color(0xFFFCD34D);
}
