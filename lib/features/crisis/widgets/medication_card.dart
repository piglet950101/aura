import 'package:aura/core/theme/aura_colors.dart';
import 'package:aura/core/theme/aura_radius.dart';
import 'package:aura/core/theme/aura_spacing.dart';
import 'package:aura/core/theme/aura_text_styles.dart';
import 'package:flutter/material.dart';

/// Read-only medication card for Day 5 — surfaces the default medication
/// if one exists, with a disabled "Mudar" affordance that becomes live on
/// Day 10 when the medication CRUD ships.
class MedicationCard extends StatelessWidget {
  const MedicationCard({this.defaultMedicationName, this.defaultDoseMg, super.key});

  final String? defaultMedicationName;
  final double? defaultDoseMg;

  @override
  Widget build(BuildContext context) {
    final hasDefault = defaultMedicationName != null;
    return Container(
      padding: const EdgeInsets.all(AuraSpacing.lg),
      decoration: BoxDecoration(
        color: AuraColors.bgRaised,
        border: Border.all(color: AuraColors.border),
        borderRadius: BorderRadius.circular(AuraRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AuraColors.accentBg,
              borderRadius: BorderRadius.circular(AuraRadius.sm),
            ),
            alignment: Alignment.center,
            child: const Text(
              '℞',
              style: TextStyle(color: AuraColors.accent, fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: AuraSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  hasDefault
                      ? '$defaultMedicationName${defaultDoseMg != null ? ' ${defaultDoseMg!.toStringAsFixed(0)} mg' : ''}'
                      : 'Sem medicação predefinida',
                  style: AuraTextStyles.body.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: hasDefault ? AuraColors.textPrimary : AuraColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasDefault ? 'preset' : 'configurar nas definições',
                  style: AuraTextStyles.caption,
                ),
              ],
            ),
          ),
          Text(
            'Mudar',
            style: AuraTextStyles.caption.copyWith(
              color: AuraColors.textMuted,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
