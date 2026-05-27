// Use-case test for the crisis registration flow.
// ----------------------------------------------------------------------------
// Uses an in-memory Drift database and a fake AuthRepository so the whole
// pipeline runs without Supabase. Validates the transactional invariant
// that the crisis row, its m:n children, and the outbox entry land together
// (or none of them land).

import 'dart:async';

import 'package:aura/data/auth/auth_repository.dart';
import 'package:aura/data/local/database.dart';
import 'package:aura/data/sync/outbox_worker.dart';
import 'package:aura/domain/crisis/crisis_draft.dart';
import 'package:aura/domain/crisis/register_crisis_use_case.dart';
import 'package:aura/domain/crisis/symptom.dart';
import 'package:aura/domain/crisis/trigger.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AuraDatabase db;
  late _StubAuth auth;
  late RegisterCrisisUseCase useCase;

  setUp(() {
    db = AuraDatabase.test(NativeDatabase.memory());
    auth = _StubAuth(const AppUser(id: 'user-marta', isAnonymous: true));
    useCase = RegisterCrisisUseCase(database: db, auth: auth);
  });

  tearDown(() async {
    await db.close();
  });

  test('writes crisis + symptoms + trigger + outbox entry in one transaction', () async {
    const draft = CrisisDraft(
      intensity: 7,
      symptoms: {Symptom.nausea, Symptom.photophobia, Symptom.phonophobia},
      trigger: CrisisTrigger.stress,
    );

    final id = await useCase.register(draft: draft);

    // Crisis row landed and is owned by the current user.
    final crisis = await db.findCrisis(id);
    expect(crisis, isNotNull);
    expect(crisis!.userId, 'user-marta');
    expect(crisis.intensity, 7);

    // Symptoms persisted (deterministic order).
    final symptoms = await db.symptomsFor(id);
    expect(symptoms, ['nausea', 'phonophobia', 'photophobia']);

    // Trigger persisted.
    final triggers = await db.triggersFor(id);
    expect(triggers, ['stress']);

    // Outbox entry queued so the worker can sync.
    final pending = await db.pendingOutbox();
    expect(pending, hasLength(1));
    expect(pending.single.entityType, OutboxEntityType.crisis);
    expect(pending.single.entityId, id);
    expect(pending.single.operation, OutboxOperation.upsert);
  });

  test('persists occurredAt from the draft (or NOW when null)', () async {
    final whenExplicit = DateTime.utc(2026, 5, 25, 14, 30);
    final id1 = await useCase.register(draft: CrisisDraft(intensity: 5, occurredAt: whenExplicit));
    final c1 = await db.findCrisis(id1);
    expect(c1!.occurredAt.toUtc(), whenExplicit);

    final beforeNow = DateTime.now().toUtc();
    final id2 = await useCase.register(draft: const CrisisDraft(intensity: 4));
    final c2 = await db.findCrisis(id2);
    expect(
      c2!.occurredAt.toUtc().difference(beforeNow).inSeconds.abs(),
      lessThan(5),
      reason: 'null occurredAt should default to NOW',
    );
  });

  test('throws DraftIncompleteError if intensity is missing', () async {
    expect(
      () => useCase.register(draft: const CrisisDraft()),
      throwsA(isA<DraftIncompleteError>()),
    );
    expect(await db.pendingOutbox(), isEmpty);
    final all = await db.select(db.crises).get();
    expect(all, isEmpty);
  });

  test('throws StateError if no signed-in user', () async {
    auth = _StubAuth(null);
    useCase = RegisterCrisisUseCase(database: db, auth: auth);
    expect(
      () => useCase.register(draft: const CrisisDraft(intensity: 5)),
      throwsA(isA<StateError>()),
    );
  });

  test('two registrations produce two distinct ids and outbox entries', () async {
    final id1 = await useCase.register(draft: const CrisisDraft(intensity: 3));
    final id2 = await useCase.register(draft: const CrisisDraft(intensity: 8));
    expect(id1, isNot(id2));
    expect(await db.pendingOutbox(), hasLength(2));
  });
}

class _StubAuth implements AuthRepository {
  _StubAuth(this._user);

  AppUser? _user;

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
  }) async => const UpgradeFailure('not used in this test');

  @override
  Future<MagicLinkResult> sendMagicLink({required String email}) async => const MagicLinkSent();

  @override
  Future<void> signOut() async {
    _user = null;
  }
}
