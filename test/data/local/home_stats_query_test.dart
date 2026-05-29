// Verifies the `watchHomeStatsLast30Days` aggregation.
//
// Seeds a deterministic timeline of crises and asserts the bucket counts
// match. Also exercises the reactive contract: inserting a new crisis
// while the stream is subscribed produces a fresh emission.

import 'package:aura/data/local/database.dart';
import 'package:aura/domain/home/home_stats.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AuraDatabase db;

  setUp(() {
    db = AuraDatabase.test(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  const userId = 'user-marta';

  Future<void> seedCrisis(String id, DateTime when, int intensity) async {
    await db.insertCrisis(
      CrisesCompanion.insert(id: id, userId: userId, occurredAt: when, intensity: intensity),
    );
  }

  test('empty DB returns empty stats (30 no-pain days, 0 crises)', () async {
    final stream = db.watchHomeStatsLast30Days(userId: userId, now: DateTime(2026, 5, 27, 12));
    final stats = await stream.first;
    expect(stats.totalCrises, 0);
    expect(stats.daysNoPain, 30);
    expect(stats.daysLeve, 0);
    expect(stats.daysModerada, 0);
    expect(stats.daysForte, 0);
    expect(stats.daysWithMedication, 0);
    expect(stats.daysWithSosMedication, 0);
    expect(stats.isEmpty, isTrue);
  });

  test('intensity buckets count distinct calendar days', () async {
    final now = DateTime(2026, 5, 27, 12);

    // Day -3: two crises, one intensity 2 (leve), one intensity 7 (forte)
    await seedCrisis('a', DateTime(2026, 5, 24, 9), 2);
    await seedCrisis('b', DateTime(2026, 5, 24, 20), 7);
    // Day -1: intensity 5 (moderada)
    await seedCrisis('c', DateTime(2026, 5, 26, 14), 5);
    // Day 0 (today): intensity 9 (forte)
    await seedCrisis('d', DateTime(2026, 5, 27, 6), 9);
    // Older than 30-day window: should NOT count
    await seedCrisis('z', DateTime(2026, 4, 1, 12), 8);

    final stream = db.watchHomeStatsLast30Days(userId: userId, now: now);
    final stats = await stream.first;

    expect(stats.totalCrises, 4, reason: 'older-than-30d row excluded');
    expect(stats.daysLeve, 1, reason: 'one day had any leve crisis (day -3)');
    expect(stats.daysModerada, 1, reason: 'one day had any moderada (day -1)');
    expect(stats.daysForte, 2, reason: 'two days had any forte (day -3, day 0)');
    // 3 distinct calendar days had at least one crisis (-3, -1, 0)
    expect(stats.daysNoPain, 27);
    expect(stats.daysWithMedication, 0, reason: 'no crisis_medications yet');
  });

  test('only counts the active user — RLS proxy', () async {
    final now = DateTime(2026, 5, 27, 12);
    await seedCrisis('mine', DateTime(2026, 5, 26, 10), 5);
    // Crisis belonging to someone else.
    await db.insertCrisis(
      CrisesCompanion.insert(
        id: 'other',
        userId: 'someone-else',
        occurredAt: DateTime(2026, 5, 26, 11),
        intensity: 9,
      ),
    );

    final stats = await db.watchHomeStatsLast30Days(userId: userId, now: now).first;
    expect(stats.totalCrises, 1);
    expect(stats.daysModerada, 1);
    expect(stats.daysForte, 0);
  });

  test('SOS medication days count distinct days with an acute med taken', () async {
    final now = DateTime(2026, 5, 27, 12);

    await db
        .into(db.medications)
        .insert(
          MedicationsCompanion.insert(
            id: 'med-sos',
            userId: userId,
            name: 'Sumatriptano',
            kind: const Value('sos'),
          ),
        );
    await db
        .into(db.medications)
        .insert(
          MedicationsCompanion.insert(
            id: 'med-prev',
            userId: userId,
            name: 'Propranolol',
            kind: const Value('preventive'),
          ),
        );

    // Day -2: crisis with an SOS med → counts.
    await seedCrisis('c1', DateTime(2026, 5, 25, 9), 6);
    await db
        .into(db.crisisMedications)
        .insert(
          CrisisMedicationsCompanion.insert(
            id: 'cm1',
            crisisId: 'c1',
            medicationNameSnapshot: 'Sumatriptano',
            takenAt: DateTime(2026, 5, 25, 9),
            medicationId: const Value('med-sos'),
          ),
        );

    // Day -1: crisis with a preventive med only → NOT an SOS day.
    await seedCrisis('c2', DateTime(2026, 5, 26, 9), 5);
    await db
        .into(db.crisisMedications)
        .insert(
          CrisisMedicationsCompanion.insert(
            id: 'cm2',
            crisisId: 'c2',
            medicationNameSnapshot: 'Propranolol',
            takenAt: DateTime(2026, 5, 26, 9),
            medicationId: const Value('med-prev'),
          ),
        );

    // Day 0: crisis with a since-deleted med (null link) → counts as SOS.
    await seedCrisis('c3', DateTime(2026, 5, 27, 8), 7);
    await db
        .into(db.crisisMedications)
        .insert(
          CrisisMedicationsCompanion.insert(
            id: 'cm3',
            crisisId: 'c3',
            medicationNameSnapshot: 'Medicação antiga',
            takenAt: DateTime(2026, 5, 27, 8),
          ),
        );

    final stats = await db.watchHomeStatsLast30Days(userId: userId, now: now).first;
    expect(stats.daysWithMedication, 3, reason: 'all three days had a medication');
    expect(
      stats.daysWithSosMedication,
      2,
      reason: 'sos-med day + null-link day count; preventive-only day excluded',
    );
  });

  test('stream re-emits when a new crisis is inserted', () async {
    final now = DateTime(2026, 5, 27, 12);
    final stream = db.watchHomeStatsLast30Days(userId: userId, now: now);

    final emitted = <HomeStats>[];
    final sub = stream.listen(emitted.add);

    // Wait for the initial emission.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(emitted, hasLength(1));
    expect(emitted.first.totalCrises, 0);

    // Insert a crisis — Drift should detect the table change and the
    // customSelect stream should re-fire.
    await seedCrisis('x', DateTime(2026, 5, 27, 8), 6);
    await Future<void>.delayed(const Duration(milliseconds: 100));

    expect(emitted.length, greaterThanOrEqualTo(2));
    expect(emitted.last.totalCrises, 1);
    expect(emitted.last.daysModerada, 1);

    await sub.cancel();
  });
}
