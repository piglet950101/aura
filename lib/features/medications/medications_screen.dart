import 'package:aura/core/theme/aura_colors.dart';
import 'package:aura/core/theme/aura_radius.dart';
import 'package:aura/core/theme/aura_spacing.dart';
import 'package:aura/core/theme/aura_text_styles.dart';
import 'package:aura/data/local/database.dart';
import 'package:aura/domain/medication/medication_kind.dart';
import 'package:aura/domain/medication/preventive_subtype.dart';
import 'package:aura/features/medications/medication_edit_screen.dart';
import 'package:aura/features/medications/medications_providers.dart';
import 'package:aura/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Medication catalog list. Reached from the home "Medicação" quick action.
/// Default medication first, then alphabetical. Tap a row to edit; the bottom
/// bar adds a new one.
class MedicationsScreen extends ConsumerWidget {
  const MedicationsScreen({super.key});

  void _openEditor(BuildContext context, {Medication? existing}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MedicationEditScreen(existing: existing),
        fullscreenDialog: existing == null,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final medsAsync = ref.watch(activeMedicationsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l.back,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(l.medication, style: AuraTextStyles.screenTitle),
        centerTitle: false,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: medsAsync.when(
                data: (meds) => meds.isEmpty
                    ? const _EmptyState()
                    : _MedicationsList(
                        meds: meds,
                        onEdit: (m) => _openEditor(context, existing: m),
                      ),
                loading: () => const Center(
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AuraColors.accent),
                  ),
                ),
                error: (e, _) => _ErrorCard(message: l.medsLoadError('$e')),
              ),
            ),
            _AddBar(onAdd: () => _openEditor(context)),
          ],
        ),
      ),
    );
  }
}

/// Groups the active catalog into Preventiva + SOS sections per Marcelo's
/// mockup. Empty sections are omitted to avoid showing dead headers.
class _MedicationsList extends StatelessWidget {
  const _MedicationsList({required this.meds, required this.onEdit});

  final List<Medication> meds;
  final void Function(Medication) onEdit;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final preventive = <Medication>[];
    final sos = <Medication>[];
    final ended = <Medication>[];
    for (final m in meds) {
      if (m.endedAt != null) {
        ended.add(m);
      } else if (m.kind == MedicationKind.preventive.code) {
        preventive.add(m);
      } else {
        sos.add(m);
      }
    }
    // History: most-recently-ended first.
    ended.sort((a, b) => (b.endedAt ?? b.updatedAt).compareTo(a.endedAt ?? a.updatedAt));

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AuraSpacing.xl,
        AuraSpacing.lg,
        AuraSpacing.xl,
        AuraSpacing.lg,
      ),
      children: [
        if (preventive.isNotEmpty) ...[
          _SectionLabel(l.sectionMedPreventive),
          for (final m in preventive)
            Padding(
              padding: const EdgeInsets.only(bottom: AuraSpacing.sm),
              child: _MedicationTile(med: m, onTap: () => onEdit(m)),
            ),
          const SizedBox(height: AuraSpacing.lg),
        ],
        if (sos.isNotEmpty) ...[
          _SectionLabel(l.sectionMedSos),
          for (final m in sos)
            Padding(
              padding: const EdgeInsets.only(bottom: AuraSpacing.sm),
              child: _MedicationTile(med: m, onTap: () => onEdit(m)),
            ),
          const SizedBox(height: AuraSpacing.lg),
        ],
        if (ended.isNotEmpty) ...[
          _SectionLabel(l.sectionMedEnded),
          for (final m in ended)
            Padding(
              padding: const EdgeInsets.only(bottom: AuraSpacing.sm),
              child: _MedicationTile(med: m, onTap: () => onEdit(m), dim: true),
            ),
        ],
      ],
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

class _MedicationTile extends StatelessWidget {
  const _MedicationTile({required this.med, required this.onTap, this.dim = false});

  final Medication med;
  final VoidCallback onTap;

  /// Faded styling for ended-treatment history rows.
  final bool dim;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final localeName = Localizations.localeOf(context).toString();
    final shortDateFmt = DateFormat.yMMMd(localeName);
    final dose = med.doseMg != null
        ? ' · ${med.doseMg == med.doseMg!.roundToDouble() ? med.doseMg!.toStringAsFixed(0) : med.doseMg}'
              ' mg'
        : '';
    final isPreventive = med.kind == MedicationKind.preventive.code;
    final subtype = isPreventive
        ? (PreventiveSubtype.fromCode(med.preventiveSubtype) ?? PreventiveSubtype.pill)
        : null;
    final mins = med.reminderMinutes;

    // Build the small second-line "Diariamente · 18:00" or
    // "Mensal · próx. 7 jun" or "Desde 2 jan" / "Terminado em 3 mar".
    String? scheduleText;
    IconData? scheduleIcon;
    if (med.endedAt != null) {
      scheduleText = l.treatmentEndedOn(shortDateFmt.format(med.endedAt!));
      scheduleIcon = Icons.event_busy_outlined;
    } else if (subtype == PreventiveSubtype.pill && mins != null) {
      scheduleText = l.reminderAt(
        MaterialLocalizations.of(
          context,
        ).formatTimeOfDay(TimeOfDay(hour: mins ~/ 60, minute: mins % 60)),
      );
      scheduleIcon = Icons.alarm;
    } else if (subtype == PreventiveSubtype.injection &&
        med.injectionPeriodDays != null &&
        med.startedAt != null) {
      final period = InjectionPeriod.fromDays(med.injectionPeriodDays);
      final periodLabel = period == InjectionPeriod.monthly ? l.periodMonthly : l.periodQuarterly;
      // Next injection = start + n*period after now.
      final start = med.startedAt!;
      final periodDays = med.injectionPeriodDays!;
      var next = start;
      final now = DateTime.now();
      while (!next.isAfter(now)) {
        next = next.add(Duration(days: periodDays));
      }
      scheduleText = l.injectionScheduleLabel(periodLabel, shortDateFmt.format(next));
      scheduleIcon = Icons.event_repeat;
    } else if (med.startedAt != null) {
      scheduleText = l.treatmentStartedOn(shortDateFmt.format(med.startedAt!));
      scheduleIcon = Icons.flag_outlined;
    }
    final titleColor = dim ? AuraColors.textMuted : AuraColors.textPrimary;
    final scheduleColor = dim ? AuraColors.textMuted : AuraColors.accent;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AuraRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AuraSpacing.lg),
        decoration: BoxDecoration(
          color: AuraColors.bgRaised,
          border: Border.all(color: AuraColors.border),
          borderRadius: BorderRadius.circular(AuraRadius.lg),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AuraColors.accentBg,
                borderRadius: BorderRadius.circular(AuraRadius.sm),
              ),
              alignment: Alignment.center,
              child: Text(
                '℞',
                style: TextStyle(
                  color: dim ? AuraColors.textMuted : AuraColors.accent,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AuraSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          '${med.name}$dose',
                          style: AuraTextStyles.body.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: titleColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (med.isDefault) ...[
                        const SizedBox(width: AuraSpacing.sm),
                        Icon(Icons.star, size: 15, color: scheduleColor),
                      ],
                    ],
                  ),
                  if (scheduleText != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(scheduleIcon, size: 13, color: scheduleColor),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            scheduleText,
                            style: AuraTextStyles.caption.copyWith(
                              color: scheduleColor,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AuraColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AuraSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.medication_outlined, size: 40, color: AuraColors.textMuted),
            const SizedBox(height: AuraSpacing.lg),
            Text(
              l.noMedications,
              style: AuraTextStyles.screenTitle.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AuraSpacing.sm),
            Text(l.noMedicationsBody, style: AuraTextStyles.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AuraSpacing.xl),
        child: Text(
          message,
          style: AuraTextStyles.bodySmall.copyWith(color: AuraColors.error),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _AddBar extends StatelessWidget {
  const _AddBar({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AuraSpacing.xl,
        AuraSpacing.md,
        AuraSpacing.xl,
        AuraSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: AuraColors.bgBase,
        border: Border(top: BorderSide(color: AuraColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AuraColors.accent,
            foregroundColor: AuraColors.bgBase,
            minimumSize: const Size.fromHeight(AuraSpacing.tapTargetMin),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AuraRadius.lg)),
            elevation: 0,
          ),
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 20),
          label: Text(
            l.addMedication,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3),
          ),
        ),
      ),
    );
  }
}
