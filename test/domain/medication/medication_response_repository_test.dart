// Verifies the on-reopen medication-response flow: which doses are "pending"
// (taken >= 2h and <= 7d ago, no response) and that recording an answer sets
// the response and queues the crisis for re-sync.

import 'package:aura/data/auth/auth_repository.dart';
import 'package:aura/data/local/database.dart';
import 'package:aura/data/sync/outbox_worker.dart';
import 'package:aura/domain/medication/medication_response_repository.dart';
import 'package:aura/domain/medication/pending_medication_response.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AuraDatabase db;
  late MedicationResponseRepository repo;
  final now = DateTime(2026, 5, 29, 12);

  setUp(() {
    db = AuraDatabase.test(NativeDatabase.memory());
    repo = MedicationResponseRepository(
      database: db,
      auth: _StubAuth(const AppUser(id: 'u-marta', isAnonymous: true)),
    );
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedDose(String cmId, String crisisId, DateTime takenAt, {String? response}) async {
    await db.insertCrisis(
      CrisesCompanion.insert(id: crisisId, userId: 'u-marta', occurredAt: takenAt, intensity: 6),
    );
    await db.insertCrisisMedication(
      CrisisMedicationsCompanion.insert(
        id: cmId,
        crisisId: crisisId,
        medicationNameSnapshot: 'Sumatriptano',
        takenAt: takenAt,
        response: Value(response),
      ),
    );
  }

  test('a dose taken 3h ago with no response is pending', () async {
    await seedDose('cm1', 'c1', now.subtract(const Duration(hours: 3)));
    final pending = await repo.nextPending(now: now);
    expect(pending, isNotNull);
    expect(pending!.crisisMedicationId, 'cm1');
    expect(pending.medicationName, 'Sumatriptano');
  });

  test('a dose taken 1h ago is NOT yet pending (too soon to judge)', () async {
    await seedDose('cm1', 'c1', now.subtract(const Duration(hours: 1)));
    expect(await repo.nextPending(now: now), isNull);
  });

  test('a dose taken 10 days ago is NOT pending (too old)', () async {
    await seedDose('cm1', 'c1', now.subtract(const Duration(days: 10)));
    expect(await repo.nextPending(now: now), isNull);
  });

  test('a dose that already has a response is NOT pending', () async {
    await seedDose('cm1', 'c1', now.subtract(const Duration(hours: 3)), response: 'total');
    expect(await repo.nextPending(now: now), isNull);
  });

  test('record sets the response and queues the crisis for re-sync', () async {
    await seedDose('cm1', 'c1', now.subtract(const Duration(hours: 3)));
    final pending = (await repo.nextPending(now: now))!;

    await repo.record(pending: pending, response: MedicationResponse.partial);

    final cm = await db.crisisMedicationsFor('c1');
    expect(cm.single.response, 'partial');

    // No longer pending.
    expect(await repo.nextPending(now: now), isNull);

    // Crisis queued so the response syncs via setMedications.
    final outbox = await db.pendingOutbox();
    expect(
      outbox.where((e) => e.entityType == OutboxEntityType.crisis && e.entityId == 'c1'),
      isNotEmpty,
    );
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
