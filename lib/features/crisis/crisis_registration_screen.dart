import 'dart:async';

import 'package:aura/core/theme/aura_colors.dart';
import 'package:aura/core/theme/aura_radius.dart';
import 'package:aura/core/theme/aura_spacing.dart';
import 'package:aura/core/theme/aura_text_styles.dart';
import 'package:aura/data/local/database_provider.dart';
import 'package:aura/domain/crisis/symptom.dart';
import 'package:aura/features/crisis/crisis_registration_controller.dart';
import 'package:aura/features/crisis/widgets/aura_toggle.dart';
import 'package:aura/features/crisis/widgets/intensity_picker.dart';
import 'package:aura/features/crisis/widgets/medication_picker.dart';
import 'package:aura/features/crisis/widgets/symptom_chips.dart';
import 'package:aura/features/settings/settings_providers.dart';
import 'package:aura/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The heart of the product: register a crisis in 3 taps, ≤ 15 seconds.
///
/// Layout principles, codified:
///   - Save CTA pinned to the bottom inside the safe area, always thumb-
///     reachable. Disabled until intensity is chosen.
///   - Scrollable body so a tall device shows everything, a short device
///     scrolls without resizing the CTA.
///   - All interactive elements ≥ 56dp.
///   - No animations on selection beyond a 120ms color/scale tween — the
///     persona has photophobia; flashy state changes hurt.
class CrisisRegistrationScreen extends ConsumerStatefulWidget {
  const CrisisRegistrationScreen({this.initialDate, this.editCrisisId, super.key});

  /// When set (e.g. from the calendar's "Registar para este dia"), the crisis
  /// is back-dated to this day at local noon instead of defaulting to NOW.
  final DateTime? initialDate;

  /// When set, the screen edits this existing crisis instead of creating one:
  /// the form is pre-filled from the DB and saving updates in place.
  final String? editCrisisId;

  @override
  ConsumerState<CrisisRegistrationScreen> createState() => _CrisisRegistrationScreenState();
}

class _CrisisRegistrationScreenState extends ConsumerState<CrisisRegistrationScreen> {
  bool _saving = false;
  final _notesController = TextEditingController();

  bool get _isEdit => widget.editCrisisId != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isEdit) {
        unawaited(_hydrate(widget.editCrisisId!));
      } else {
        // Reset the draft on every fresh open so the previous registration's
        // values don't ghost the next one. If opened for a specific day, seed
        // the occurrence date to local noon of that day.
        final notifier = ref.read(crisisDraftProvider.notifier)..reset();
        _notesController.clear();
        final d = widget.initialDate;
        if (d != null) {
          notifier.setOccurredAt(DateTime(d.year, d.month, d.day, 12));
        }
      }
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _hydrate(String crisisId) async {
    final db = ref.read(auraDatabaseProvider);
    final crisis = await db.findCrisis(crisisId);
    if (crisis == null) return;
    final symptomCodes = await db.symptomsFor(crisisId);
    final meds = await db.crisisMedicationsFor(crisisId);
    final med = meds.isNotEmpty ? meds.first : null;
    if (!mounted) return;
    ref
        .read(crisisDraftProvider.notifier)
        .hydrate(
          occurredAt: crisis.occurredAt,
          intensity: crisis.intensity,
          symptoms: symptomCodes.map(Symptom.fromCode).whereType<Symptom>().toSet(),
          notes: crisis.notes,
          medicationId: med?.medicationId,
          medicationName: med?.medicationNameSnapshot,
          medicationDoseMg: med?.doseMg,
          menstruation: crisis.menstruation,
        );
    _notesController.text = crisis.notes ?? '';
  }

  Future<void> _onSave() async {
    if (_saving) return;
    final l = AppL10n.of(context);
    setState(() => _saving = true);
    try {
      final draft = ref.read(crisisDraftProvider);
      final useCase = ref.read(registerCrisisUseCaseProvider);
      if (_isEdit) {
        await useCase.update(crisisId: widget.editCrisisId!, draft: draft);
      } else {
        await useCase.register(draft: draft);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit ? l.crisisUpdated : l.crisisSaved),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.saveError(e))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _onDelete() async {
    final crisisId = widget.editCrisisId;
    if (crisisId == null) return;
    final l = AppL10n.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AuraColors.bgElevated,
        title: Text(l.deleteCrisisTitle, style: AuraTextStyles.screenTitle),
        content: Text(l.deleteCrisisBody, style: AuraTextStyles.bodySmall),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l.cancel)),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.delete, style: const TextStyle(color: AuraColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(registerCrisisUseCaseProvider).delete(crisisId: crisisId);
      if (!mounted) return;
      Navigator.of(context).pop();
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.deleteError(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final draft = ref.watch(crisisDraftProvider);
    final notifier = ref.read(crisisDraftProvider.notifier);
    // Conditional render of the Menstruação question, per the client's spec:
    // only show when the user's profile says feminino. Older crises edited
    // post-fact stay editable through draft.menstruation regardless, so we
    // never lose data captured before a profile change.
    final profile = ref.watch(profileProvider).valueOrNull;
    final showMenstruation = profile?.sex == 'f' || draft.menstruation != null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: l.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(_isEdit ? l.editCrisis : l.newCrisis, style: AuraTextStyles.screenTitle),
        centerTitle: false,
        actions: [
          if (_isEdit)
            IconButton(
              tooltip: l.delete,
              icon: const Icon(Icons.delete_outline, color: AuraColors.error),
              onPressed: _onDelete,
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AuraSpacing.xl,
                  AuraSpacing.lg,
                  AuraSpacing.xl,
                  AuraSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l.formIntro, style: AuraTextStyles.bodySmall),
                    const SizedBox(height: AuraSpacing.xl),

                    _SectionLabel(l.sectionIntensity),
                    IntensityPicker(value: draft.intensity, onChanged: notifier.setIntensity),
                    const SizedBox(height: AuraSpacing.xl),

                    _SectionLabel(l.sectionAura),
                    AuraToggle(
                      present: draft.symptoms.contains(Symptom.aura),
                      onChanged: (v) => notifier.setAura(present: v),
                    ),
                    const SizedBox(height: AuraSpacing.xl),

                    if (showMenstruation) ...[
                      _SectionLabel(l.sectionMenstruation),
                      AuraToggle(
                        present: draft.menstruation ?? false,
                        onChanged: (v) => notifier.setMenstruation(present: v),
                      ),
                      const SizedBox(height: AuraSpacing.xl),
                    ],

                    _SectionLabel(l.sectionSymptoms),
                    SymptomChips(
                      selected: draft.symptoms,
                      onToggle: notifier.toggleSymptom,
                      onClear: notifier.clearSymptoms,
                    ),
                    const SizedBox(height: AuraSpacing.xl),

                    _SectionLabel(l.sectionMedicationTaken),
                    const MedicationPicker(),
                    const SizedBox(height: AuraSpacing.xl),

                    _SectionLabel(l.sectionNotesOptional),
                    TextField(
                      controller: _notesController,
                      onChanged: notifier.setNotes,
                      maxLines: 3,
                      minLines: 2,
                      maxLength: 1000,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(hintText: l.notesHint),
                    ),
                    const SizedBox(height: AuraSpacing.xxl),
                  ],
                ),
              ),
            ),

            // Pinned bottom CTA, inside the safe area.
            _SaveBar(enabled: draft.isSaveable && !_saving, saving: _saving, onSave: _onSave),
          ],
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

class _SaveBar extends StatelessWidget {
  const _SaveBar({required this.enabled, required this.saving, required this.onSave});

  final bool enabled;
  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AuraSpacing.xl,
        AuraSpacing.md,
        AuraSpacing.xl,
        AuraSpacing.xl,
      ),
      decoration: const BoxDecoration(
        color: AuraColors.bgBase,
        border: Border(top: BorderSide(color: AuraColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AuraColors.accent,
            foregroundColor: AuraColors.bgBase,
            disabledBackgroundColor: AuraColors.bgElevated,
            disabledForegroundColor: AuraColors.textMuted,
            minimumSize: const Size.fromHeight(AuraSpacing.tapTargetMin),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AuraRadius.lg)),
          ),
          onPressed: enabled ? onSave : null,
          child: saving
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: AuraColors.bgBase),
                )
              : Text(
                  l.saveCrisis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }
}
