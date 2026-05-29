// Verifies AccountService.exportJson builds a complete, well-formed export,
// and that wipeAllLocalData clears every table. The server-delete + re-anon
// path needs a live Supabase, so it's covered by the on-device check.

import 'dart:convert';

import 'package:aura/data/account/account_service.dart';
import 'package:aura/data/auth/auth_repository.dart';
import 'package:aura/data/local/database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AuraDatabase db;
  late AccountService service;
  const uid = 'u-marta';

  setUp(() {
    db = AuraDatabase.test(NativeDatabase.memory());
    service = AccountService(
      database: db,
      auth: _StubAuth(const AppUser(id: uid, isAnonymous: true)),
    );
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedAll() async {
    await db.upsertProfile(
      const ProfilesCompanion(
        id: Value(uid),
        displayName: Value('Marta'),
        birthYear: Value(1990),
        sex: Value('f'),
      ),
    );
    await db
        .into(db.medications)
        .insert(
          MedicationsCompanion.insert(
            id: 'm1',
            userId: uid,
            name: 'Sumatriptano',
            kind: const Value('sos'),
          ),
        );
    await db.insertCrisis(
      CrisesCompanion.insert(
        id: 'c1',
        userId: uid,
        occurredAt: DateTime.utc(2026, 5, 20, 9),
        intensity: 7,
        notes: const Value('forte'),
      ),
    );
    await db
        .into(db.crisisSymptoms)
        .insert(CrisisSymptomsCompanion.insert(crisisId: 'c1', symptom: 'aura'));
    await db.insertCrisisMedication(
      CrisisMedicationsCompanion.insert(
        id: 'cm1',
        crisisId: 'c1',
        medicationId: const Value('m1'),
        medicationNameSnapshot: 'Sumatriptano',
        takenAt: DateTime.utc(2026, 5, 20, 9, 30),
        response: const Value('total'),
      ),
    );
  }

  test('exportJson includes profile, crises (with symptoms + meds) and catalog', () async {
    await seedAll();

    final json = await service.exportJson(now: DateTime.utc(2026, 5, 29, 12));
    final map = jsonDecode(json) as Map<String, dynamic>;

    expect(map['app'], 'AURA');
    expect(map['exported_at'], '2026-05-29T12:00:00.000Z');

    final profile = map['profile'] as Map<String, dynamic>;
    expect(profile['display_name'], 'Marta');
    expect(profile['birth_year'], 1990);
    expect(profile['sex'], 'f');

    final crises = map['crises'] as List;
    expect(crises, hasLength(1));
    final crisis = crises.single as Map<String, dynamic>;
    expect(crisis['intensity'], 7);
    expect(crisis['notes'], 'forte');
    expect(crisis['symptoms'], ['aura']);
    final meds = crisis['medications'] as List;
    expect((meds.single as Map)['name'], 'Sumatriptano');
    expect((meds.single as Map)['response'], 'total');

    final catalog = map['medications'] as List;
    expect((catalog.single as Map)['kind'], 'sos');
  });

  test('exportJson on an empty account is still valid JSON', () async {
    final json = await service.exportJson(now: DateTime.utc(2026, 5, 29, 12));
    final map = jsonDecode(json) as Map<String, dynamic>;
    expect(map['profile'], isNull);
    expect(map['crises'], isEmpty);
    expect(map['medications'], isEmpty);
  });

  test('wipeAllLocalData clears every table', () async {
    await seedAll();
    await db.wipeAllLocalData();

    expect(await db.getProfile(uid), isNull);
    expect(await db.allCrisesNewestFirst(userId: uid), isEmpty);
    expect(await db.allMedications(uid), isEmpty);
    expect(await db.crisisMedicationsFor('c1'), isEmpty);
    expect(await db.symptomsFor('c1'), isEmpty);
  });
}

class _StubAuth implements AuthRepository {
  _StubAuth(this._user);
  final AppUser _user;

  @override
  AppUser? get currentUser => _user;

  @override
  Stream<AppUser?> watchCurrentUser() async* {
    yield _user;
  }

  @override
  Future<UpgradeResult> upgradeToEmailPassword({
    required String email,
    required String password,
  }) async => const UpgradeFailure('not used');

  @override
  Future<MagicLinkResult> sendMagicLink({required String email}) async => const MagicLinkSent();

  @override
  Future<void> signOut() async {}
}
