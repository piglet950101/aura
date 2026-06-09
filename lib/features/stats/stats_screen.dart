import 'package:aura/core/theme/aura_colors.dart';
import 'package:aura/core/theme/aura_radius.dart';
import 'package:aura/core/theme/aura_spacing.dart';
import 'package:aura/core/theme/aura_text_styles.dart';
import 'package:aura/data/entitlement/entitlement_service_provider.dart';
import 'package:aura/domain/entitlement/entitlement.dart';
import 'package:aura/domain/hit6/hit6.dart';
import 'package:aura/domain/report/report_data.dart';
import 'package:aura/features/hit6/hit6_providers.dart';
import 'package:aura/features/paywall/paywall_screen.dart';
import 'package:aura/features/stats/stats_providers.dart';
import 'package:aura/l10n/app_l10n.dart';
import 'package:aura/l10n/l10n_labels.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Estatísticas (formerly Dados). Redesigned per the client's final spec:
/// 5-period selector at the top (30d / 60d / 90d / 6m / 1a), Dias Afetados
/// as the primary number, plus five sections — Evolução, Padrões,
/// Tratamento, Severidade, Eventos.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final days = ref.watch(statsPeriodDaysProvider);
    final dataAsync = ref.watch(statsDataProvider);
    final hit6Async = ref.watch(latestHit6Provider);
    final hit6HistoryAsync = ref.watch(hit6HistoryProvider);

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
              _PeriodSelector(
                current: days,
                onChange: (d) => ref.read(statsPeriodDaysProvider.notifier).state = d,
              ),
              const SizedBox(height: AuraSpacing.lg),
              _StatsRow(data: data, hit6: hit6Async.valueOrNull),
              if (data.sosDays >= 10) ...[
                const SizedBox(height: AuraSpacing.md),
                _SosOveruseChip(sosDays: data.sosDays),
              ],

              // 1) Evolução e impacto
              const SizedBox(height: AuraSpacing.xl),
              _SectionLabel(l.sectionEvolutionImpact),
              _Hit6EvolutionCard(history: hit6HistoryAsync.valueOrNull ?? const []),
              const SizedBox(height: AuraSpacing.md),
              _ChartCard(
                title: l.sectionCrisesPerWeek,
                child: _WeeklyChart(data: data),
              ),

              // 2) Padrões
              const SizedBox(height: AuraSpacing.xl),
              _SectionLabel(l.sectionPatterns),
              _ChartCard(
                title: l.weekdayHeatTitle,
                child: _WeekdayHeatMap(data: data),
              ),

              // 3) Tratamento e eficácia
              const SizedBox(height: AuraSpacing.xl),
              _SectionLabel(l.sectionTreatment),
              _ChartCard(
                title: l.sosEfficacyTitle,
                child: _SosEfficacyBars(data: data),
              ),

              // 4) Severidade
              const SizedBox(height: AuraSpacing.xl),
              _SectionLabel(l.sectionSeverity),
              _ChartCard(
                title: l.sectionIntensityDays,
                child: _IntensityBars(data: data),
              ),
              if (data.symptomFrequency.isNotEmpty) ...[
                const SizedBox(height: AuraSpacing.md),
                _ChartCard(
                  title: l.sectionFrequentSymptoms,
                  child: _SymptomBars(data: data),
                ),
              ],

              // 5) Eventos específicos — aura timeline + menstruation correlation
              const SizedBox(height: AuraSpacing.xl),
              _SectionLabel(l.sectionEvents),
              _ChartCard(
                title: l.auraTimelineTitle,
                child: _AuraTimeline(data: data),
              ),
              if (data.daysWithMenstruation > 0) ...[
                const SizedBox(height: AuraSpacing.md),
                _MenstruationCorrelationCard(data: data),
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

/// Period selector. The 180d/365d chips are premium — tapping them on a
/// free account opens the paywall; if the user converts, the tapped period
/// is applied immediately. The 30d/60d/90d chips are free.
class _PeriodSelector extends ConsumerWidget {
  const _PeriodSelector({required this.current, required this.onChange});

  final int current;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final entitled = ref
        .watch(entitlementStatusProvider)
        .valueOrNull
        ?.allows(PremiumFeature.extendedStats);
    final isPremium = entitled ?? false;
    final options = <(int, String, bool)>[
      (30, l.period30, false),
      (60, l.period60, false),
      (90, l.period90, false),
      (180, l.period6m, true),
      (365, l.period1y, true),
    ];

    Future<void> handleTap(int days, {required bool gated}) async {
      if (gated && !isPremium) {
        final unlocked = await PaywallScreen.push(context);
        if (!unlocked) return;
      }
      onChange(days);
    }

    return Row(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          Expanded(
            child: _PeriodChip(
              label: options[i].$2,
              selected: current == options[i].$1,
              locked: options[i].$3 && !isPremium,
              onTap: () => handleTap(options[i].$1, gated: options[i].$3),
            ),
          ),
          if (i < options.length - 1) const SizedBox(width: AuraSpacing.xs),
        ],
      ],
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.locked = false,
  });

  final String label;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AuraRadius.md),
      child: Container(
        constraints: const BoxConstraints(minHeight: 40),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AuraColors.accentBg : AuraColors.bgRaised,
          border: Border.all(color: selected ? AuraColors.accent : AuraColors.border),
          borderRadius: BorderRadius.circular(AuraRadius.md),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (locked) ...[
              const Icon(Icons.lock_outline, size: 12, color: AuraColors.textMuted),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AuraTextStyles.bodySmall.copyWith(
                color: locked
                    ? AuraColors.textMuted
                    : (selected ? AuraColors.accent : AuraColors.textSecondary),
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.data, required this.hit6});

  final ReportData data;
  final Hit6Submission? hit6;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final localeName = Localizations.localeOf(context).toString();
    final avg = data.averageIntensity;
    return Row(
      children: [
        _Tile(value: '${data.affectedDays}', label: l.statAffectedDays),
        const SizedBox(width: AuraSpacing.sm),
        _Tile(value: '${data.totalCrises}', label: l.statCrises),
        const SizedBox(width: AuraSpacing.sm),
        _Tile(
          value: avg == null ? '—' : NumberFormat('0.0', localeName).format(avg),
          label: l.statIntensity,
        ),
        const SizedBox(width: AuraSpacing.sm),
        _Tile(value: '${data.sosDays}', label: l.statDiasSos, danger: data.sosDays >= 10),
        const SizedBox(width: AuraSpacing.sm),
        _Tile(
          value: hit6?.score.toString() ?? '—',
          label: l.statHit6,
          danger: (hit6?.score ?? 0) >= 60,
        ),
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
          border: Border.all(color: danger ? AuraColors.error : AuraColors.border),
          borderRadius: BorderRadius.circular(AuraRadius.lg),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AuraTextStyles.numeric.copyWith(
                fontSize: 17,
                color: danger ? AuraColors.error : AuraColors.textPrimary,
              ),
            ),
            const SizedBox(height: AuraSpacing.xs),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AuraTextStyles.caption.copyWith(
                color: danger ? AuraColors.error : null,
                fontSize: 10,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _SosOveruseChip extends StatelessWidget {
  const _SosOveruseChip({required this.sosDays});
  final int sosDays;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.md, vertical: AuraSpacing.sm),
      decoration: BoxDecoration(
        color: AuraColors.error.withValues(alpha: 0.08),
        border: Border.all(color: AuraColors.error),
        borderRadius: BorderRadius.circular(AuraRadius.md),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AuraColors.error, size: 18),
          const SizedBox(width: AuraSpacing.sm),
          Expanded(
            child: Text(
              l.camAlertBody(sosDays),
              style: AuraTextStyles.caption.copyWith(color: AuraColors.error, height: 1.4),
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

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AuraSpacing.lg),
      decoration: BoxDecoration(
        color: AuraColors.bgRaised,
        border: Border.all(color: AuraColors.border),
        borderRadius: BorderRadius.circular(AuraRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AuraTextStyles.body.copyWith(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AuraSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _Hit6EvolutionCard extends StatelessWidget {
  const _Hit6EvolutionCard({required this.history});
  final List<Hit6Submission> history;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    if (history.isEmpty) {
      return _ChartCard(
        title: l.hit6CardTitle,
        child: Text(l.statHit6None, style: AuraTextStyles.caption),
      );
    }
    final latest = history.last;
    return _ChartCard(
      title: '${l.hit6CardTitle} · ${l.hit6ScoreLabel(latest.score)}',
      child: SizedBox(
        height: 110,
        child: LineChart(
          LineChartData(
            minY: 36,
            maxY: 78,
            titlesData: const FlTitlesData(show: false),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: [
                  for (var i = 0; i < history.length; i++)
                    FlSpot(i.toDouble(), history[i].score.toDouble()),
                ],
                color: AuraColors.accent,
                barWidth: 2.5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeekdayHeatMap extends StatelessWidget {
  const _WeekdayHeatMap({required this.data});
  final ReportData data;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final byWeekday = data.intensityByWeekday;
    final maxValue = byWeekday.values.fold<double>(0, (m, v) => v > m ? v : m);
    if (maxValue == 0) {
      return Text(l.weekdayHeatNoData, style: AuraTextStyles.caption);
    }
    final localeName = Localizations.localeOf(context).toString();
    final shortDf = DateFormat.E(localeName);
    final monday = DateTime(2024, 9, 2);
    final labels = [for (var i = 0; i < 7; i++) shortDf.format(monday.add(Duration(days: i)))];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < 7; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: _HeatCell(label: labels[i], value: byWeekday[i + 1] ?? 0, maxValue: maxValue),
            ),
          ),
      ],
    );
  }
}

class _HeatCell extends StatelessWidget {
  const _HeatCell({required this.label, required this.value, required this.maxValue});
  final String label;
  final double value;
  final double maxValue;

  @override
  Widget build(BuildContext context) {
    final ratio = maxValue == 0 ? 0.0 : (value / maxValue).clamp(0.0, 1.0);
    final color = _color(value, ratio);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AuraRadius.sm),
          ),
          child: value == 0
              ? null
              : Text(
                  value.toStringAsFixed(1),
                  style: AuraTextStyles.caption.copyWith(
                    fontSize: 10,
                    color: ratio > 0.5 ? AuraColors.bgBase : AuraColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
        const SizedBox(height: 4),
        Text(label, style: AuraTextStyles.caption.copyWith(fontSize: 10)),
      ],
    );
  }

  Color _color(double value, double ratio) {
    if (value == 0) return AuraColors.bgElevated;
    if (value <= 3) return AuraColors.intensityLow.withValues(alpha: 0.35 + ratio * 0.6);
    if (value <= 6) return AuraColors.intensityMed.withValues(alpha: 0.35 + ratio * 0.6);
    return AuraColors.intensityHigh.withValues(alpha: 0.35 + ratio * 0.6);
  }
}

class _SosEfficacyBars extends StatelessWidget {
  const _SosEfficacyBars({required this.data});
  final ReportData data;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final byName = <String, _Eff>{};
    for (final c in data.crises) {
      for (final m in c.medications) {
        if (m.kind != 'sos') continue;
        final e = byName.putIfAbsent(m.name, _Eff.new);
        e.total++;
        switch (m.response) {
          case 'total':
            e.totalResp++;
          case 'partial':
            e.partial++;
          case 'none':
            e.none++;
        }
      }
    }
    if (byName.isEmpty) {
      return Text(l.respNone, style: AuraTextStyles.caption);
    }
    final entries = byName.entries.toList()..sort((a, b) => b.value.total.compareTo(a.value.total));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in entries.take(5))
          Padding(
            padding: const EdgeInsets.only(bottom: AuraSpacing.sm),
            child: _SosEfficacyRow(name: entry.key, eff: entry.value, l: l),
          ),
      ],
    );
  }
}

class _Eff {
  int total = 0;
  int totalResp = 0;
  int partial = 0;
  int none = 0;
}

class _SosEfficacyRow extends StatelessWidget {
  const _SosEfficacyRow({required this.name, required this.eff, required this.l});
  final String name;
  final _Eff eff;
  final AppL10n l;

  @override
  Widget build(BuildContext context) {
    final total = eff.total;
    final totalFlex = eff.totalResp.clamp(0, total);
    final partialFlex = eff.partial.clamp(0, total);
    final noneFlex = eff.none.clamp(0, total);
    final remainder = total - totalFlex - partialFlex - noneFlex;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '$name (${eff.total})',
                style: AuraTextStyles.caption.copyWith(fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ),
            if (eff.none > 0)
              Text(
                '${l.respNoneShort}: ${eff.none}',
                style: AuraTextStyles.caption.copyWith(
                  color: AuraColors.error,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 10,
          child: Row(
            children: [
              if (totalFlex > 0)
                Expanded(
                  flex: totalFlex,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AuraColors.intensityLow,
                      borderRadius: BorderRadius.circular(AuraRadius.sm),
                    ),
                  ),
                ),
              if (partialFlex > 0) ...[
                if (totalFlex > 0) const SizedBox(width: 2),
                Expanded(
                  flex: partialFlex,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AuraColors.intensityMed,
                      borderRadius: BorderRadius.circular(AuraRadius.sm),
                    ),
                  ),
                ),
              ],
              if (noneFlex > 0) ...[
                if (totalFlex + partialFlex > 0) const SizedBox(width: 2),
                Expanded(
                  flex: noneFlex,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AuraColors.error,
                      borderRadius: BorderRadius.circular(AuraRadius.sm),
                    ),
                  ),
                ),
              ],
              if (remainder > 0) Expanded(flex: remainder, child: const SizedBox.shrink()),
            ],
          ),
        ),
      ],
    );
  }
}

class _AuraTimeline extends StatelessWidget {
  const _AuraTimeline({required this.data});
  final ReportData data;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final auras = data.crises.where((c) => c.hasAura).toList();
    if (auras.isEmpty) {
      return Text(l.auraTimelineNone, style: AuraTextStyles.caption);
    }
    final localeName = Localizations.localeOf(context).toString();
    final df = DateFormat.MMMd(localeName);
    return Wrap(
      spacing: AuraSpacing.xs,
      runSpacing: AuraSpacing.xs,
      children: [
        for (final c in auras)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.sm, vertical: 2),
            decoration: BoxDecoration(
              color: AuraColors.accentBg,
              border: Border.all(color: AuraColors.accent.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(AuraRadius.pill),
            ),
            child: Text(
              '✨ ${df.format(c.occurredAt)}',
              style: AuraTextStyles.caption.copyWith(color: AuraColors.accent, fontSize: 11),
            ),
          ),
      ],
    );
  }
}

class _MenstruationCorrelationCard extends StatelessWidget {
  const _MenstruationCorrelationCard({required this.data});
  final ReportData data;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final menstrualCrises = data.crises.where((c) => c.menstruation ?? false).length;
    final percent = data.totalCrises == 0
        ? 0
        : ((menstrualCrises / data.totalCrises) * 100).round();
    return Container(
      padding: const EdgeInsets.all(AuraSpacing.lg),
      decoration: BoxDecoration(
        color: AuraColors.bgRaised,
        border: Border.all(color: AuraColors.border),
        borderRadius: BorderRadius.circular(AuraRadius.lg),
      ),
      child: Row(
        children: [
          const Icon(Icons.water_drop_outlined, color: AuraColors.accent),
          const SizedBox(width: AuraSpacing.md),
          Expanded(
            child: Text(
              l.menstruationCorrelation(percent),
              style: AuraTextStyles.caption.copyWith(height: 1.4),
            ),
          ),
        ],
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
    return SizedBox(
      height: 140,
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
                    width: weeks.length > 7 ? 6 : 14,
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
            width: 110,
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
