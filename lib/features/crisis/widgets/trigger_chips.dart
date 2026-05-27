import 'package:aura/core/theme/aura_colors.dart';
import 'package:aura/core/theme/aura_radius.dart';
import 'package:aura/core/theme/aura_spacing.dart';
import 'package:aura/core/theme/aura_text_styles.dart';
import 'package:aura/domain/crisis/trigger.dart';
import 'package:flutter/material.dart';

/// Single-select chip row for the 3 most-common migraine triggers. Tapping
/// the selected chip again clears the selection — the controller handles
/// the toggle so the screen state stays consistent.
class TriggerChips extends StatelessWidget {
  const TriggerChips({required this.selected, required this.onSelected, super.key});

  final CrisisTrigger? selected;
  final ValueChanged<CrisisTrigger> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (i, t) in CrisisTrigger.values.indexed) ...[
          if (i != 0) const SizedBox(width: AuraSpacing.sm),
          Expanded(
            child: _TriggerTile(
              label: t.labelPt,
              selected: selected == t,
              onTap: () => onSelected(t),
            ),
          ),
        ],
      ],
    );
  }
}

class _TriggerTile extends StatelessWidget {
  const _TriggerTile({required this.label, required this.selected, required this.onTap});

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
          height: AuraSpacing.tapTargetMin,
          decoration: BoxDecoration(
            color: selected ? AuraColors.accentBg : AuraColors.bgRaised,
            border: Border.all(color: selected ? AuraColors.accent : AuraColors.border),
            borderRadius: BorderRadius.circular(AuraRadius.md),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AuraTextStyles.body.copyWith(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? AuraColors.accent : AuraColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
