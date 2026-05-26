import 'package:aura/core/theme/aura_colors.dart';
import 'package:aura/core/theme/aura_radius.dart';
import 'package:aura/core/theme/aura_spacing.dart';
import 'package:aura/core/theme/aura_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Single dark theme for the AURA MVP.
///
/// v1 is dark-only inside the app; the exported PDF renders in its own
/// document-style light theme. We do not implement a light app theme.
abstract final class AuraTheme {
  AuraTheme._();

  static ThemeData get dark {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AuraColors.accent,
      onPrimary: AuraColors.bgBase,
      secondary: AuraColors.accentDim,
      onSecondary: AuraColors.bgBase,
      surface: AuraColors.bgBase,
      onSurface: AuraColors.textPrimary,
      surfaceContainerLow: AuraColors.bgRaised,
      surfaceContainerHigh: AuraColors.bgElevated,
      surfaceContainerHighest: AuraColors.bgElevated,
      outline: AuraColors.border,
      outlineVariant: AuraColors.border,
      error: AuraColors.error,
      onError: AuraColors.bgBase,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AuraColors.bgBase,
      canvasColor: AuraColors.bgBase,
      splashColor: AuraColors.accentBg,
      highlightColor: AuraColors.accentBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        titleTextStyle: AuraTextStyles.screenTitle,
        iconTheme: IconThemeData(color: AuraColors.textPrimary),
      ),
      textTheme: const TextTheme(
        displayLarge: AuraTextStyles.screenTitle,
        headlineMedium: AuraTextStyles.screenTitle,
        titleLarge: AuraTextStyles.screenTitle,
        bodyLarge: AuraTextStyles.body,
        bodyMedium: AuraTextStyles.bodySecondary,
        bodySmall: AuraTextStyles.bodySmall,
        labelLarge: AuraTextStyles.button,
        labelMedium: AuraTextStyles.bodySmall,
        labelSmall: AuraTextStyles.sectionLabel,
      ),
      cardTheme: CardThemeData(
        color: AuraColors.bgRaised,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AuraRadius.lg),
          side: const BorderSide(color: AuraColors.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AuraColors.accent,
          foregroundColor: AuraColors.bgBase,
          disabledBackgroundColor: AuraColors.bgElevated,
          disabledForegroundColor: AuraColors.textMuted,
          minimumSize: const Size.fromHeight(AuraSpacing.tapTargetMin),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AuraRadius.lg)),
          textStyle: AuraTextStyles.button.copyWith(color: AuraColors.bgBase),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AuraColors.textPrimary,
          side: const BorderSide(color: AuraColors.border),
          minimumSize: const Size.fromHeight(AuraSpacing.tapTargetMin),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AuraRadius.lg)),
          textStyle: AuraTextStyles.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AuraColors.accent,
          minimumSize: const Size.fromHeight(AuraSpacing.tapTargetMin),
          textStyle: AuraTextStyles.button.copyWith(color: AuraColors.accent),
        ),
      ),
      iconTheme: const IconThemeData(color: AuraColors.textSecondary, size: 24),
      dividerTheme: const DividerThemeData(color: AuraColors.border, thickness: 1, space: 1),
      visualDensity: VisualDensity.standard,
    );
  }
}
