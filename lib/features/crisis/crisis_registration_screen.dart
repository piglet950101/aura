import 'package:aura/core/theme/aura_colors.dart';
import 'package:aura/core/theme/aura_radius.dart';
import 'package:aura/core/theme/aura_spacing.dart';
import 'package:aura/core/theme/aura_text_styles.dart';
import 'package:aura/features/crisis/crisis_registration_controller.dart';
import 'package:aura/features/crisis/widgets/intensity_picker.dart';
import 'package:aura/features/crisis/widgets/medication_picker.dart';
import 'package:aura/features/crisis/widgets/symptom_chips.dart';
import 'package:aura/features/crisis/widgets/trigger_chips.dart';
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
  const CrisisRegistrationScreen({this.initialDate, super.key});

  /// When set (e.g. from the calendar's "Registar para este dia"), the crisis
  /// is back-dated to this day at local noon instead of defaulting to NOW.
  final DateTime? initialDate;

  @override
  ConsumerState<CrisisRegistrationScreen> createState() => _CrisisRegistrationScreenState();
}

class _CrisisRegistrationScreenState extends ConsumerState<CrisisRegistrationScreen> {
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Reset the draft on every fresh open so the previous registration's
    // values don't ghost the next one. If opened for a specific day, seed
    // the occurrence date to local noon of that day.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(crisisDraftProvider.notifier)..reset();
      final d = widget.initialDate;
      if (d != null) {
        notifier.setOccurredAt(DateTime(d.year, d.month, d.day, 12));
      }
    });
  }

  Future<void> _onSave() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final draft = ref.read(crisisDraftProvider);
      final useCase = ref.read(registerCrisisUseCaseProvider);
      await useCase.register(draft: draft);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Crise registada'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao guardar: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(crisisDraftProvider);
    final notifier = ref.read(crisisDraftProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Cancelar',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Nova crise', style: AuraTextStyles.screenTitle),
        centerTitle: false,
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
                    const Text(
                      'Regista o essencial em poucos toques.',
                      style: AuraTextStyles.bodySmall,
                    ),
                    const SizedBox(height: AuraSpacing.xl),

                    const _SectionLabel('Intensidade da dor'),
                    IntensityPicker(value: draft.intensity, onChanged: notifier.setIntensity),
                    const SizedBox(height: AuraSpacing.xl),

                    const _SectionLabel('Sintomas'),
                    SymptomChips(selected: draft.symptoms, onToggle: notifier.toggleSymptom),
                    const SizedBox(height: AuraSpacing.xl),

                    const _SectionLabel('Gatilho mais provável'),
                    TriggerChips(selected: draft.trigger, onSelected: notifier.setTrigger),
                    const SizedBox(height: AuraSpacing.xl),

                    const _SectionLabel('Medicação tomada'),
                    const MedicationPicker(),
                    const SizedBox(height: AuraSpacing.xxxl),
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
              : const Text(
                  'Guardar crise',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3),
                ),
        ),
      ),
    );
  }
}
