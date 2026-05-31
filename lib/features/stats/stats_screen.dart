import 'package:aura/core/theme/aura_colors.dart';
import 'package:aura/core/theme/aura_radius.dart';
import 'package:aura/core/theme/aura_spacing.dart';
import 'package:aura/core/theme/aura_text_styles.dart';
import 'package:aura/domain/report/report_data.dart';
import 'package:aura/features/stats/stats_providers.dart';
import 'package:aura/l10n/app_l10n.dart';
import 'package:aura/l10n/l10n_labels.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// In-app statistics ("Dados"): key numbers + charts over a chosen period.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final days = ref.watch(statsPeriodDaysProvider);
    final dataAsync = ref.watch(statsDataProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l.back,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(l.statsTitle, style: AuraTextStyles.screenTitle),
        centerTitle: false,
      ),
      body: SafeArea(
        top: false,
        child: dataAsync.when(
          data: (data) => ListView(
            padding: const EdgeInsets.fromLTRB(
              AuraSpacing.xl,
              AuraSpacing.md,
              AuraSpacing.xl,
              AuraSpacing.xxl,
            ),
            children: [
              Row(
                children: [
                  _PeriodChip(
                    label: l.period30,
                    selected: days == 30,
                    onTap: () => ref.read(statsPeriodDaysProvider.notifier).state = 30,
                  ),
                  const SizedBox(width: AuraSpacing.sm),
                  _PeriodChip(
                    label: l.period90,
                    selected: days == 90,
                    onTap: () => ref.read(statsPeriodDaysProvider.notifier).state = 90,
                  ),
                ],
              ),
              const SizedBox(height: AuraSpacing.lg),
              _StatsRow(data: data),
              const SizedBox(height: AuraSpacing.xl),
              _SectionLabel(l.sectionCrisesPerWeek),
              _WeeklyChart(data: data),
              const SizedBox(height: AuraSpacing.xl),
              _SectionLabel(l.sectionIntensityDays),
              _IntensityBars(data: data),
              if (data.symptomFrequency.isNotEmpty) ...[
                const SizedBox(height: AuraSpacing.xl),
                _SectionLabel(l.sectionFrequentSymptoms),
                _SymptomBars(data: data),
              ],
            ],
          ),
          loading: () => const Center(
            child: SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: AuraColors.accent),
            ),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(AuraSpacing.xl),
            child: Text(
              l.statsError(e),
              style: AuraTextStyles.bodySmall.copyWith(color: AuraColors.error),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.data});
  final ReportData data;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final localeName = Localizations.localeOf(context).toString();
    final avg = data.averageIntensity;
    return Row(
      children: [
        _Tile(value: '${data.totalCrises}', label: l.statCrises),
        const SizedBox(width: AuraSpacing.sm),
        _Tile(value: '${data.affectedDays}', label: l.statAffectedDays),
        const SizedBox(width: AuraSpacing.sm),
        _Tile(
          value: avg == null ? '—' : NumberFormat('0.0', localeName).format(avg),
          label: l.statIntensity,
        ),
        const SizedBox(width: AuraSpacing.sm),
        _Tile(value: '${data.sosDays}', label: l.statDiasSos, danger: data.sosDays >= 10),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.value, required this.label, this.danger = false});
  final String value;
  final String label;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AuraSpacing.md, horizontal: AuraSpacing.xs),
        decoration: BoxDecoration(
          color: AuraColors.bgRaised,
          border: Border.all(color: danger ? AuraColors.intensityHigh : AuraColors.border),
          borderRadius: BorderRadius.circular(AuraRadius.lg),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AuraTextStyles.numeric.copyWith(
                fontSize: 18,
                color: danger ? AuraColors.intensityHigh : AuraColors.textPrimary,
              ),
            ),
            const SizedBox(height: AuraSpacing.xs),
            Text(label, textAlign: TextAlign.center, style: AuraTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.data});
  final ReportData data;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final weeks = data.crisesPerWeek;
    final maxCount = weeks.fold<int>(0, (m, v) => v > m ? v : m);
    final maxY = (maxCount + 1).toDouble();

    return Container(
      height: 180,
      padding: const EdgeInsets.fromLTRB(
        AuraSpacing.sm,
        AuraSpacing.lg,
        AuraSpacing.md,
        AuraSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AuraColors.bgRaised,
        border: Border.all(color: AuraColors.border),
        borderRadius: BorderRadius.circular(AuraRadius.lg),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(enabled: false),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (_) => const FlLine(color: AuraColors.border, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 24,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: AuraTextStyles.caption.copyWith(fontSize: 9),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= weeks.length) {
                    return const SizedBox.shrink();
                  }
                  // Avoid clutter for 90-day (13 weeks): label every other.
                  if (weeks.length > 7 && i.isOdd) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      l.weekShort(i + 1),
                      style: AuraTextStyles.caption.copyWith(fontSize: 9),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < weeks.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: weeks[i].toDouble(),
                    color: AuraColors.accent,
                    width: weeks.length > 7 ? 8 : 16,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _IntensityBars extends StatelessWidget {
  const _IntensityBars({required this.data});
  final ReportData data;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final max = data.periodDays;
    return Column(
      children: [
        _HBar(l.painNone, data.daysNoPain, max, AuraColors.textDisabled),
        _HBar(l.painLeve, data.daysLeve, max, AuraColors.intensityLow),
        _HBar(l.painModerada, data.daysModerada, max, AuraColors.intensityMed),
        _HBar(l.painForte, data.daysForte, max, AuraColors.intensityHigh),
      ],
    );
  }
}

class _SymptomBars extends StatelessWidget {
  const _SymptomBars({required this.data});
  final ReportData data;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final top = data.symptomFrequency.take(5).toList();
    final max = top.isEmpty ? 1 : top.first.value;
    return Column(
      children: [
        for (final e in top) _HBar(symptomLabel(l, e.key), e.value, max, AuraColors.accent),
      ],
    );
  }
}

class _HBar extends StatelessWidget {
  const _HBar(this.label, this.value, this.max, this.color);
  final String label;
  final int value;
  final int max;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final filled = max <= 0 ? 0 : value.clamp(0, max);
    final rest = max <= 0 ? 1 : (max - filled).clamp(0, max);
    return Padding(
      padding: const EdgeInsets.only(bottom: AuraSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AuraTextStyles.bodySmall.copyWith(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Row(
              children: [
                if (filled > 0)
                  Expanded(
                    flex: filled,
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(AuraRadius.sm),
                      ),
                    ),
                  ),
                if (rest > 0) Expanded(flex: rest, child: const SizedBox()),
              ],
            ),
          ),
          const SizedBox(width: AuraSpacing.sm),
          SizedBox(
            width: 22,
            child: Text(
              '$value',
              textAlign: TextAlign.right,
              style: AuraTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
        ],
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

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AuraRadius.md),
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AuraColors.accentBg : AuraColors.bgRaised,
            border: Border.all(color: selected ? AuraColors.accent : AuraColors.border),
            borderRadius: BorderRadius.circular(AuraRadius.md),
          ),
          child: Text(
            label,
            style: AuraTextStyles.bodySmall.copyWith(
              color: selected ? AuraColors.accent : AuraColors.textSecondary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
