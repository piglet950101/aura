import 'package:aura/core/theme/aura_colors.dart';
import 'package:aura/core/theme/aura_radius.dart';
import 'package:aura/core/theme/aura_spacing.dart';
import 'package:aura/core/theme/aura_text_styles.dart';
import 'package:aura/domain/calendar/month_overview.dart';
import 'package:aura/domain/crisis/crisis_summary.dart';
import 'package:aura/features/calendar/calendar_providers.dart';
import 'package:aura/features/crisis/crisis_registration_screen.dart';
import 'package:aura/l10n/app_l10n.dart';
import 'package:aura/l10n/l10n_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Monthly calendar with per-day intensity heat.
///
/// Reached from the home "Calendário" quick action. Each day cell is tinted
/// by the worst crisis intensity that day (leve/moderada/forte), matching the
/// home summary buckets. Tapping a day opens a sheet with that day's crises or
/// an empty state with a "register for this day" affordance. Colours are kept
/// low-alpha on purpose — the persona has photophobia, so no harsh fills.
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  void _shiftMonth(WidgetRef ref, int delta) {
    final m = ref.read(calendarMonthProvider);
    ref.read(calendarMonthProvider.notifier).state = DateTime(m.year, m.month + delta);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final localeName = Localizations.localeOf(context).toString();
    // Monday-first short weekday labels for the current locale. 2024-09-02 is a
    // Monday, so adding 0..6 days walks Mon→Sun.
    final weekdayDf = DateFormat.E(localeName);
    final monday = DateTime(2024, 9, 2);
    final weekdayLabels = [
      for (var i = 0; i < 7; i++) weekdayDf.format(monday.add(Duration(days: i))),
    ];
    final month = ref.watch(calendarMonthProvider);
    final overviewAsync = ref.watch(monthOverviewProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l.back,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(l.calendar, style: AuraTextStyles.screenTitle),
        centerTitle: false,
      ),
      body: SafeArea(
        top: false,
        child: GestureDetector(
          onHorizontalDragEnd: (details) {
            final v = details.primaryVelocity ?? 0;
            if (v > 120) {
              _shiftMonth(ref, -1); // swipe right → previous month
            } else if (v < -120) {
              _shiftMonth(ref, 1); // swipe left → next month
            }
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AuraSpacing.xl,
              AuraSpacing.md,
              AuraSpacing.xl,
              AuraSpacing.xxl,
            ),
            children: [
              _MonthHeader(
                month: month,
                onPrev: () => _shiftMonth(ref, -1),
                onNext: () => _shiftMonth(ref, 1),
              ),
              const SizedBox(height: AuraSpacing.lg),
              overviewAsync.when(
                data: (overview) => Column(
                  children: [
                    _StatsStrip(overview: overview),
                    const SizedBox(height: AuraSpacing.xl),
                    _WeekdayHeader(labels: weekdayLabels),
                    const SizedBox(height: AuraSpacing.sm),
                    _MonthGrid(
                      overview: overview,
                      onDayTap: (date, load) => _showDaySheet(context, ref, date, load),
                    ),
                    const SizedBox(height: AuraSpacing.xl),
                    const _Legend(),
                    // CAM (Cefaleia por Abuso de Medicação) alert — fires
                    // when more than 10 SOS days are logged in the visible
                    // month. The threshold mirrors the clinical convention
                    // and the home-summary's red flag.
                    if (overview.sosDays > 10) ...[
                      const SizedBox(height: AuraSpacing.xl),
                      _CamAlertCard(sosDays: overview.sosDays),
                    ],
                  ],
                ),
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: AuraSpacing.xxxl),
                  child: Center(
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AuraColors.accent),
                    ),
                  ),
                ),
                error: (e, _) => _ErrorCard(message: l.calendarLoadError('$e')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDaySheet(BuildContext context, WidgetRef ref, DateTime date, DayLoad? load) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AuraColors.bgRaised,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AuraRadius.xl)),
      ),
      builder: (sheetContext) => _DaySheet(
        date: date,
        load: load,
        onRegister: () {
          Navigator.of(sheetContext).pop();
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CrisisRegistrationScreen(initialDate: date),
              fullscreenDialog: true,
            ),
          );
        },
        onEdit: (crisisId) {
          Navigator.of(sheetContext).pop();
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CrisisRegistrationScreen(editCrisisId: crisisId),
              fullscreenDialog: true,
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Month header — ‹ Maio 2026 ›
// ---------------------------------------------------------------------------

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({required this.month, required this.onPrev, required this.onNext});

  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final localeName = Localizations.localeOf(context).toString();
    final raw = DateFormat('MMMM yyyy', localeName).format(month);
    final label = raw.isEmpty ? raw : '${raw[0].toUpperCase()}${raw.substring(1)}';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          tooltip: l.monthPrev,
          icon: const Icon(Icons.chevron_left, color: AuraColors.textSecondary),
          onPressed: onPrev,
        ),
        Text(label, style: AuraTextStyles.screenTitle.copyWith(fontSize: 20)),
        IconButton(
          tooltip: l.monthNext,
          icon: const Icon(Icons.chevron_right, color: AuraColors.textSecondary),
          onPressed: onNext,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Stats strip — crises · intensidade média · dias afetados
// ---------------------------------------------------------------------------

class _StatsStrip extends StatelessWidget {
  const _StatsStrip({required this.overview});

  final MonthOverview overview;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final localeName = Localizations.localeOf(context).toString();
    final avg = overview.averageIntensity;
    final avgText = avg == null ? '—' : NumberFormat('0.0', localeName).format(avg);
    return Row(
      children: [
        Expanded(
          child: _StatTile(value: '${overview.totalCrises}', label: l.statCrises),
        ),
        const SizedBox(width: AuraSpacing.sm),
        Expanded(
          child: _StatTile(value: avgText, label: l.statAvgIntensity),
        ),
        const SizedBox(width: AuraSpacing.sm),
        Expanded(
          child: _StatTile(
            value: '${overview.affectedDays}/${overview.daysInMonth}',
            label: l.statAffectedDays,
            // 15 affected days/month is the chronic-migraine threshold (ICHD
            // criterion 1.3 for "chronic migraine"). Client asked for a red
            // flag so the user knows when they cross the line.
            danger: overview.affectedDays >= 15,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label, this.danger = false});

  final String value;
  final String label;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AuraColors.error : AuraColors.textPrimary;
    final borderColor = danger ? AuraColors.error : AuraColors.border;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AuraSpacing.md, horizontal: AuraSpacing.sm),
      decoration: BoxDecoration(
        color: AuraColors.bgRaised,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(AuraRadius.lg),
      ),
      child: Column(
        children: [
          Text(value, style: AuraTextStyles.numeric.copyWith(fontSize: 20, color: color)),
          const SizedBox(height: AuraSpacing.xs),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AuraTextStyles.caption.copyWith(
              color: danger ? AuraColors.error : null,
              fontWeight: danger ? FontWeight.w700 : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Weekday header row
// ---------------------------------------------------------------------------

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final l in labels)
          Expanded(
            child: Center(
              child: Text(
                l,
                style: AuraTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Month grid
// ---------------------------------------------------------------------------

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({required this.overview, required this.onDayTap});

  final MonthOverview overview;
  final void Function(DateTime date, DayLoad? load) onDayTap;

  @override
  Widget build(BuildContext context) {
    final month = overview.month;
    final daysInMonth = overview.daysInMonth;
    // DateTime.weekday: Mon=1..Sun=7 → leading blanks for a Monday-first grid.
    final leadingBlanks = DateTime(month.year, month.month).weekday - 1;
    final cellCount = leadingBlanks + daysInMonth;
    final rows = (cellCount / 7).ceil();
    final totalCells = rows * 7;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final cells = <Widget>[];
    for (var i = 0; i < totalCells; i++) {
      final dayNum = i - leadingBlanks + 1;
      if (dayNum < 1 || dayNum > daysInMonth) {
        cells.add(const SizedBox.shrink());
        continue;
      }
      final date = DateTime(month.year, month.month, dayNum);
      final load = overview.dayOf(dayNum);
      cells.add(
        _DayCell(
          dayNum: dayNum,
          tier: load?.tier ?? IntensityTier.none,
          count: load?.count ?? 0,
          hasAura: load?.hasAura ?? false,
          hasSos: load?.hasSosMedication ?? false,
          isToday: date == today,
          onTap: () => onDayTap(date, load),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AuraSpacing.xs,
      crossAxisSpacing: AuraSpacing.xs,
      children: cells,
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.dayNum,
    required this.tier,
    required this.count,
    required this.hasAura,
    required this.hasSos,
    required this.isToday,
    required this.onTap,
  });

  final int dayNum;
  final IntensityTier tier;
  final int count;
  final bool hasAura;
  final bool hasSos;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final heat = tierColor(tier);
    final filled = tier != IntensityTier.none;
    final semantics = filled
        ? '${l.daySemantic(dayNum)}, ${l.crisesCount(count)}${hasAura ? l.withAura : ''}'
        : l.daySemantic(dayNum);
    return Semantics(
      button: true,
      label: semantics,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AuraRadius.md),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: filled ? heat.withValues(alpha: 0.20) : Colors.transparent,
                borderRadius: BorderRadius.circular(AuraRadius.md),
                border: Border.all(
                  color: isToday
                      ? AuraColors.accent
                      : (filled ? heat.withValues(alpha: 0.55) : AuraColors.border),
                  width: isToday ? 1.5 : 1,
                ),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$dayNum',
                    style: AuraTextStyles.bodySmall.copyWith(
                      fontSize: 14,
                      color: filled ? AuraColors.textPrimary : AuraColors.textMuted,
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  if (count > 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '×$count',
                        style: AuraTextStyles.caption.copyWith(color: heat, fontSize: 9),
                      ),
                    ),
                ],
              ),
            ),
            if (hasAura)
              const Positioned(top: 2, right: 3, child: Text('✨', style: TextStyle(fontSize: 9))),
            // Pill icon at the bottom-left when the day logged any SOS-kind
            // medication. Per the client mockup, the icon stays small enough
            // to leave room for the dayNum + ×count text.
            if (hasSos)
              const Positioned(
                bottom: 2,
                left: 3,
                child: Icon(Icons.medication_outlined, size: 11, color: AuraColors.intensityHigh),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CAM (Cefaleia por Abuso de Medicação) alert
// ---------------------------------------------------------------------------

class _CamAlertCard extends StatelessWidget {
  const _CamAlertCard({required this.sosDays});

  final int sosDays;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return Container(
      padding: const EdgeInsets.all(AuraSpacing.lg),
      decoration: BoxDecoration(
        color: AuraColors.error.withValues(alpha: 0.08),
        border: Border.all(color: AuraColors.error),
        borderRadius: BorderRadius.circular(AuraRadius.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: AuraColors.error, size: 22),
          const SizedBox(width: AuraSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.camAlertTitle,
                  style: AuraTextStyles.body.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AuraColors.error,
                  ),
                ),
                const SizedBox(height: 4),
                Text(l.camAlertBody(sosDays), style: AuraTextStyles.caption.copyWith(height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Legend
// ---------------------------------------------------------------------------

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return Wrap(
      spacing: AuraSpacing.lg,
      runSpacing: AuraSpacing.sm,
      alignment: WrapAlignment.center,
      children: [
        _LegendItem(color: tierColor(IntensityTier.low), label: l.legendLeve),
        _LegendItem(color: tierColor(IntensityTier.med), label: l.legendModerada),
        _LegendItem(color: tierColor(IntensityTier.high), label: l.legendForte),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AuraSpacing.xs),
        Text(label, style: AuraTextStyles.caption),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Day detail sheet
// ---------------------------------------------------------------------------

class _DaySheet extends StatelessWidget {
  const _DaySheet({
    required this.date,
    required this.load,
    required this.onRegister,
    required this.onEdit,
  });

  final DateTime date;
  final DayLoad? load;
  final VoidCallback onRegister;
  final void Function(String crisisId) onEdit;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final localeName = Localizations.localeOf(context).toString();
    final now = DateTime.now();
    final isFuture = date.isAfter(DateTime(now.year, now.month, now.day));
    final titleRaw = DateFormat.MMMMEEEEd(localeName).format(date);
    final title = titleRaw.isEmpty
        ? titleRaw
        : '${titleRaw[0].toUpperCase()}${titleRaw.substring(1)}';
    final crises = load?.crises ?? const <CrisisSummary>[];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AuraSpacing.xl, 0, AuraSpacing.xl, AuraSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: AuraTextStyles.screenTitle.copyWith(fontSize: 18)),
            const SizedBox(height: AuraSpacing.lg),
            if (crises.isEmpty)
              Text(isFuture ? l.dayFuture : l.noCrisesThisDay, style: AuraTextStyles.bodySmall)
            else
              ...crises.map((c) => _CrisisRow(crisis: c, onTap: () => onEdit(c.id))),
            if (!isFuture) ...[
              const SizedBox(height: AuraSpacing.xl),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(AuraSpacing.tapTargetMin),
                  side: const BorderSide(color: AuraColors.accent),
                  foregroundColor: AuraColors.accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AuraRadius.lg)),
                ),
                onPressed: onRegister,
                icon: const Icon(Icons.add, size: 20),
                label: Text(l.registerForThisDay),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CrisisRow extends StatelessWidget {
  const _CrisisRow({required this.crisis, required this.onTap});

  final CrisisSummary crisis;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final localeName = Localizations.localeOf(context).toString();
    final tier = IntensityTier.fromIntensity(crisis.intensity);
    final time = DateFormat.Hm(localeName).format(crisis.occurredAt);
    return Padding(
      padding: const EdgeInsets.only(bottom: AuraSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AuraRadius.md),
        child: Container(
          padding: const EdgeInsets.all(AuraSpacing.md),
          decoration: BoxDecoration(
            color: AuraColors.bgElevated,
            borderRadius: BorderRadius.circular(AuraRadius.md),
            border: Border.all(color: AuraColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: tierColor(tier), shape: BoxShape.circle),
              ),
              const SizedBox(width: AuraSpacing.md),
              Expanded(
                child: Text(
                  '${l.intensityValue(crisis.intensity)} · ${tierLabel(l, tier)}'
                  '${crisis.hasAura ? ' · ${l.auraTag} ✨' : ''}',
                  style: AuraTextStyles.body.copyWith(fontSize: 14),
                ),
              ),
              Text(time, style: AuraTextStyles.bodySmall.copyWith(color: AuraColors.textMuted)),
              const SizedBox(width: AuraSpacing.sm),
              const Icon(Icons.chevron_right, size: 18, color: AuraColors.textMuted),
            ],
          ),
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
    return Container(
      margin: const EdgeInsets.only(top: AuraSpacing.xl),
      padding: const EdgeInsets.all(AuraSpacing.lg),
      decoration: BoxDecoration(
        color: AuraColors.bgRaised,
        border: Border.all(color: AuraColors.error),
        borderRadius: BorderRadius.circular(AuraRadius.lg),
      ),
      child: Text(message, style: AuraTextStyles.bodySmall.copyWith(color: AuraColors.error)),
    );
  }
}

// ---------------------------------------------------------------------------
// Tier → presentation helpers (presentation layer; tokens live in AuraColors)
// ---------------------------------------------------------------------------

Color tierColor(IntensityTier tier) {
  switch (tier) {
    case IntensityTier.none:
      return AuraColors.textDisabled;
    case IntensityTier.low:
      return AuraColors.intensityLow;
    case IntensityTier.med:
      return AuraColors.intensityMed;
    case IntensityTier.high:
      return AuraColors.intensityHigh;
  }
}
