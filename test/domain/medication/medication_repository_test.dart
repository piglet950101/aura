// Verifies MedicationRepository: create / edit / archive, the one-default
// invariant, and that every write enqueues a sync outbox entry (with the
// demoted previous default queued BEFORE the new default for unique-index
// safety on the server).

import 'package:aura/data/auth/auth_repository.dart';
import 'package:aura/data/local/database.dart';
import 'package:aura/data/sync/outbox_worker.dart';
import 'package:aura/domain/medication/medication_kind.dart';
import 'package:aura/domain/medication/medication_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AuraDatabase db;
  late MedicationRepository repo;

  setUp(() {
    db = AuraDatabase.test(NativeDatabase.memory());
    repo = MedicationRepository(
      database: db,
      auth: _StubAuth(const AppUser(id: 'u-marta', isAnonymous: true)),
    );
  });

  tearDown(() async {
    await db.close();
  });

  Future<List<Medication>> active() => db.watchActiveMedications('u-marta').first;

  test('save creates an SOS medication and enqueues an upsert', () async {
    final id = await repo.save(
      name: 'Sumatriptano',
      kind: MedicationKind.sos,
      isDefault: false,
      doseMg: 50,
    );

    final meds = await active();
    expect(meds, hasLength(1));
    expect(meds.single.id, id);
    expect(meds.single.name, 'Sumatriptano');
    expect(meds.single.kind, 'sos');
    expect(meds.single.doseMg, 50);
    expect(meds.single.isDefault, isFalse);

    final outbox = await db.pendingOutbox();
    expect(outbox, hasLength(1));
    expect(outbox.single.entityType, OutboxEntityType.medication);
    expect(outbox.single.entityId, id);
    expect(outbox.single.operation, OutboxOperation.upsert);
  });

  test('save trims the name and defaults kind to sos column-side', () async {
    await repo.save(name: '  Ibuprofeno  ', kind: MedicationKind.preventive, isDefault: false);
    final meds = await active();
    expect(meds.single.name, 'Ibuprofeno');
    expect(meds.single.kind, 'preventive');
    expect(meds.single.doseMg, isNull);
  });

  test('empty name is rejected', () async {
    expect(
      () => repo.save(name: '   ', kind: MedicationKind.sos, isDefault: false),
      throwsArgumentError,
    );
  });

  test('promoting a new default demotes the previous one (queued first)', () async {
    final firstId = await repo.save(name: 'Med A', kind: MedicationKind.sos, isDefault: true);
    final secondId = await repo.save(name: 'Med B', kind: MedicationKind.sos, isDefault: true);

    final meds = await active();
    final a = meds.firstWhere((m) => m.id == firstId);
    final b = meds.firstWhere((m) => m.id == secondId);
    expect(a.isDefault, isFalse, reason: 'previous default demoted');
    expect(b.isDefault, isTrue, reason: 'new default active');

    // Only one default at a time.
    expect(meds.where((m) => m.isDefault), hasLength(1));

    // Outbox order: A(create) , B(create) , A(demote) , B(promote) — the
    // demote of A must precede the promote of B so the server unique index
    // never sees two defaults.
    final outbox = await db.pendingOutbox();
    final demoteAIndex = outbox.lastIndexWhere((e) => e.entityId == firstId);
    final promoteBIndex = outbox.lastIndexWhere((e) => e.entityId == secondId);
    expect(demoteAIndex, lessThan(promoteBIndex));
  });

  test('editing an existing medication updates in place (no duplicate)', () async {
    final id = await repo.save(name: 'Med', kind: MedicationKind.sos, isDefault: false, doseMg: 25);
    await repo.save(
      id: id,
      name: 'Med Forte',
      kind: MedicationKind.preventive,
      isDefault: true,
      doseMg: 100,
    );

    final meds = await active();
    expect(meds, hasLength(1));
    expect(meds.single.id, id);
    expect(meds.single.name, 'Med Forte');
    expect(meds.single.kind, 'preventive');
    expect(meds.single.doseMg, 100);
    expect(meds.single.isDefault, isTrue);
  });

  test('archive removes from active list and enqueues a sync', () async {
    final id = await repo.save(name: 'Med', kind: MedicationKind.sos, isDefault: true);
    await repo.archive(id);

    expect(await active(), isEmpty);

    final med = await db.findMedication(id);
    expect(med, isNotNull);
    expect(med!.archived, isTrue);
    expect(med.isDefault, isFalse, reason: 'archived med cannot stay default');

    final outbox = await db.pendingOutbox();
    expect(outbox.last.entityId, id);
    expect(outbox.last.operation, OutboxOperation.upsert);
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
