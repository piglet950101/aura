// AURA · local SQLite via Drift
// ----------------------------------------------------------------------------
// This is the offline-first source of truth. All reads go through here; all
// writes land here first and are then drained to Supabase by the OutboxWorker
// (Day 3). The schema mirrors `supabase/migrations/0001_initial_schema.sql`
// so a row can sync 1:1 by primary key — UUIDs are generated on the client
// (uuid.v4) and used as the canonical id on both sides.

import 'dart:io' show File;

import 'package:aura/domain/home/home_stats.dart';
import 'package:aura/domain/medication/pending_medication_response.dart';
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

  /// 'sos' (acute / rescue, taken during a crisis) or 'preventive' (daily
  /// prophylactic). Drives the "Medicação SOS" overuse metric on the home
  /// summary. Defaults to 'sos' — most logged meds are rescue meds, and it
  /// keeps the v1→v2 migration of existing rows sensible.
  TextColumn get kind => text().withDefault(const Constant('sos'))();

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
/// `CrisisTriggerRow` is the explicit row-class name so we don't collide
/// with the domain enum `CrisisTrigger` defined in lib/domain/crisis/.
@DataClassName('CrisisTriggerRow')
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

  /// Medication response, asked when the app reopens (≥2h after the dose):
  /// 'none' | 'partial' | 'total'. Null = not recorded yet.
  TextColumn get response => text().nullable()();

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
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      // v2: medications gain a `kind` column (sos / preventive). Existing
      // rows default to 'sos' via the column default, so no data is lost.
      if (from < 2) {
        await m.addColumn(medications, medications.kind);
      }
      // v3: crisis_medications gain a `response` column (none/partial/total),
      // captured when the app reopens after a dose. Nullable, no backfill.
      if (from < 3) {
        await m.addColumn(crisisMedications, crisisMedications.response);
      }
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

  /// Reactive list of a user's crises whose [Crises.occurredAt] falls in
  /// `[start, end)`. Used by the calendar (a month window) and reusable for
  /// any range report. Bounds are compared as absolute instants — pass the
  /// UTC range that covers the local window; the caller bins by local day.
  Stream<List<Crisis>> watchCrisesInRange({
    required String userId,
    required DateTime start,
    required DateTime end,
  }) {
    return (select(crises)
          ..where(
            (c) =>
                c.userId.equals(userId) &
                c.occurredAt.isBiggerOrEqualValue(start) &
                c.occurredAt.isSmallerThanValue(end),
          )
          ..orderBy([(c) => OrderingTerm.asc(c.occurredAt)]))
        .watch();
  }

  /// Stable English symptom codes attached to a crisis, ordered for
  /// deterministic sync payloads.
  Future<List<String>> symptomsFor(String crisisId) async {
    final rows =
        await (select(crisisSymptoms)
              ..where((cs) => cs.crisisId.equals(crisisId))
              ..orderBy([(cs) => OrderingTerm.asc(cs.symptom)]))
            .get();
    return rows.map((r) => r.symptom).toList();
  }

  /// Stable English trigger codes attached to a crisis.
  Future<List<String>> triggersFor(String crisisId) async {
    final rows =
        await (select(crisisTriggers)
              ..where((ct) => ct.crisisId.equals(crisisId))
              ..orderBy([(ct) => OrderingTerm.asc(ct.trigger)]))
            .get();
    return rows.map((r) => r.trigger).toList();
  }

  // --------------------------------------------------------------------
  // Home dashboard stats — reactive Stream that re-emits whenever the
  // crises or crisis_medications tables change (so registering a crisis
  // updates the home page summary without explicit refresh logic).
  //
  // We measure in "distinct calendar days, local time" rather than raw
  // counts — that matches the home UI which says "N dias" per bucket.
  // --------------------------------------------------------------------
  Stream<HomeStats> watchHomeStatsLast30Days({required String userId, DateTime? now}) {
    final today = (now ?? DateTime.now()).toLocal();
    final startOfToday = DateTime(today.year, today.month, today.day);
    // 30-day window includes today, so subtract 29 days.
    final cutoff = startOfToday.subtract(const Duration(days: 29));

    // Drift's customSelect binds variables positionally; use `?` each time
    // and re-pass the values (numbered `?1` placeholders aren't reliably
    // supported across sqlite3 + Drift versions).
    return customSelect(
      '''
SELECT
  COUNT(DISTINCT date(occurred_at, 'unixepoch'))
    AS days_with_crisis,
  COUNT(DISTINCT CASE WHEN intensity BETWEEN 1 AND 3
                      THEN date(occurred_at, 'unixepoch') END)
    AS days_leve,
  COUNT(DISTINCT CASE WHEN intensity BETWEEN 4 AND 6
                      THEN date(occurred_at, 'unixepoch') END)
    AS days_moderada,
  COUNT(DISTINCT CASE WHEN intensity BETWEEN 7 AND 10
                      THEN date(occurred_at, 'unixepoch') END)
    AS days_forte,
  (SELECT COUNT(DISTINCT date(c.occurred_at, 'unixepoch'))
     FROM crises c
     JOIN crisis_medications cm ON cm.crisis_id = c.id
    WHERE c.user_id = ? AND c.occurred_at >= ?)
    AS days_with_medication,
  (SELECT COUNT(DISTINCT date(c.occurred_at, 'unixepoch'))
     FROM crises c
     JOIN crisis_medications cm ON cm.crisis_id = c.id
     LEFT JOIN medications m ON m.id = cm.medication_id
    WHERE c.user_id = ? AND c.occurred_at >= ?
      AND (m.kind = 'sos' OR cm.medication_id IS NULL))
    AS days_with_sos_medication,
  COUNT(*) AS total_crises
FROM crises
WHERE user_id = ? AND occurred_at >= ?
''',
      variables: [
        Variable.withString(userId),
        Variable.withDateTime(cutoff),
        Variable.withString(userId),
        Variable.withDateTime(cutoff),
        Variable.withString(userId),
        Variable.withDateTime(cutoff),
      ],
      readsFrom: {crises, crisisMedications, medications},
    ).watchSingle().map((row) {
      final daysWithCrisis = row.read<int>('days_with_crisis');
      return HomeStats(
        daysNoPain: (30 - daysWithCrisis).clamp(0, 30),
        daysLeve: row.read<int>('days_leve'),
        daysModerada: row.read<int>('days_moderada'),
        daysForte: row.read<int>('days_forte'),
        daysWithMedication: row.read<int>('days_with_medication'),
        daysWithSosMedication: row.read<int>('days_with_sos_medication'),
        totalCrises: row.read<int>('total_crises'),
      );
    });
  }

  // --------------------------------------------------------------------
  // Medication queries — the catalog the user manages (Day 10). Archived
  // rows stay so historical crisis_medications keep a real reference, but
  // they're hidden from the active list / pickers.
  // --------------------------------------------------------------------

  Stream<List<Medication>> watchActiveMedications(String userId) {
    return (select(medications)
          ..where((m) => m.userId.equals(userId) & m.archived.equals(false))
          ..orderBy([(m) => OrderingTerm.desc(m.isDefault), (m) => OrderingTerm.asc(m.name)]))
        .watch();
  }

  Future<Medication?> findMedication(String id) =>
      (select(medications)..where((m) => m.id.equals(id))).getSingleOrNull();

  Future<Medication?> defaultMedication(String userId) {
    return (select(medications)..where(
          (m) => m.userId.equals(userId) & m.isDefault.equals(true) & m.archived.equals(false),
        ))
        .getSingleOrNull();
  }

  /// Case-insensitive lookup of an active medication by name — used to resolve
  /// a crisis-form preset to an existing catalog row before creating a new one.
  Future<Medication?> findActiveMedicationByName({required String userId, required String name}) {
    return (select(medications)..where(
          (m) =>
              m.userId.equals(userId) &
              m.archived.equals(false) &
              m.name.lower().equals(name.toLowerCase()),
        ))
        .getSingleOrNull();
  }

  /// Crisis medications still awaiting a response, taken in `[notBefore,
  /// notAfter]` for the user. Newest first. Drives the on-reopen prompt.
  Future<List<PendingMedicationResponse>> pendingMedicationResponses({
    required String userId,
    required DateTime notBefore,
    required DateTime notAfter,
  }) async {
    final query =
        select(
            crisisMedications,
          ).join([innerJoin(crises, crises.id.equalsExp(crisisMedications.crisisId))])
          ..where(
            crises.userId.equals(userId) &
                crisisMedications.response.isNull() &
                crisisMedications.takenAt.isSmallerOrEqualValue(notAfter) &
                crisisMedications.takenAt.isBiggerOrEqualValue(notBefore),
          )
          ..orderBy([OrderingTerm.desc(crisisMedications.takenAt)]);

    final rows = await query.get();
    return rows.map((r) {
      final cm = r.readTable(crisisMedications);
      return PendingMedicationResponse(
        crisisMedicationId: cm.id,
        crisisId: cm.crisisId,
        medicationName: cm.medicationNameSnapshot,
        takenAt: cm.takenAt,
      );
    }).toList();
  }

  Future<void> setCrisisMedicationResponse({required String id, required String response}) {
    return (update(crisisMedications)..where((cm) => cm.id.equals(id))).write(
      CrisisMedicationsCompanion(response: Value(response)),
    );
  }

  Future<void> insertMedication(MedicationsCompanion row) => into(medications).insert(row);

  Future<void> insertCrisisMedication(CrisisMedicationsCompanion row) =>
      into(crisisMedications).insert(row);

  /// Medication doses logged against a crisis (for sync + detail views).
  Future<List<CrisisMedication>> crisisMedicationsFor(String crisisId) {
    return (select(crisisMedications)..where((cm) => cm.crisisId.equals(crisisId))).get();
  }

  Future<void> updateMedicationFields({
    required String id,
    required String name,
    required String kind,
    required bool isDefault,
    double? doseMg,
  }) {
    return (update(medications)..where((m) => m.id.equals(id))).write(
      MedicationsCompanion(
        name: Value(name),
        doseMg: Value(doseMg),
        kind: Value(kind),
        isDefault: Value(isDefault),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> archiveMedicationById(String id) {
    return (update(medications)..where((m) => m.id.equals(id))).write(
      MedicationsCompanion(
        archived: const Value(true),
        isDefault: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Demotes every *other* default medication for [userId] (all except
  /// [exceptId]), returning the ids that changed so the caller can enqueue
  /// their sync. Enforces the "one default per user" invariant.
  Future<List<String>> demoteOtherDefaultMedications({
    required String userId,
    required String exceptId,
  }) async {
    final others =
        await (select(medications)..where(
              (m) => m.userId.equals(userId) & m.isDefault.equals(true) & m.id.isNotValue(exceptId),
            ))
            .get();
    for (final od in others) {
      await (update(medications)..where((m) => m.id.equals(od.id))).write(
        MedicationsCompanion(isDefault: const Value(false), updatedAt: Value(DateTime.now())),
      );
    }
    return [for (final o in others) o.id];
  }

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
    required int currentAttempts,
    required String error,
    required Duration backoff,
  }) {
    return (update(outboxEntries)..where((e) => e.id.equals(id))).write(
      OutboxEntriesCompanion(
        attempts: Value(currentAttempts + 1),
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
