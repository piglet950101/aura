import 'package:aura/core/theme/aura_colors.dart';
import 'package:aura/core/theme/aura_radius.dart';
import 'package:aura/core/theme/aura_spacing.dart';
import 'package:aura/core/theme/aura_text_styles.dart';
import 'package:flutter/material.dart';

/// Visual preview of the AURA design tokens.
///
/// This is the temporary first screen, used to validate the palette and
/// typography choices end-to-end on a real device. It will be replaced by
/// the home dashboard on Day 6.
class ThemePreviewScreen extends StatelessWidget {
  const ThemePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.xl, vertical: AuraSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Text('AURA', style: AuraTextStyles.brand),
                  const SizedBox(width: AuraSpacing.sm),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AuraColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AuraSpacing.sm),
                  Text(
                    'tokens preview',
                    style: AuraTextStyles.bodySmall.copyWith(
                      color: AuraColors.textMuted,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AuraSpacing.xl),
              const Text('Design tokens', style: AuraTextStyles.screenTitle),
              const SizedBox(height: AuraSpacing.sm),
              const Text(
                'Esta é uma tela de diagnóstico. Será substituída pelo dashboard real.',
                style: AuraTextStyles.bodySmall,
              ),
              const SizedBox(height: AuraSpacing.xxl),
              const _SectionLabel('Surfaces'),
              const _Swatch(label: 'bgBase', color: AuraColors.bgBase, hex: '#1A1625'),
              const _Swatch(label: 'bgRaised', color: AuraColors.bgRaised, hex: '#241F33'),
              const _Swatch(label: 'bgElevated', color: AuraColors.bgElevated, hex: '#2E2845'),
              const _Swatch(label: 'border', color: AuraColors.border, hex: '#3B3556'),
              const SizedBox(height: AuraSpacing.xl),
              const _SectionLabel('Text'),
              const _Swatch(label: 'textPrimary', color: AuraColors.textPrimary, hex: '#ECE9F5'),
              const _Swatch(
                label: 'textSecondary',
                color: AuraColors.textSecondary,
                hex: '#B8B0D4',
              ),
              const _Swatch(label: 'textMuted', color: AuraColors.textMuted, hex: '#7E7796'),
              const SizedBox(height: AuraSpacing.xl),
              const _SectionLabel('Accent'),
              const _Swatch(label: 'accent', color: AuraColors.accent, hex: '#A78BFA'),
              const _Swatch(label: 'accentDim', color: AuraColors.accentDim, hex: '#8B6DEE'),
              const SizedBox(height: AuraSpacing.xl),
              const _SectionLabel('Intensity scale'),
              const _Swatch(label: 'intensityLow', color: AuraColors.intensityLow, hex: '#86EFAC'),
              const _Swatch(label: 'intensityMed', color: AuraColors.intensityMed, hex: '#FCD34D'),
              const _Swatch(
                label: 'intensityHigh',
                color: AuraColors.intensityHigh,
                hex: '#FB7185',
              ),
              const SizedBox(height: AuraSpacing.xxl),
              const _SectionLabel('Typography'),
              const Text('Screen title · 24 / 700', style: AuraTextStyles.screenTitle),
              const SizedBox(height: AuraSpacing.sm),
              const Text(
                'Body · 17 / 400 — line height 1.4 for fatigued eyes during a crisis.',
                style: AuraTextStyles.body,
              ),
              const SizedBox(height: AuraSpacing.sm),
              const Text('Body small · 13 / 400', style: AuraTextStyles.bodySmall),
              const SizedBox(height: AuraSpacing.sm),
              const Text('SECTION LABEL · 11 / 600 · TRACKED', style: AuraTextStyles.sectionLabel),
              const SizedBox(height: AuraSpacing.sm),
              const Text('Numeric 18 / 700: 6,2', style: AuraTextStyles.numeric),
              const SizedBox(height: AuraSpacing.xxl),
              const _SectionLabel('Buttons · min 56dp tap target'),
              ElevatedButton(onPressed: () {}, child: const Text('Registar crise')),
              const SizedBox(height: AuraSpacing.sm),
              OutlinedButton(onPressed: () {}, child: const Text('Cancelar')),
              const SizedBox(height: AuraSpacing.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(onPressed: () {}, child: const Text('Saber mais')),
              ),
              const SizedBox(height: AuraSpacing.xxl),
              const _SectionLabel('Card on bgBase'),
              Container(
                padding: const EdgeInsets.all(AuraSpacing.lg),
                decoration: BoxDecoration(
                  color: AuraColors.bgRaised,
                  border: Border.all(color: AuraColors.border),
                  borderRadius: BorderRadius.circular(AuraRadius.lg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sábado · 25 maio',
                      style: AuraTextStyles.sectionLabel.copyWith(color: AuraColors.textMuted),
                    ),
                    const SizedBox(height: AuraSpacing.xs),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'Intensidade 7',
                          style: AuraTextStyles.screenTitle.copyWith(fontSize: 18),
                        ),
                        const SizedBox(width: AuraSpacing.sm),
                        Text(
                          '· intensa',
                          style: AuraTextStyles.bodySmall.copyWith(
                            color: AuraColors.intensityHigh,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AuraSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AuraSpacing.md),
      child: Text(text.toUpperCase(), style: AuraTextStyles.sectionLabel),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.label, required this.color, required this.hex});

  final Color color;
  final String hex;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AuraSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: AuraColors.border),
              borderRadius: BorderRadius.circular(AuraRadius.sm),
            ),
          ),
          const SizedBox(width: AuraSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AuraTextStyles.body),
                Text(hex, style: AuraTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
