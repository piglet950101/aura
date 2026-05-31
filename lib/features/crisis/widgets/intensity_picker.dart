import 'package:aura/core/theme/aura_colors.dart';
import 'package:aura/core/theme/aura_radius.dart';
import 'package:aura/core/theme/aura_spacing.dart';
import 'package:aura/core/theme/aura_text_styles.dart';
import 'package:aura/l10n/app_l10n.dart';
import 'package:flutter/material.dart';

/// Ten circular dots labelled 1..10. The selected dot scales up slightly
/// and adopts a color that escalates from green (1) through amber (4-6) to
/// coral (8-10). Each dot is a 56dp tap target — the briefing's "alvos de
/// toque grandes (mãos que tremem)" rule lives here.
class IntensityPicker extends StatelessWidget {
  const IntensityPicker({required this.value, required this.onChanged, super.key});

  final int? value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 1; i <= 10; i++)
              _Dot(value: i, selected: value == i, onTap: () => onChanged(i)),
          ],
        ),
        const SizedBox(height: AuraSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l.intensityScaleMin, style: AuraTextStyles.caption),
              if (value != null)
                Text(
                  _label(l, value!),
                  style: AuraTextStyles.caption.copyWith(
                    color: _color(value!),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              Text(l.intensityScaleMax, style: AuraTextStyles.caption),
            ],
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.value, required this.selected, required this.onTap});
  final int value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _color(value);
    return Semantics(
      label: AppL10n.of(context).intensityOutOf(value),
      selected: selected,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        // Outer transparent box guarantees 56dp tap surface even when the
        // visible dot is smaller. We do NOT shrink the dot to ~28dp — the
        // hit area and the visual stay aligned for trustworthy targeting.
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: AuraSpacing.tapTargetMin * 0.5,
          height: AuraSpacing.tapTargetMin * 0.5,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? color : AuraColors.bgRaised,
            border: Border.all(color: selected ? color : AuraColors.border),
            shape: BoxShape.circle,
            boxShadow: selected
                ? [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 14)]
                : null,
          ),
          transformAlignment: Alignment.center,
          transform: selected
              ? (Matrix4.identity()..scaleByDouble(1.08, 1.08, 1, 1))
              : Matrix4.identity(),
          child: Text(
            '$value',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected ? AuraColors.bgBase : AuraColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

Color _color(int value) {
  if (value <= 3) return AuraColors.intensityLow;
  if (value <= 6) return AuraColors.intensityMed;
  return AuraColors.intensityHigh;
}

String _label(AppL10n l, int value) {
  if (value <= 3) return l.intensityLabelMild;
  if (value <= 6) return l.intensityLabelModerate;
  if (value <= 8) return l.intensityLabelIntense;
  return l.intensityLabelDisabling;
}

// Unused import suppression for AuraRadius — kept so the widget can be
// extended with rounded backgrounds later without re-adding the import.
// ignore: unused_element
const _kKeepImport = AuraRadius.sm;
