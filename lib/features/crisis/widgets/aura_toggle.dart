import 'package:aura/core/theme/aura_colors.dart';
import 'package:aura/core/theme/aura_radius.dart';
import 'package:aura/core/theme/aura_spacing.dart';
import 'package:aura/core/theme/aura_text_styles.dart';
import 'package:flutter/material.dart';

/// Sim/Não selector for whether the crisis had an aura. Two large pills so it
/// stays easy to tap one-handed during a crisis.
class AuraToggle extends StatelessWidget {
  const AuraToggle({required this.present, required this.onChanged, super.key});

  final bool present;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Pill(label: 'Não', selected: !present, onTap: () => onChanged(false)),
        ),
        const SizedBox(width: AuraSpacing.sm),
        Expanded(
          child: _Pill(label: 'Sim', selected: present, onTap: () => onChanged(true)),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Aura: $label',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AuraRadius.md),
        child: Container(
          constraints: const BoxConstraints(minHeight: AuraSpacing.tapTargetMin),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AuraColors.accentBg : AuraColors.bgRaised,
            border: Border.all(
              color: selected ? AuraColors.accent : AuraColors.border,
              width: selected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(AuraRadius.md),
          ),
          child: Text(
            label,
            style: AuraTextStyles.body.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: selected ? AuraColors.accent : AuraColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
