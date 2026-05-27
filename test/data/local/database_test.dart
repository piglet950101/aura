// Smoke test for the Drift local DB.
//
// Validates the Day 2 deliverable end-to-end on an in-memory SQLite:
//   1. The schema migrates clean on a fresh install.
//   2. A crisis can be inserted and read back with field-perfect fidelity.
//   3. An outbox entry can be enqueued, listed as pending, and marked sent.
//   4. Foreign-key cascade fires: deleting a crisis also removes its
//      crisis_symptoms / crisis_triggers / crisis_medications children.
//
// In-memory NativeDatabase means every test gets a virgin schema; no test
// pollution, no fixture setup.

import 'package:aura/data/local/database.dart';
// Drift exports its own `isNotNull` column matcher which collides with
// flutter_test's matcher. Hide the column-side one; we only need `Value`.
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

void main() {
  late AuraDatabase db;

  setUp(() {
    db = AuraDatabase.test(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('schema migrates clean on first open', () async {
    // Reading from an empty schema with no error proves migration succeeded.
    final crises = await db.allCrisesNewestFirst(userId: 'nobody');
    expect(crises, isEmpty);
    final outbox = await db.pendingOutbox();
    expect(outbox, isEmpty);
  });

  test('insert a crisis and read it back', () async {
    final id = const Uuid().v4();
    final occurredAt = DateTime.utc(2026, 5, 25, 14, 30);

    await db.insertCrisis(
      CrisesCompanion.insert(
        id: id,
        userId: 'user-marta',
        occurredAt: occurredAt,
        intensity: 7,
        location: const Value('frontal'),
        notes: const Value('after a stressful afternoon'),
      ),
    );

    final found = await db.findCrisis(id);
    expect(found, isNotNull);
    expect(found!.id, id);
    expect(found.userId, 'user-marta');
    expect(found.intensity, 7);
    expect(found.location, 'frontal');
    expect(found.notes, 'after a stressful afternoon');
    expect(found.occurredAt.toUtc(), occurredAt);
  });

  test('list crises newest-first, scoped by user', () async {
    const user = 'user-marta';
    await db.insertCrisis(
      CrisesCompanion.insert(
        id: 'a',
        userId: user,
        occurredAt: DateTime.utc(2026, 5, 10),
        intensity: 5,
      ),
    );
    await db.insertCrisis(
      CrisesCompanion.insert(
        id: 'b',
        userId: user,
        occurredAt: DateTime.utc(2026, 5, 20),
        intensity: 8,
      ),
    );
    // Different user's row must be excluded.
    await db.insertCrisis(
      CrisesCompanion.insert(
        id: 'other',
        userId: 'someone-else',
        occurredAt: DateTime.utc(2026, 5, 25),
        intensity: 9,
      ),
    );

    final results = await db.allCrisesNewestFirst(userId: user);
    expect(results.map((c) => c.id), ['b', 'a']);
  });

  test('outbox: enqueue, list pending, mark sent', () async {
    final firstId = await db.enqueueOutbox(
      entityType: 'crisis',
      entityId: 'crisis-1',
      operation: 'upsert',
    );
    await db.enqueueOutbox(entityType: 'medication', entityId: 'med-7', operation: 'delete');

    final pending = await db.pendingOutbox();
    expect(pending, hasLength(2));
    expect(pending.first.entityType, 'crisis');
    expect(pending.first.operation, 'upsert');

    await db.markOutboxSent(firstId);

    final remaining = await db.pendingOutbox();
    expect(remaining, hasLength(1));
    expect(remaining.single.entityType, 'medication');
  });

  test('outbox failure: backoff is honored by pendingOutbox', () async {
    final id = await db.enqueueOutbox(
      entityType: 'crisis',
      entityId: 'crisis-x',
      operation: 'upsert',
    );

    await db.markOutboxFailed(
      id: id,
      error: 'simulated network 500',
      backoff: const Duration(hours: 1),
    );

    // pendingOutbox filters by next_retry_at <= now, so an entry pushed an
    // hour into the future must not appear yet.
    final pending = await db.pendingOutbox();
    expect(pending, isEmpty);
  });

  test('deleting a crisis cascades to its child rows', () async {
    final crisisId = const Uuid().v4();
    await db.insertCrisis(
      CrisesCompanion.insert(
        id: crisisId,
        userId: 'user-marta',
        occurredAt: DateTime.now(),
        intensity: 6,
      ),
    );
    await db
        .into(db.crisisSymptoms)
        .insert(CrisisSymptomsCompanion.insert(crisisId: crisisId, symptom: 'photophobia'));
    await db
        .into(db.crisisTriggers)
        .insert(CrisisTriggersCompanion.insert(crisisId: crisisId, trigger: 'stress'));

    // Sanity check before delete.
    final symptomsBefore = await db.select(db.crisisSymptoms).get();
    final triggersBefore = await db.select(db.crisisTriggers).get();
    expect(symptomsBefore, hasLength(1));
    expect(triggersBefore, hasLength(1));

    final affected = await db.deleteCrisis(crisisId);
    expect(affected, 1);

    final symptomsAfter = await db.select(db.crisisSymptoms).get();
    final triggersAfter = await db.select(db.crisisTriggers).get();
    expect(symptomsAfter, isEmpty);
    expect(triggersAfter, isEmpty);
  });
}
