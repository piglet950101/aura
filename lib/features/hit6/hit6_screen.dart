import 'package:aura/core/theme/aura_colors.dart';
import 'package:aura/core/theme/aura_radius.dart';
import 'package:aura/core/theme/aura_spacing.dart';
import 'package:aura/core/theme/aura_text_styles.dart';
import 'package:aura/domain/hit6/hit6.dart';
import 'package:aura/features/hit6/hit6_providers.dart';
import 'package:aura/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// HIT-6 (Headache Impact Test) questionnaire screen. Six questions, one
/// answer each from the standard five-option scale. Saves when the user
/// taps the final answer on Q6; pops back to Preparar Consulta with the
/// new score available.
class Hit6Screen extends ConsumerStatefulWidget {
  const Hit6Screen({super.key});

  @override
  ConsumerState<Hit6Screen> createState() => _Hit6ScreenState();
}

class _Hit6ScreenState extends ConsumerState<Hit6Screen> {
  final _answers = <Hit6Answer?>[null, null, null, null, null, null];
  bool _saving = false;

  bool get _isComplete => _answers.every((a) => a != null);

  Future<void> _submit() async {
    if (!_isComplete || _saving) return;
    final l = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _saving = true);
    try {
      await ref.read(hit6RepositoryProvider).submit(_answers.cast<Hit6Answer>());
      // Refresh anything that watches the latest / history.
      ref
        ..invalidate(latestHit6Provider)
        ..invalidate(hit6HistoryProvider);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(l.hit6Submitted),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      navigator.pop();
    } on Object catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l.saveError(e))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final questions = [
      l.hit6Q1,
      l.hit6Q2,
      l.hit6Q3,
      l.hit6Q4,
      l.hit6Q5,
      l.hit6Q6,
    ];
    final answerLabels = {
      Hit6Answer.never: l.hit6Never,
      Hit6Answer.rarely: l.hit6Rarely,
      Hit6Answer.sometimes: l.hit6Sometimes,
      Hit6Answer.veryOften: l.hit6VeryOften,
      Hit6Answer.always: l.hit6Always,
    };

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: l.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(l.hit6Title, style: AuraTextStyles.screenTitle),
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
                    Text(l.hit6Intro, style: AuraTextStyles.bodySmall),
                    const SizedBox(height: AuraSpacing.xl),
                    for (var i = 0; i < 6; i++) ...[
                      _QuestionBlock(
                        number: i + 1,
                        question: questions[i],
                        answers: answerLabels,
                        selected: _answers[i],
                        onPick: (a) => setState(() => _answers[i] = a),
                      ),
                      const SizedBox(height: AuraSpacing.xl),
                    ],
                  ],
                ),
              ),
            ),
            _SaveBar(
              enabled: _isComplete && !_saving,
              saving: _saving,
              onSave: _submit,
              label: l.hit6Submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionBlock extends StatelessWidget {
  const _QuestionBlock({
    required this.number,
    required this.question,
    required this.answers,
    required this.selected,
    required this.onPick,
  });

  final int number;
  final String question;
  final Map<Hit6Answer, String> answers;
  final Hit6Answer? selected;
  final ValueChanged<Hit6Answer> onPick;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return Container(
      padding: const EdgeInsets.all(AuraSpacing.lg),
      decoration: BoxDecoration(
        color: AuraColors.bgRaised,
        border: Border.all(color: AuraColors.border),
        borderRadius: BorderRadius.circular(AuraRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.hit6QuestionLabel(number),
            style: AuraTextStyles.caption.copyWith(
              color: AuraColors.accent,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AuraSpacing.xs),
          Text(
            question,
            style: AuraTextStyles.body.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AuraSpacing.md),
          for (final entry in answers.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: AuraSpacing.sm),
              child: _AnswerOption(
                label: entry.value,
                selected: selected == entry.key,
                onTap: () => onPick(entry.key),
              ),
            ),
        ],
      ),
    );
  }
}

class _AnswerOption extends StatelessWidget {
  const _AnswerOption({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({
    required this.enabled,
    required this.saving,
    required this.onSave,
    required this.label,
  });

  final bool enabled;
  final bool saving;
  final VoidCallback onSave;
  final String label;

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
              : Text(
                  label,
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
