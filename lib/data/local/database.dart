// AURA · local SQLite via Drift
// ----------------------------------------------------------------------------
// This is the offline-first source of truth. All reads go through here; all
// writes land here first and are then drained to Supabase by the OutboxWorker
// (Day 3). The schema mirrors `supabase/migrations/0001_initial_schema.sql`
// so a row can sync 1:1 by primary key — UUIDs are generated on the client
// (uuid.v4) and used as the canonical id on both sides.

import 'dart:io' show File;

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

// ===========================================================================
// Tables
// ---------------------------------------------------------------------------
// Naming convention:
//   - Table classes are PascalCase plural to match Drift's row-class
//     generation (e.g. `Crises` → `Crisis` row + `$CrisesTable`).
//   - Columns are camelCase. Drift snake_cases them at the SQL layer
//     automatically (via the default name mapping).
//   - All `id` columns are TEXT (UUID v4 strings) for sync-friendly equality
//     with Supabase. The single exception is `outbox_entries.id` which is an
//     auto-increment integer because it's a local-only queue.
// ===========================================================================

/// One row per Supabase auth user. We hold it locally so the UI can read
/// preferences (locale) without a network round-trip.
class Profiles extends Table {
  TextColumn get id => text()();
  TextColumn get displayName => text().nullable()();
  IntColumn get birthYear => integer().nullable()();
  TextColumn get sex => text().nullable()();
  TextColumn get locale => text().withDefault(const Constant('pt-PT'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// User-managed medication list. `archived = true` keeps the row visible to
/// historical crisis_medications references without polluting selectors.
class Medications extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  RealColumn get doseMg => real().nullable()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// The main event log: one row per registered migraine crisis.
@DataClassName('Crisis')
@TableIndex(name: 'crises_user_recent_idx', columns: {#userId, #occurredAt})
class Crises extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  DateTimeColumn get occurredAt => dateTime()();
  IntColumn get intensity => integer()();
  TextColumn get location => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get resolvedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// many-to-many: a crisis can have multiple symptoms. `symptom` is a stable
/// English code (e.g. 'photophobia') — the UI translates it at the
/// presentation layer using the active locale.
class CrisisSymptoms extends Table {
  TextColumn get crisisId => text().references(Crises, #id, onDelete: KeyAction.cascade)();
  TextColumn get symptom => text()();

  @override
  Set<Column<Object>> get primaryKey => {crisisId, symptom};
}

/// many-to-many: a crisis can have multiple identified triggers.
class CrisisTriggers extends Table {
  TextColumn get crisisId => text().references(Crises, #id, onDelete: KeyAction.cascade)();
  TextColumn get trigger => text()();

  @override
  Set<Column<Object>> get primaryKey => {crisisId, trigger};
}

/// Medication doses taken during a crisis, plus relief response if known.
/// `medicationNameSnapshot` is denormalised so deleting/archiving a
/// medication can never corrupt historical reports.
class CrisisMedications extends Table {
  TextColumn get id => text()();
  TextColumn get crisisId => text().references(Crises, #id, onDelete: KeyAction.cascade)();
  TextColumn get medicationId =>
      text().nullable().references(Medications, #id, onDelete: KeyAction.setNull)();
  TextColumn get medicationNameSnapshot => text()();
  RealColumn get doseMg => real().nullable()();
  DateTimeColumn get takenAt => dateTime()();
  DateTimeColumn get reliefAt => dateTime().nullable()();
  BoolColumn get effective => boolean().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Local-only sync queue. Every mutation enqueues an entry; the OutboxWorker
/// (Day 3) drains it to Supabase in order. We store only the operation and
/// the target entity reference, never the full payload — the worker re-reads
/// the current row at flush time so the *latest* state always wins. Deletes
/// carry the entity id because the row is gone by then.
@DataClassName('OutboxEntry')
@TableIndex(name: 'outbox_ready_idx', columns: {#nextRetryAt})
class OutboxEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get operation => text()(); // 'upsert' | 'delete'
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get nextRetryAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// ===========================================================================
// Database
// ===========================================================================

@DriftDatabase(
  tables: [
    Profiles,
    Medications,
    Crises,
    CrisisSymptoms,
    CrisisTriggers,
    CrisisMedications,
    OutboxEntries,
  ],
)
class AuraDatabase extends _$AuraDatabase {
  /// Production constructor — opens `<app docs>/aura.db` lazily.
  AuraDatabase() : super(_openOnDevice());

  /// Test constructor — pass an in-memory or alternative executor.
  AuraDatabase.test(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    beforeOpen: (details) async {
      // Foreign keys are off by default in SQLite — turn them on for
      // every connection so KeyAction.cascade actually fires.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  // --------------------------------------------------------------------
  // Crisis queries — minimal surface to support the Day 2 smoke test;
  // grow as Days 5–9 add the registration / calendar / detail flows.
  // --------------------------------------------------------------------

  Future<void> insertCrisis(CrisesCompanion row) =>
      into(crises).insert(row, mode: InsertMode.insertOrReplace);

  Future<Crisis?> findCrisis(String id) =>
      (select(crises)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<List<Crisis>> allCrisesNewestFirst({required String userId}) {
    return (select(crises)
          ..where((c) => c.userId.equals(userId))
          ..orderBy([(c) => OrderingTerm.desc(c.occurredAt)]))
        .get();
  }

  Future<int> deleteCrisis(String id) => (delete(crises)..where((c) => c.id.equals(id))).go();

  // --------------------------------------------------------------------
  // Outbox helpers — used by repository layer (Day 3) and the worker.
  // --------------------------------------------------------------------

  Future<int> enqueueOutbox({
    required String entityType,
    required String entityId,
    required String operation,
  }) {
    return into(outboxEntries).insert(
      OutboxEntriesCompanion.insert(
        entityType: entityType,
        entityId: entityId,
        operation: operation,
      ),
    );
  }

  Future<List<OutboxEntry>> pendingOutbox({int limit = 50}) {
    final now = DateTime.now();
    return (select(outboxEntries)
          ..where((e) => e.nextRetryAt.isSmallerOrEqualValue(now))
          ..orderBy([(e) => OrderingTerm.asc(e.id)])
          ..limit(limit))
        .get();
  }

  Future<int> markOutboxSent(int id) => (delete(outboxEntries)..where((e) => e.id.equals(id))).go();

  Future<int> markOutboxFailed({
    required int id,
    required String error,
    required Duration backoff,
  }) {
    return (update(outboxEntries)..where((e) => e.id.equals(id))).write(
      OutboxEntriesCompanion(
        // Worker can bump attempts in a separate call if it tracks retries.
        lastError: Value(error),
        nextRetryAt: Value(DateTime.now().add(backoff)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Connection helpers
// ---------------------------------------------------------------------------

QueryExecutor _openOnDevice() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'aura.db'));
    return NativeDatabase.createInBackground(file);
  });
}
