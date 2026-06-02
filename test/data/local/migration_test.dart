// Verifies the Drift schema migration v1 -> v5 on a POPULATED database — the
// path a real existing install (e.g. the client's phone) takes. All other DB
// tests start fresh at v5 via onCreate and never exercise onUpgrade, so this
// is the test that de-risks losing or corrupting a user's data on update.

import 'dart:io';

import 'package:aura/data/local/database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late Directory tempDir;
  late File dbFile;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('aura_mig_test');
    dbFile = File('${tempDir.path}/aura.db');
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('migrates a populated v1 database to v5 without losing data', () async {
    // Build a v1-shaped database: medications has no `kind`, crisis_medications
    // has no `response`, profiles has no `email`, and there is no `appointments`
    // table yet. Seed enough rows to prove data survives the upgrade.
    sqlite3.open(dbFile.path)
      ..execute('''
      CREATE TABLE profiles (
        id TEXT NOT NULL PRIMARY KEY, display_name TEXT, birth_year INTEGER, sex TEXT,
        locale TEXT NOT NULL DEFAULT 'pt-PT',
        created_at INTEGER NOT NULL DEFAULT 0, updated_at INTEGER NOT NULL DEFAULT 0);
      CREATE TABLE medications (
        id TEXT NOT NULL PRIMARY KEY, user_id TEXT NOT NULL, name TEXT NOT NULL,
        dose_mg REAL, is_default INTEGER NOT NULL DEFAULT 0,
        archived INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL DEFAULT 0, updated_at INTEGER NOT NULL DEFAULT 0);
      CREATE TABLE crises (
        id TEXT NOT NULL PRIMARY KEY, user_id TEXT NOT NULL, occurred_at INTEGER NOT NULL,
        intensity INTEGER NOT NULL, location TEXT, notes TEXT, resolved_at INTEGER,
        created_at INTEGER NOT NULL DEFAULT 0, updated_at INTEGER NOT NULL DEFAULT 0);
      CREATE TABLE crisis_medications (
        id TEXT NOT NULL PRIMARY KEY, crisis_id TEXT NOT NULL REFERENCES crises(id),
        medication_id TEXT REFERENCES medications(id),
        medication_name_snapshot TEXT NOT NULL, dose_mg REAL, taken_at INTEGER NOT NULL,
        relief_at INTEGER, effective INTEGER);
    ''')
      ..execute(
        'INSERT INTO medications (id,user_id,name,dose_mg,is_default,archived) '
        "VALUES ('m1','u-marta','Sumatriptano',50,1,0)",
      )
      ..execute(
        'INSERT INTO crises (id,user_id,occurred_at,intensity) '
        "VALUES ('c1','u-marta',1779000000,7)",
      )
      ..execute(
        'INSERT INTO crisis_medications (id,crisis_id,medication_id,medication_name_snapshot,dose_mg,taken_at) '
        "VALUES ('cm1','c1','m1','Sumatriptano',50,1779000000)",
      )
      ..execute('PRAGMA user_version = 1')
      ..dispose();

    // Open through the app's database — first query triggers onUpgrade(1 -> 5).
    final db = AuraDatabase.test(NativeDatabase(dbFile));
    addTearDown(db.close);

    // medications.kind added by the v2 step, backfilled to its 'sos' default.
    final med = await db.findMedication('m1');
    expect(med, isNotNull);
    expect(med!.name, 'Sumatriptano', reason: 'existing data preserved');
    expect(med.isDefault, isTrue, reason: 'existing data preserved');
    expect(med.kind, 'sos', reason: 'v2 addColumn backfills the default');
    // v4 addColumn for the new `reminder_minutes` field — nullable, no backfill.
    expect(med.reminderMinutes, isNull, reason: 'v4 addColumn is nullable');
    // v5 addColumns for the new preventive subtype + treatment-date fields —
    // every existing row picks up null until the user edits.
    expect(med.preventiveSubtype, isNull, reason: 'v5 addColumn is nullable');
    expect(med.injectionPeriodDays, isNull, reason: 'v5 addColumn is nullable');
    expect(med.startedAt, isNull, reason: 'v5 addColumn is nullable');
    expect(med.endedAt, isNull, reason: 'v5 addColumn is nullable');

    // crisis_medications.response added by the v3 step, nullable (no backfill).
    final cms = await db.crisisMedicationsFor('c1');
    expect(cms, hasLength(1));
    expect(cms.single.medicationNameSnapshot, 'Sumatriptano');
    expect(cms.single.response, isNull, reason: 'v3 addColumn is nullable');

    // v5 adds crises.menstruation — nullable column, existing row reads null.
    final c1 = await db.findCrisis('c1');
    expect(c1?.menstruation, isNull, reason: 'v5 addColumn is nullable');

    // v4 also adds the new `appointments` table — prove it exists and is
    // readable/writable end-to-end by inserting and reading back one row.
    await db.upsertAppointment(
      AppointmentsCompanion(
        id: const Value('a1'),
        userId: const Value('u-marta'),
        occursAt: Value(DateTime.utc(2026, 6, 15, 10)),
        doctorName: const Value('Dra. Rocha'),
      ),
    );
    final appts = await db.allAppointments('u-marta');
    expect(appts, hasLength(1));
    expect(appts.single.doctorName, 'Dra. Rocha');

    // v4 also adds `profiles.email` — the column accepts and round-trips a
    // value with no schema complaint (proves the addColumn step ran).
    await db.upsertProfile(
      const ProfilesCompanion(id: Value('u-marta'), email: Value('marta@example.com')),
    );
    final profile = await db.getProfile('u-marta');
    expect(profile?.email, 'marta@example.com');

    // v5 adds the hit6_responses table — prove it exists and round-trips.
    await db
        .into(db.hit6Responses)
        .insert(
          Hit6ResponsesCompanion.insert(
            id: 'h1',
            userId: 'u-marta',
            submittedAt: DateTime.utc(2026, 6, 1, 9, 30),
            score: 54,
            responses: '["never","sometimes","sometimes","sometimes","rarely","very_often"]',
          ),
        );
    final hit6 = await db.select(db.hit6Responses).get();
    expect(hit6, hasLength(1));
    expect(hit6.single.score, 54);

    // The database now reports schema version 5.
    final row = await db.customSelect('PRAGMA user_version').getSingle();
    expect(row.read<int>('user_version'), 5);
  });
}
