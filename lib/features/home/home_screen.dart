import 'package:aura/core/theme/aura_colors.dart';
import 'package:aura/core/theme/aura_radius.dart';
import 'package:aura/core/theme/aura_spacing.dart';
import 'package:aura/core/theme/aura_text_styles.dart';
import 'package:aura/domain/home/home_stats.dart';
import 'package:aura/domain/medication/pending_medication_response.dart';
import 'package:aura/features/calendar/calendar_screen.dart';
import 'package:aura/features/crisis/crisis_registration_screen.dart';
import 'package:aura/features/home/home_stats_provider.dart';
import 'package:aura/features/medications/medication_response_providers.dart';
import 'package:aura/features/medications/medications_screen.dart';
import 'package:aura/features/report/report_screen.dart';
import 'package:aura/features/settings/settings_screen.dart';
import 'package:aura/features/stats/stats_screen.dart';
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
///   4. 3+2 button grid (Calendário · Partilhar · Medicação ;
///      Consulta Médica · Dados) — placeholders until later days.
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

  void _openReport(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ReportScreen()));
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
                          stats.isEmpty ? const _EmptyStateCard() : _SummaryList(stats: stats),
                      loading: () => const _SummarySkeleton(),
                      error: (e, _) => _ErrorCard(message: '$e'),
                    ),
                    const SizedBox(height: AuraSpacing.xl),
                    _QuickActionsGrid(
                      onCalendar: () => _openCalendar(context),
                      onShare: () => _openReport(context),
                      onMedication: () => _openMedications(context),
                      onAppointment: () => _openReport(context),
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
            tooltip: 'Definições',
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
    final dateFmt = DateFormat("d 'de' MMMM", 'pt_PT');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Olá',
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
    final pending = ref.watch(pendingMedicationResponseProvider).valueOrNull;
    if (pending == null) return const SizedBox.shrink();

    final time = DateFormat("d 'de' MMM 'às' HH:mm", 'pt_PT').format(pending.takenAt);
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
              'A medicação funcionou?',
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
                      child: Text(r.labelPt, style: const TextStyle(fontSize: 13)),
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
// Summary list (5 rows)
// ---------------------------------------------------------------------------

class _SummaryList extends StatelessWidget {
  const _SummaryList({required this.stats});

  final HomeStats stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: AuraSpacing.md),
          child: Text('ÚLTIMOS 30 DIAS', style: AuraTextStyles.sectionLabel),
        ),
        Container(
          decoration: BoxDecoration(
            color: AuraColors.bgRaised,
            border: Border.all(color: AuraColors.border),
            borderRadius: BorderRadius.circular(AuraRadius.lg),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.md),
          child: Column(
            children: [
              _SummaryRow(
                color: AuraColors.textDisabled,
                label: 'Sem dor de cabeça',
                count: stats.daysNoPain,
                unit: stats.daysNoPain == 1 ? 'dia' : 'dias',
                last: false,
              ),
              _SummaryRow(
                color: AuraColors.intensityLow,
                label: 'Dor leve',
                count: stats.daysLeve,
                unit: stats.daysLeve == 1 ? 'dia' : 'dias',
                last: false,
              ),
              _SummaryRow(
                color: AuraColors.intensityMed,
                label: 'Moderada',
                count: stats.daysModerada,
                unit: stats.daysModerada == 1 ? 'dia' : 'dias',
                last: false,
              ),
              _SummaryRow(
                color: AuraColors.intensityHigh,
                label: 'Forte',
                count: stats.daysForte,
                unit: stats.daysForte == 1 ? 'dia' : 'dias',
                last: false,
              ),
              _SummaryRow(
                color: AuraColors.accent,
                label: 'Tomou medicação',
                count: stats.daysWithMedication,
                unit: stats.daysWithMedication == 1 ? 'dia' : 'dias',
                last: false,
              ),
              _SummaryRow(
                color: AuraColors.intensityHigh,
                label: 'Medicação SOS',
                count: stats.daysWithSosMedication,
                unit: stats.daysWithSosMedication == 1 ? 'dia' : 'dias',
                last: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.color,
    required this.label,
    required this.count,
    required this.unit,
    required this.last,
  });

  final Color color;
  final String label;
  final int count;
  final String unit;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: last ? null : const Border(bottom: BorderSide(color: AuraColors.border)),
      ),
      padding: const EdgeInsets.symmetric(vertical: AuraSpacing.md, horizontal: AuraSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: color == AuraColors.textDisabled
                  ? null
                  : [BoxShadow(color: color.withValues(alpha: 0.45), blurRadius: 6)],
            ),
          ),
          const SizedBox(width: AuraSpacing.md),
          Expanded(
            child: Text(
              label,
              style: AuraTextStyles.body.copyWith(
                fontSize: 14,
                color: AuraColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          RichText(
            text: TextSpan(
              text: '$count',
              style: AuraTextStyles.numeric.copyWith(fontSize: 16),
              children: [
                TextSpan(
                  text: ' $unit',
                  style: AuraTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                    color: AuraColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
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
          Text('Bem-vindo', style: AuraTextStyles.screenTitle.copyWith(fontSize: 20)),
          const SizedBox(height: AuraSpacing.sm),
          Text(
            'Regista a tua primeira crise quando precisares. '
            'Os teus dados ficam neste dispositivo e na tua conta.',
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
        'Não foi possível carregar o resumo: $message',
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
    required this.onShare,
    required this.onMedication,
    required this.onAppointment,
    required this.onData,
  });

  final VoidCallback onCalendar;
  final VoidCallback onShare;
  final VoidCallback onMedication;
  final VoidCallback onAppointment;
  final VoidCallback onData;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _QuickButton(
                icon: Icons.calendar_month_outlined,
                label: 'Calendário',
                onTap: onCalendar,
              ),
            ),
            const SizedBox(width: AuraSpacing.sm),
            Expanded(
              child: _QuickButton(
                icon: Icons.ios_share_outlined,
                label: 'Partilhar',
                onTap: onShare,
              ),
            ),
            const SizedBox(width: AuraSpacing.sm),
            Expanded(
              child: _QuickButton(
                icon: Icons.medication_outlined,
                label: 'Medicação',
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
                label: 'Consulta Médica',
                onTap: onAppointment,
              ),
            ),
            const SizedBox(width: AuraSpacing.sm),
            Expanded(
              child: _QuickButton(icon: Icons.bar_chart_outlined, label: 'Dados', onTap: onData),
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
          label: const Text(
            'Registar crise',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3),
          ),
        ),
      ),
    );
  }
}
