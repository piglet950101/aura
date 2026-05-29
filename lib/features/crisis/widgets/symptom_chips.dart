import 'package:aura/core/theme/aura_colors.dart';
import 'package:aura/core/theme/aura_radius.dart';
import 'package:aura/core/theme/aura_spacing.dart';
import 'package:aura/core/theme/aura_text_styles.dart';
import 'package:aura/domain/crisis/symptom.dart';
import 'package:flutter/material.dart';

/// Multi-select chip grid for symptoms (aura is excluded — it has its own
/// Sim/Não question). A "Sem sintomas" chip clears the selection and is shown
/// active when nothing is selected.
class SymptomChips extends StatelessWidget {
  const SymptomChips({
    required this.selected,
    required this.onToggle,
    required this.onClear,
    super.key,
  });

  final Set<Symptom> selected;
  final ValueChanged<Symptom> onToggle;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final anySelected = Symptom.chips.any(selected.contains);
    return Wrap(
      spacing: AuraSpacing.sm,
      runSpacing: AuraSpacing.sm,
      children: [
        for (final s in Symptom.chips)
          _ChipTile(label: s.labelPt, selected: selected.contains(s), onTap: () => onToggle(s)),
        _ChipTile(label: 'Sem sintomas', selected: !anySelected, onTap: onClear),
      ],
    );
  }
}

class _ChipTile extends StatelessWidget {
  const _ChipTile({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AuraRadius.md),
        child: Container(
          constraints: const BoxConstraints(minHeight: AuraSpacing.tapTargetMin),
          padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.lg, vertical: AuraSpacing.md),
          decoration: BoxDecoration(
            color: selected ? AuraColors.accentBg : AuraColors.bgRaised,
            border: Border.all(color: selected ? AuraColors.accent : AuraColors.border),
            borderRadius: BorderRadius.circular(AuraRadius.md),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AuraTextStyles.body.copyWith(
                  color: selected ? AuraColors.accent : AuraColors.textSecondary,
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              if (selected) ...[
                const SizedBox(width: AuraSpacing.sm),
                const Icon(Icons.check, size: 16, color: AuraColors.accent),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
