// Verifies ProfileRepository.save upserts the profile (create then update).

import 'package:aura/data/local/database.dart';
import 'package:aura/domain/profile/profile_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AuraDatabase db;
  late ProfileRepository repo;

  setUp(() {
    db = AuraDatabase.test(NativeDatabase.memory());
    repo = ProfileRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('save creates a profile, trimming an empty name to null', () async {
    await repo.save(userId: 'u1', displayName: '  ', birthYear: 1990, sex: 'f');
    final p = await db.getProfile('u1');
    expect(p, isNotNull);
    expect(p!.displayName, isNull, reason: 'blank name stored as null');
    expect(p.birthYear, 1990);
    expect(p.sex, 'f');
  });

  test('save updates an existing profile in place', () async {
    await repo.save(userId: 'u1', displayName: 'Marta', birthYear: 1990, sex: 'f');
    await repo.save(userId: 'u1', displayName: 'Marta S.', birthYear: 1991, sex: 'na');

    final p = await db.getProfile('u1');
    expect(p!.displayName, 'Marta S.');
    expect(p.birthYear, 1991);
    expect(p.sex, 'na');
  });
}
