import 'package:aura/core/theme/aura_colors.dart';
import 'package:aura/core/theme/aura_radius.dart';
import 'package:aura/core/theme/aura_spacing.dart';
import 'package:aura/core/theme/aura_text_styles.dart';
import 'package:aura/data/local/database.dart';
import 'package:aura/domain/medication/common_medications.dart';
import 'package:aura/domain/medication/medication_kind.dart';
import 'package:aura/features/crisis/crisis_registration_controller.dart';
import 'package:aura/features/medications/medication_edit_screen.dart';
import 'package:aura/features/medications/medications_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Crisis-form control for logging which medication was taken during the
/// crisis. Shows the current selection (or "Nenhuma") and opens a single-
/// select sheet of the user's active medications. The chosen medication's
/// name + dose are snapshotted into the draft.
class MedicationPicker extends ConsumerWidget {
  const MedicationPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(crisisDraftProvider);
    final meds = ref.watch(activeMedicationsProvider).valueOrNull ?? const <Medication>[];
    final selectedName = draft.takenMedicationName;
    final hasSelection = draft.hasMedication;

    return InkWell(
      onTap: () => _openSheet(context, ref, meds),
      borderRadius: BorderRadius.circular(AuraRadius.md),
      child: Container(
        padding: const EdgeInsets.all(AuraSpacing.lg),
        decoration: BoxDecoration(
          color: AuraColors.bgRaised,
          border: Border.all(color: hasSelection ? AuraColors.accent : AuraColors.border),
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
                style: TextStyle(
                  color: AuraColors.accent,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AuraSpacing.md),
            Expanded(
              child: Text(
                hasSelection ? (selectedName ?? 'Medicação') : 'Nenhuma medicação',
                style: AuraTextStyles.body.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: hasSelection ? AuraColors.textPrimary : AuraColors.textMuted,
                ),
              ),
            ),
            Text(
              hasSelection ? 'Mudar' : 'Adicionar',
              style: AuraTextStyles.caption.copyWith(
                color: AuraColors.accent,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openSheet(BuildContext context, WidgetRef ref, List<Medication> meds) {
    final notifier = ref.read(crisisDraftProvider.notifier);
    final draft = ref.read(crisisDraftProvider);
    final selectedId = draft.takenMedicationId;
    final selectedName = draft.takenMedicationName;

    // Presets the user hasn't already added to their catalog (case-insensitive).
    final catalogNames = meds.map((m) => m.name.toLowerCase()).toSet();
    final presets = CommonMedications.sosPresets
        .where((p) => !catalogNames.contains(p.toLowerCase()))
        .toList();

    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AuraColors.bgRaised,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AuraRadius.xl)),
      ),
      builder: (sheetContext) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AuraSpacing.xl, 0, AuraSpacing.xl, AuraSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Medicação tomada', style: AuraTextStyles.screenTitle),
              const SizedBox(height: AuraSpacing.lg),
              _Option(
                label: 'Nada tomado',
                selected: !draft.hasMedication,
                onTap: () {
                  notifier.clearMedication();
                  Navigator.of(sheetContext).pop();
                },
              ),
              for (final m in meds)
                _Option(
                  label: _label(m.name, m.doseMg),
                  kind: MedicationKind.fromCode(m.kind),
                  selected: selectedId == m.id,
                  onTap: () {
                    notifier.selectCatalogMedication(id: m.id, name: m.name, doseMg: m.doseMg);
                    Navigator.of(sheetContext).pop();
                  },
                ),
              for (final p in presets)
                _Option(
                  label: p,
                  kind: MedicationKind.sos,
                  selected: selectedId == null && selectedName == p,
                  onTap: () {
                    notifier.selectPresetMedication(p);
                    Navigator.of(sheetContext).pop();
                  },
                ),
              const SizedBox(height: AuraSpacing.xs),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const MedicationEditScreen(),
                      fullscreenDialog: true,
                    ),
                  );
                },
                icon: const Icon(Icons.add, size: 20, color: AuraColors.accent),
                label: const Text('Adicionar outra', style: TextStyle(color: AuraColors.accent)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _label(String name, double? doseMg) {
    if (doseMg == null) return name;
    final dose = doseMg == doseMg.roundToDouble() ? doseMg.toStringAsFixed(0) : doseMg.toString();
    return '$name · $dose mg';
  }
}

class _Option extends StatelessWidget {
  const _Option({required this.label, required this.selected, required this.onTap, this.kind});

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final MedicationKind? kind;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AuraSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AuraRadius.md),
        child: Container(
          constraints: const BoxConstraints(minHeight: AuraSpacing.tapTargetMin),
          padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.lg, vertical: AuraSpacing.md),
          decoration: BoxDecoration(
            color: selected ? AuraColors.accentBg : AuraColors.bgElevated,
            border: Border.all(color: selected ? AuraColors.accent : AuraColors.border),
            borderRadius: BorderRadius.circular(AuraRadius.md),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                size: 20,
                color: selected ? AuraColors.accent : AuraColors.textMuted,
              ),
              const SizedBox(width: AuraSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: AuraTextStyles.body.copyWith(
                    fontSize: 14,
                    color: selected ? AuraColors.textPrimary : AuraColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (kind != null) _KindTag(kind: kind!),
            ],
          ),
        ),
      ),
    );
  }
}

class _KindTag extends StatelessWidget {
  const _KindTag({required this.kind});

  final MedicationKind kind;

  @override
  Widget build(BuildContext context) {
    final color = kind == MedicationKind.sos ? AuraColors.intensityHigh : AuraColors.intensityLow;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AuraRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        kind.labelPt,
        style: AuraTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
