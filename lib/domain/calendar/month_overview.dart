import 'package:aura/domain/crisis/crisis_summary.dart';

/// Pain-intensity tier used to colour calendar day cells. Mirrors the home
/// dashboard buckets exactly (leve 1-3, moderada 4-6, forte 7-10) so a day's
/// heat colour on the calendar matches how it's counted in "Últimos 30 dias".
enum IntensityTier {
  none,
  low, // leve · 1-3
  med, // moderada · 4-6
  high; // forte · 7-10

  static IntensityTier fromIntensity(int intensity) {
    if (intensity <= 0) return IntensityTier.none;
    if (intensity <= 3) return IntensityTier.low;
    if (intensity <= 6) return IntensityTier.med;
    return IntensityTier.high;
  }
}

/// Everything the calendar needs to render one day cell + its detail sheet.
class DayLoad {
  const DayLoad({required this.date, required this.crises});

  /// Local midnight of this day.
  final DateTime date;

  /// Crises that occurred on this local calendar day, ascending by time.
  final List<CrisisSummary> crises;

  bool get hasCrisis => crises.isNotEmpty;
  int get count => crises.length;

  /// The worst pain of the day drives the heat colour.
  int get maxIntensity => crises.fold(0, (m, c) => c.intensity > m ? c.intensity : m);

  IntensityTier get tier =>
      hasCrisis ? IntensityTier.fromIntensity(maxIntensity) : IntensityTier.none;
}

/// Aggregated view of one month: per-day loads plus the header stat strip.
class MonthOverview {
  MonthOverview({required this.month, required Map<int, DayLoad> days}) : _days = days;

  factory MonthOverview.empty(DateTime month) =>
      MonthOverview(month: DateTime(month.year, month.month), days: const <int, DayLoad>{});

  /// Builds the overview from crises whose [CrisisSummary.occurredAt] is in
  /// local time. Crises outside [month] are ignored (the provider over-fetches
  /// by a day on each side to be timezone-safe, then this trims to the month).
  factory MonthOverview.fromCrises({required DateTime month, required List<CrisisSummary> crises}) {
    final first = DateTime(month.year, month.month);
    final next = DateTime(month.year, month.month + 1);

    final byDay = <int, List<CrisisSummary>>{};
    for (final c in crises) {
      final when = c.occurredAt;
      if (when.isBefore(first) || !when.isBefore(next)) continue;
      byDay.putIfAbsent(when.day, () => <CrisisSummary>[]).add(c);
    }

    final days = <int, DayLoad>{};
    byDay.forEach((day, list) {
      list.sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
      days[day] = DayLoad(date: DateTime(month.year, month.month, day), crises: list);
    });

    return MonthOverview(month: first, days: days);
  }

  /// First of the month, local time.
  final DateTime month;
  final Map<int, DayLoad> _days;

  /// Day-of-month → load, or null if that day had no crises.
  DayLoad? dayOf(int dayOfMonth) => _days[dayOfMonth];

  /// Number of days in this calendar month (handles leap Februaries).
  int get daysInMonth => DateTime(month.year, month.month + 1, 0).day;

  int get totalCrises => _days.values.fold(0, (s, d) => s + d.count);

  int get affectedDays => _days.values.where((d) => d.hasCrisis).length;

  /// Fraction of the month's days that had at least one crisis (0..1).
  double get affectedRatio => daysInMonth == 0 ? 0 : affectedDays / daysInMonth;

  /// Mean intensity across every crisis in the month, or null if none.
  double? get averageIntensity {
    final all = _days.values.expand((d) => d.crises).toList();
    if (all.isEmpty) return null;
    final sum = all.fold<int>(0, (s, c) => s + c.intensity);
    return sum / all.length;
  }

  bool get isEmpty => totalCrises == 0;
}
