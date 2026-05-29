// Verifies the Drift schema migration v1 -> v3 on a POPULATED database — the
// path a real existing install (e.g. the client's phone) takes. All other DB
// tests start fresh at v3 via onCreate and never exercise onUpgrade, so this
// is the test that de-risks losing or corrupting a user's data on update.

import 'dart:io';

import 'package:aura/data/local/database.dart';
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

  test('migrates a populated v1 database to v3 without losing data', () async {
    // Build a v1-shaped database: medications has no `kind`, crisis_medications
    // has no `response`. Seed one of each so we can prove data survives.
    sqlite3.open(dbFile.path)
      ..execute('''
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

    // Open through the app's database — first query triggers onUpgrade(1 -> 3).
    final db = AuraDatabase.test(NativeDatabase(dbFile));
    addTearDown(db.close);

    // medications.kind added by the v2 step, backfilled to its 'sos' default.
    final med = await db.findMedication('m1');
    expect(med, isNotNull);
    expect(med!.name, 'Sumatriptano', reason: 'existing data preserved');
    expect(med.isDefault, isTrue, reason: 'existing data preserved');
    expect(med.kind, 'sos', reason: 'v2 addColumn backfills the default');

    // crisis_medications.response added by the v3 step, nullable (no backfill).
    final cms = await db.crisisMedicationsFor('c1');
    expect(cms, hasLength(1));
    expect(cms.single.medicationNameSnapshot, 'Sumatriptano');
    expect(cms.single.response, isNull, reason: 'v3 addColumn is nullable');

    // The database now reports schema version 3.
    final row = await db.customSelect('PRAGMA user_version').getSingle();
    expect(row.read<int>('user_version'), 3);
  });
}
