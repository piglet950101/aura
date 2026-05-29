// Verifies ReportData's computed clinical stats.

import 'package:aura/domain/report/report_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ReportData build() {
    final dayA = DateTime(2026, 5, 28, 9);
    final dayB = DateTime(2026, 5, 25, 14);
    return ReportData(
      start: DateTime(2026, 4, 30),
      end: DateTime(2026, 5, 30),
      generatedAt: DateTime(2026, 5, 29, 12),
      patientName: 'Marta',
      birthYear: 1990,
      crises: [
        ReportCrisis(
          occurredAt: dayA,
          intensity: 7, // forte
          symptomCodes: const ['aura', 'nausea'],
          medications: const [
            ReportMedication(name: 'Sumatriptano', kind: 'sos', response: 'total'),
          ],
        ),
        ReportCrisis(
          occurredAt: dayB,
          intensity: 4, // moderada
          symptomCodes: const ['nausea'],
          medications: const [
            ReportMedication(name: 'Ibuprofeno', kind: 'sos', response: 'partial'),
          ],
        ),
        ReportCrisis(
          occurredAt: dayB.add(const Duration(hours: 2)),
          intensity: 2, // leve, same calendar day as B
          symptomCodes: const [],
          medications: const [],
        ),
      ],
    );
  }

  test('period + age', () {
    final d = build();
    expect(d.periodDays, 30);
    expect(d.age, 36);
  });

  test('counts and intensity buckets (by distinct day)', () {
    final d = build();
    expect(d.totalCrises, 3);
    expect(d.affectedDays, 2);
    expect(d.daysNoPain, 28);
    expect(d.daysForte, 1);
    expect(d.daysModerada, 1);
    expect(d.daysLeve, 1);
    expect(d.averageIntensity, closeTo((7 + 4 + 2) / 3, 1e-9));
  });

  test('SOS days count distinct days with an acute med', () {
    expect(build().sosDays, 2);
  });

  test('symptom frequency, most frequent first', () {
    final freq = build().symptomFrequency;
    expect(freq.first.key.code, 'nausea');
    expect(freq.first.value, 2);
    expect(freq.map((e) => e.key.code), containsAll(<String>['nausea', 'aura']));
  });

  test('medication usage with response breakdown', () {
    final usage = {for (final u in build().medicationUsage) u.name: u};
    expect(usage['Sumatriptano']!.times, 1);
    expect(usage['Sumatriptano']!.total, 1);
    expect(usage['Ibuprofeno']!.partial, 1);
  });

  test('empty period', () {
    final d = ReportData(
      start: DateTime(2026, 4, 30),
      end: DateTime(2026, 5, 30),
      generatedAt: DateTime(2026, 5, 29),
      crises: const [],
    );
    expect(d.isEmpty, isTrue);
    expect(d.daysNoPain, 30);
    expect(d.averageIntensity, isNull);
    expect(d.age, isNull);
  });
}
