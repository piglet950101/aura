// Verifies MonthOverview aggregation: day binning, per-day tier (max
// intensity), month stats (count / average / affected days), and that
// crises outside the target month are excluded.

import 'package:aura/domain/calendar/month_overview.dart';
import 'package:aura/domain/crisis/crisis_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  CrisisSummary c(String id, DateTime when, int intensity) =>
      CrisisSummary(id: id, occurredAt: when, intensity: intensity);

  test('empty month has no crises and a null average', () {
    final o = MonthOverview.empty(DateTime(2026, 5));
    expect(o.isEmpty, isTrue);
    expect(o.totalCrises, 0);
    expect(o.affectedDays, 0);
    expect(o.averageIntensity, isNull);
    expect(o.daysInMonth, 31);
    expect(o.affectedRatio, 0);
    expect(o.dayOf(15), isNull);
  });

  test('IntensityTier mirrors the home buckets', () {
    expect(IntensityTier.fromIntensity(0), IntensityTier.none);
    expect(IntensityTier.fromIntensity(1), IntensityTier.low);
    expect(IntensityTier.fromIntensity(3), IntensityTier.low);
    expect(IntensityTier.fromIntensity(4), IntensityTier.med);
    expect(IntensityTier.fromIntensity(6), IntensityTier.med);
    expect(IntensityTier.fromIntensity(7), IntensityTier.high);
    expect(IntensityTier.fromIntensity(10), IntensityTier.high);
  });

  test('bins crises by local day and tiers by worst intensity of the day', () {
    final o = MonthOverview.fromCrises(
      month: DateTime(2026, 5),
      crises: [
        c('a', DateTime(2026, 5, 10, 9), 2), // leve
        c('b', DateTime(2026, 5, 10, 21), 8), // forte — should win the tier
        c('c', DateTime(2026, 5, 12, 14), 5), // moderada
      ],
    );

    expect(o.dayOf(10), isNotNull);
    expect(o.dayOf(10)!.count, 2);
    expect(o.dayOf(10)!.maxIntensity, 8);
    expect(o.dayOf(10)!.tier, IntensityTier.high);

    expect(o.dayOf(12)!.tier, IntensityTier.med);
    expect(o.dayOf(11), isNull);
  });

  test('crises within a day are sorted ascending by time', () {
    final o = MonthOverview.fromCrises(
      month: DateTime(2026, 5),
      crises: [c('late', DateTime(2026, 5, 10, 21), 8), c('early', DateTime(2026, 5, 10, 9), 2)],
    );
    final day = o.dayOf(10)!;
    expect(day.crises.map((e) => e.id).toList(), ['early', 'late']);
  });

  test('stats: total crises, affected days, average intensity', () {
    final o = MonthOverview.fromCrises(
      month: DateTime(2026, 5),
      crises: [
        c('a', DateTime(2026, 5, 10, 9), 2),
        c('b', DateTime(2026, 5, 10, 21), 8),
        c('c', DateTime(2026, 5, 12, 14), 5),
      ],
    );
    expect(o.totalCrises, 3);
    expect(o.affectedDays, 2); // days 10 and 12
    expect(o.averageIntensity, closeTo((2 + 8 + 5) / 3, 1e-9));
    expect(o.affectedRatio, closeTo(2 / 31, 1e-9));
    expect(o.isEmpty, isFalse);
  });

  test('crises outside the target month are excluded', () {
    final o = MonthOverview.fromCrises(
      month: DateTime(2026, 5),
      crises: [
        c('prev', DateTime(2026, 4, 30, 23), 9), // April
        c('in', DateTime(2026, 5, 1, 0, 30), 4), // May 1
        c('next', DateTime(2026, 6, 1, 0, 30), 9), // June
      ],
    );
    expect(o.totalCrises, 1);
    expect(o.dayOf(1)!.tier, IntensityTier.med);
  });

  test('daysInMonth handles leap February', () {
    expect(MonthOverview.empty(DateTime(2024, 2)).daysInMonth, 29);
    expect(MonthOverview.empty(DateTime(2026, 2)).daysInMonth, 28);
  });
}
