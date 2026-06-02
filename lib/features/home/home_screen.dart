import 'package:aura/core/theme/aura_colors.dart';
import 'package:aura/core/theme/aura_radius.dart';
import 'package:aura/core/theme/aura_spacing.dart';
import 'package:aura/core/theme/aura_text_styles.dart';
import 'package:aura/domain/home/home_stats.dart';
import 'package:aura/domain/medication/pending_medication_response.dart';
import 'package:aura/features/appointments/appointments_screen.dart';
import 'package:aura/features/calendar/calendar_screen.dart';
import 'package:aura/features/crisis/crisis_registration_screen.dart';
import 'package:aura/features/home/home_stats_provider.dart';
import 'package:aura/features/medications/medication_response_providers.dart';
import 'package:aura/features/medications/medications_screen.dart';
import 'package:aura/features/settings/settings_screen.dart';
import 'package:aura/features/stats/stats_screen.dart';
import 'package:aura/l10n/app_l10n.dart';
import 'package:aura/l10n/l10n_labels.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// AURA home dashboard.
///
/// Lives on the root route. Layout, top to bottom:
///   1. Brand mark + settings cog
///   2. Greeting + today's date
///   3. "Últimos 30 dias" — five-row breakdown (no pain / leve / moderada
///      / forte / dias com medicação) computed reactively from Drift.
///   4. 2×2 button grid (Calendário · Medicação ; Consulta Médica · Dados).
///   5. Fixed bottom "Registar crise" CTA, always thumb-reachable.
///
/// Empty state (zero crises in the window) collapses the breakdown into
/// a welcoming card and makes the CTA even more prominent.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _openCrisisRegistration(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const CrisisRegistrationScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  void _openCalendar(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const CalendarScreen()));
  }

  void _openMedications(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const MedicationsScreen()));
  }

  void _openAppointments(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AppointmentsScreen()));
  }

  void _openStats(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const StatsScreen()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(homeStatsProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _TopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AuraSpacing.xl,
                  AuraSpacing.md,
                  AuraSpacing.xl,
                  AuraSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _Greeting(),
                    const SizedBox(height: AuraSpacing.xl),
                    const _MedicationResponsePrompt(),
                    statsAsync.when(
                      data: (stats) =>
                          stats.isEmpty ? const _EmptyStateCard() : _SummaryDonut(stats: stats),
                      loading: () => const _SummarySkeleton(),
                      error: (e, _) => _ErrorCard(message: '$e'),
                    ),
                    const SizedBox(height: AuraSpacing.xl),
                    _QuickActionsGrid(
                      onCalendar: () => _openCalendar(context),
                      onMedication: () => _openMedications(context),
                      onAppointment: () => _openAppointments(context),
                      onData: () => _openStats(context),
                    ),
                    const SizedBox(height: AuraSpacing.xxl),
                  ],
                ),
              ),
            ),
            _RegisterCrisisBar(onTap: () => _openCrisisRegistration(context)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Top bar — brand mark + settings cog
// ---------------------------------------------------------------------------

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AuraSpacing.xl,
        AuraSpacing.lg,
        AuraSpacing.lg,
        AuraSpacing.sm,
      ),
      child: Row(
        children: [
          Row(
            children: [
              const Text('AURA', style: AuraTextStyles.brand),
              const SizedBox(width: AuraSpacing.sm),
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(color: AuraColors.accent, shape: BoxShape.circle),
              ),
              const SizedBox(width: AuraSpacing.sm),
              Text(
                'diário',
                style: AuraTextStyles.bodySmall.copyWith(
                  color: AuraColors.textMuted,
                  letterSpacing: 1.2,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            tooltip: AppL10n.of(context).settings,
            icon: const Icon(Icons.settings_outlined, size: 22),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Greeting + date
// ---------------------------------------------------------------------------

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final dateFmt = DateFormat.MMMMd(locale);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppL10n.of(context).homeGreeting,
          style: AuraTextStyles.bodySmall.copyWith(color: AuraColors.textMuted, fontSize: 14),
        ),
        const SizedBox(height: 2),
        Text(
          dateFmt.format(DateTime.now()),
          style: AuraTextStyles.screenTitle.copyWith(fontSize: 22),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Medication response prompt (asked on reopen, >= 2h after a dose)
// ---------------------------------------------------------------------------

class _MedicationResponsePrompt extends ConsumerWidget {
  const _MedicationResponsePrompt();

  Future<void> _record(
    WidgetRef ref,
    PendingMedicationResponse pending,
    MedicationResponse response,
  ) async {
    await ref
        .read(medicationResponseRepositoryProvider)
        .record(pending: pending, response: response);
    ref.invalidate(pendingMedicationResponseProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final pending = ref.watch(pendingMedicationResponseProvider).valueOrNull;
    if (pending == null) return const SizedBox.shrink();

    final locale = Localizations.localeOf(context).toString();
    final time = DateFormat.MMMd(locale).add_Hm().format(pending.takenAt);
    return Padding(
      padding: const EdgeInsets.only(bottom: AuraSpacing.xl),
      child: Container(
        padding: const EdgeInsets.all(AuraSpacing.lg),
        decoration: BoxDecoration(
          color: AuraColors.bgRaised,
          border: Border.all(color: AuraColors.accent),
          borderRadius: BorderRadius.circular(AuraRadius.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.medicationWorkedTitle,
              style: AuraTextStyles.body.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text('${pending.medicationName} · $time', style: AuraTextStyles.caption),
            const SizedBox(height: AuraSpacing.md),
            Row(
              children: [
                for (final r in MedicationResponse.values) ...[
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AuraColors.accent,
                        side: const BorderSide(color: AuraColors.border),
                        padding: const EdgeInsets.symmetric(vertical: AuraSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AuraRadius.md),
                        ),
                      ),
                      onPressed: () => _record(ref, pending, r),
                      child: Text(
                        medicationResponseLabel(l, r),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                  if (r != MedicationResponse.values.last) const SizedBox(width: AuraSpacing.sm),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 30-day summary: donut (4 intensity tiers as the slices) over a 30-day window,
// with a count center and 2 highlight tiles below for the medication metrics
// (which can't go in the partition — a day with meds is also a day with pain).
// ---------------------------------------------------------------------------

class _SummaryDonut extends StatelessWidget {
  const _SummaryDonut({required this.stats});

  final HomeStats stats;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final tiers = <_Tier>[
      _Tier(AuraColors.textDisabled, l.painNone, stats.daysNoPain),
      _Tier(AuraColors.intensityLow, l.painLeve, stats.daysLeve),
      _Tier(AuraColors.intensityMed, l.painModerada, stats.daysModerada),
      _Tier(AuraColors.intensityHigh, l.painForte, stats.daysForte),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AuraSpacing.md),
          child: Text(l.last30Days.toUpperCase(), style: AuraTextStyles.sectionLabel),
        ),
        Container(
          padding: const EdgeInsets.all(AuraSpacing.lg),
          decoration: BoxDecoration(
            color: AuraColors.bgRaised,
            border: Border.all(color: AuraColors.border),
            borderRadius: BorderRadius.circular(AuraRadius.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 160,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 48,
                        startDegreeOffset: -90,
                        sections: [
                          for (final t in tiers)
                            PieChartSectionData(
                              value: t.count.toDouble(),
                              color: t.color,
                              radius: 22,
                              showTitle: false,
                            ),
                        ],
                      ),
                    ),
                    _DonutCenter(crises: stats.totalCrises),
                  ],
                ),
              ),
              const SizedBox(height: AuraSpacing.md),
              _DonutLegend(tiers: tiers),
              const SizedBox(height: AuraSpacing.lg),
              const Divider(height: 1, color: AuraColors.border),
              const SizedBox(height: AuraSpacing.sm),
              _MedicationRow(
                color: AuraColors.accent,
                label: l.medicationTaken,
                count: stats.daysWithMedication,
              ),
              // SOS days ≥ 10 flips the label + count to red, per the
              // Cefaleia por Abuso de Medicação threshold the client + the
              // ICHD criteria use (>10 acute doses/month is the warning line).
              _MedicationRow(
                color: AuraColors.intensityHigh,
                label: l.medicationSos,
                count: stats.daysWithSosMedication,
                danger: stats.daysWithSosMedication >= 10,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Tier {
  const _Tier(this.color, this.label, this.count);
  final Color color;
  final String label;
  final int count;
}

class _DonutCenter extends StatelessWidget {
  const _DonutCenter({required this.crises});

  final int crises;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('$crises', style: AuraTextStyles.numeric.copyWith(fontSize: 28, height: 1)),
        const SizedBox(height: 2),
        Text(
          l.statCrises.toLowerCase(),
          style: AuraTextStyles.caption.copyWith(color: AuraColors.textMuted, fontSize: 11),
        ),
      ],
    );
  }
}

class _DonutLegend extends StatelessWidget {
  const _DonutLegend({required this.tiers});

  final List<_Tier> tiers;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return Wrap(
      spacing: AuraSpacing.lg,
      runSpacing: AuraSpacing.xs,
      alignment: WrapAlignment.center,
      children: [
        for (final t in tiers)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(color: t.color, shape: BoxShape.circle),
              ),
              const SizedBox(width: AuraSpacing.xs),
              Text(
                '${t.label} · ${l.days(t.count)}',
                style: AuraTextStyles.caption.copyWith(fontSize: 11),
              ),
            ],
          ),
      ],
    );
  }
}

class _MedicationRow extends StatelessWidget {
  const _MedicationRow({
    required this.color,
    required this.label,
    required this.count,
    this.danger = false,
  });

  final Color color;
  final String label;
  final int count;

  /// When true, the label + day count flip to the error colour. The home uses
  /// this for SOS days ≥ 10 (Cefaleia por Abuso de Medicação threshold).
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final dotColor = danger ? AuraColors.error : color;
    final labelColor = danger ? AuraColors.error : AuraColors.textSecondary;
    final countColor = danger ? AuraColors.error : AuraColors.textPrimary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AuraSpacing.sm, horizontal: AuraSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: dotColor.withValues(alpha: 0.45), blurRadius: 6)],
            ),
          ),
          const SizedBox(width: AuraSpacing.md),
          Expanded(
            child: Text(
              label,
              style: AuraTextStyles.body.copyWith(
                fontSize: 14,
                color: labelColor,
                fontWeight: danger ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            AppL10n.of(context).days(count),
            style: AuraTextStyles.numeric.copyWith(fontSize: 15, color: countColor),
          ),
        ],
      ),
    );
  }
}

class _SummarySkeleton extends StatelessWidget {
  const _SummarySkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: AuraColors.bgRaised,
        border: Border.all(color: AuraColors.border),
        borderRadius: BorderRadius.circular(AuraRadius.lg),
      ),
      alignment: Alignment.center,
      child: const SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(strokeWidth: 2, color: AuraColors.accent),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AuraSpacing.xl),
      decoration: BoxDecoration(
        color: AuraColors.bgRaised,
        border: Border.all(color: AuraColors.border),
        borderRadius: BorderRadius.circular(AuraRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppL10n.of(context).welcomeTitle,
            style: AuraTextStyles.screenTitle.copyWith(fontSize: 20),
          ),
          const SizedBox(height: AuraSpacing.sm),
          Text(
            AppL10n.of(context).welcomeBody,
            style: AuraTextStyles.body.copyWith(
              fontSize: 14,
              color: AuraColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AuraSpacing.lg),
      decoration: BoxDecoration(
        color: AuraColors.bgRaised,
        border: Border.all(color: AuraColors.error),
        borderRadius: BorderRadius.circular(AuraRadius.lg),
      ),
      child: Text(
        AppL10n.of(context).summaryLoadError(message),
        style: AuraTextStyles.bodySmall.copyWith(color: AuraColors.error),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3+2 quick actions grid
// ---------------------------------------------------------------------------

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid({
    required this.onCalendar,
    required this.onMedication,
    required this.onAppointment,
    required this.onData,
  });

  final VoidCallback onCalendar;
  final VoidCallback onMedication;
  final VoidCallback onAppointment;
  final VoidCallback onData;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _QuickButton(
                icon: Icons.calendar_month_outlined,
                label: l.qaCalendar,
                onTap: onCalendar,
              ),
            ),
            const SizedBox(width: AuraSpacing.sm),
            Expanded(
              child: _QuickButton(
                icon: Icons.medication_outlined,
                label: l.qaMedication,
                onTap: onMedication,
              ),
            ),
          ],
        ),
        const SizedBox(height: AuraSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _QuickButton(
                icon: Icons.monitor_heart_outlined,
                label: l.qaAppointment,
                onTap: onAppointment,
              ),
            ),
            const SizedBox(width: AuraSpacing.sm),
            Expanded(
              child: _QuickButton(icon: Icons.bar_chart_outlined, label: l.qaData, onTap: onData),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickButton extends StatelessWidget {
  const _QuickButton({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AuraRadius.lg),
        child: Container(
          constraints: const BoxConstraints(minHeight: 84),
          padding: const EdgeInsets.symmetric(vertical: AuraSpacing.md, horizontal: AuraSpacing.sm),
          decoration: BoxDecoration(
            color: AuraColors.bgRaised,
            border: Border.all(color: AuraColors.border),
            borderRadius: BorderRadius.circular(AuraRadius.lg),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: AuraColors.accent),
              const SizedBox(height: AuraSpacing.sm),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AuraTextStyles.bodySmall.copyWith(
                  fontSize: 11,
                  color: AuraColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Fixed bottom "Registar crise" CTA
// ---------------------------------------------------------------------------

class _RegisterCrisisBar extends StatelessWidget {
  const _RegisterCrisisBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
          onPressed: onTap,
          icon: const Icon(Icons.add, size: 20),
          label: Text(
            AppL10n.of(context).registerCrisis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3),
          ),
        ),
      ),
    );
  }
}
