import 'package:aura/core/theme/aura_colors.dart';
import 'package:flutter/material.dart';

/// Typography tokens.
///
/// fontFamily is intentionally null in v1 — we use the platform default
/// (SF Pro on iOS, Roboto on Android). Inter is the design target and will
/// be bundled as an asset before public release; the styles below already
/// match Inter's metrics so the swap is mechanical.
abstract final class AuraTextStyles {
  AuraTextStyles._();

  static const TextStyle screenTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -0.4,
    color: AuraColors.textPrimary,
  );

  static const TextStyle sectionLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    color: AuraColors.textMuted,
  );

  static const TextStyle body = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AuraColors.textPrimary,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AuraColors.textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AuraColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.3,
    color: AuraColors.textMuted,
  );

  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
    color: AuraColors.textPrimary,
  );

  static const TextStyle numeric = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AuraColors.textPrimary,
  );

  static const TextStyle brand = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 3,
    color: AuraColors.textPrimary,
  );
}
