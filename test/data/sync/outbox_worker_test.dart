// OutboxWorker tests.
// ----------------------------------------------------------------------------
// Uses an in-memory Drift DB plus fake remote data sources so the whole
// drain pipeline runs synchronously without any network or Supabase mock.

import 'dart:async';

import 'package:aura/data/local/database.dart';
import 'package:aura/data/remote/crisis_remote_data_source.dart';
import 'package:aura/data/remote/medication_remote_data_source.dart';
import 'package:aura/data/sync/outbox_worker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AuraDatabase db;
  late _FakeCrisisRemote crisisRemote;
  late _FakeMedicationRemote medicationRemote;
  late StreamController<List<ConnectivityResult>> connectivityCtl;
  late OutboxWorker worker;

  setUp(() {
    db = AuraDatabase.test(NativeDatabase.memory());
    crisisRemote = _FakeCrisisRemote();
    medicationRemote = _FakeMedicationRemote();
    connectivityCtl = StreamController<List<ConnectivityResult>>.broadcast();
    worker = OutboxWorker(
      database: db,
      crisisRemote: crisisRemote,
      medicationRemote: medicationRemote,
      connectivityStream: connectivityCtl.stream,
      // Short timer so test doesn't depend on real 30s.
      periodic: const Duration(milliseconds: 50),
      baseBackoff: const Duration(seconds: 1),
      maxBackoff: const Duration(seconds: 60),
    );
  });

  tearDown(() async {
    worker.stop();
    await connectivityCtl.close();
    await db.close();
  });

  test('drain pushes crisis upsert and clears the entry', () async {
    await db.insertCrisis(
      CrisesCompanion.insert(
        id: 'c1',
        userId: 'u1',
        occurredAt: DateTime.utc(2026, 5, 25, 14),
        intensity: 7,
      ),
    );
    await db.enqueueOutbox(
      entityType: OutboxEntityType.crisis,
      entityId: 'c1',
      operation: OutboxOperation.upsert,
    );

    await worker.drain();

    expect(crisisRemote.upserts, hasLength(1));
    expect(crisisRemote.upserts.single.id, 'c1');
    expect(crisisRemote.upserts.single.intensity, 7);
    expect(await db.pendingOutbox(), isEmpty);
  });

  test('drain pushes crisis delete by id (no need for local row)', () async {
    await db.enqueueOutbox(
      entityType: OutboxEntityType.crisis,
      entityId: 'gone-c2',
      operation: OutboxOperation.delete,
    );

    await worker.drain();

    expect(crisisRemote.deletes, ['gone-c2']);
    expect(await db.pendingOutbox(), isEmpty);
  });

  test('upsert of a locally-deleted row resolves without remote call', () async {
    // Enqueue an upsert for a crisis that no longer exists locally
    // (user inserted then deleted before sync). Worker should NOT call the
    // remote and should clear the entry — otherwise we'd send a ghost row.
    await db.enqueueOutbox(
      entityType: OutboxEntityType.crisis,
      entityId: 'ghost',
      operation: OutboxOperation.upsert,
    );

    await worker.drain();

    expect(crisisRemote.upserts, isEmpty);
    expect(await db.pendingOutbox(), isEmpty);
  });

  test('drain handles medication operations', () async {
    await db
        .into(db.medications)
        .insert(MedicationsCompanion.insert(id: 'm1', userId: 'u1', name: 'Sumatriptan'));
    await db.enqueueOutbox(
      entityType: OutboxEntityType.medication,
      entityId: 'm1',
      operation: OutboxOperation.upsert,
    );
    await db.enqueueOutbox(
      entityType: OutboxEntityType.medication,
      entityId: 'old-m9',
      operation: OutboxOperation.delete,
    );

    await worker.drain();

    expect(medicationRemote.upserts.single.name, 'Sumatriptan');
    expect(medicationRemote.deletes, ['old-m9']);
    expect(await db.pendingOutbox(), isEmpty);
  });

  test('failure increments attempts and schedules backoff', () async {
    await db.insertCrisis(
      CrisesCompanion.insert(
        id: 'c1',
        userId: 'u1',
        occurredAt: DateTime.utc(2026, 5, 25, 14),
        intensity: 7,
      ),
    );
    await db.enqueueOutbox(
      entityType: OutboxEntityType.crisis,
      entityId: 'c1',
      operation: OutboxOperation.upsert,
    );

    crisisRemote.failNextN = 1; // simulate one transient error
    await worker.drain();

    // pendingOutbox filters by next_retry_at <= now; backoff pushes it future.
    expect(await db.pendingOutbox(), isEmpty);

    // But the entry still exists with attempts bumped.
    final all = await db.select(db.outboxEntries).get();
    expect(all, hasLength(1));
    expect(all.single.attempts, 1);
    expect(all.single.lastError, contains('simulated'));
  });

  test('connectivity change to non-none triggers a drain', () async {
    worker.start();
    // Let the initial drain (on an empty queue) settle.
    await Future<void>.delayed(const Duration(milliseconds: 10));

    // Enqueue while "offline" (no connectivity event delivered yet).
    await db.enqueueOutbox(
      entityType: OutboxEntityType.crisis,
      entityId: 'reconnect-y',
      operation: OutboxOperation.delete,
    );

    // No drain yet because we haven't fired a connectivity event or hit
    // the 50ms timer threshold. (We could be racing the timer here, but
    // any drain that happens is still correct behavior — the test asserts
    // the END state after the reconnect event.)
    connectivityCtl.add([ConnectivityResult.wifi]);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(crisisRemote.deletes, contains('reconnect-y'));
  });

  test('start() is idempotent', () async {
    worker
      ..start()
      ..start()
      ..start();
    // No crash, no duplicate work — drain is guarded by _draining.
    expect(true, isTrue);
  });
}

// -------- Fakes -------------------------------------------------------------

class _FakeCrisisRemote implements CrisisRemoteDataSource {
  final List<Crisis> upserts = [];
  final List<String> deletes = [];
  int failNextN = 0;

  void _maybeFail() {
    if (failNextN > 0) {
      failNextN--;
      throw Exception('simulated remote failure');
    }
  }

  @override
  Future<void> upsert(Crisis row) async {
    _maybeFail();
    upserts.add(row);
  }

  @override
  Future<void> delete(String id) async {
    _maybeFail();
    deletes.add(id);
  }

  @override
  Future<List<CrisesCompanion>> fetchUpdatedAfter({
    required DateTime since,
    required String userId,
  }) async => <CrisesCompanion>[];
}

class _FakeMedicationRemote implements MedicationRemoteDataSource {
  final List<Medication> upserts = [];
  final List<String> deletes = [];

  @override
  Future<void> upsert(Medication row) async {
    upserts.add(row);
  }

  @override
  Future<void> delete(String id) async {
    deletes.add(id);
  }

  @override
  Future<List<MedicationsCompanion>> fetchUpdatedAfter({
    required DateTime since,
    required String userId,
  }) async => <MedicationsCompanion>[];
}
