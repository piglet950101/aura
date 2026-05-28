// Verifies watchCrisesInRange: filters by user + [start, end) window, orders
// ascending by occurred_at, and re-emits reactively when a crisis is added.

import 'package:aura/data/local/database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AuraDatabase db;

  setUp(() {
    db = AuraDatabase.test(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  const userId = 'user-marta';

  Future<void> seed(String id, DateTime when, int intensity, {String user = userId}) {
    return db.insertCrisis(
      CrisesCompanion.insert(id: id, userId: user, occurredAt: when, intensity: intensity),
    );
  }

  test('returns only the active user crises inside the window, ordered', () async {
    await seed('mid', DateTime(2026, 5, 15, 10), 5);
    await seed('early', DateTime(2026, 5, 2, 8), 3);
    await seed('before', DateTime(2026, 4, 28, 8), 9); // before window
    await seed('after', DateTime(2026, 6, 3, 8), 9); // after window
    await seed('other', DateTime(2026, 5, 10, 8), 7, user: 'someone-else');

    final start = DateTime(2026, 5);
    final end = DateTime(2026, 6);
    final rows = await db.watchCrisesInRange(userId: userId, start: start, end: end).first;

    expect(rows.map((r) => r.id).toList(), ['early', 'mid'], reason: 'ascending, in-window, mine');
  });

  test('end bound is exclusive, start bound is inclusive', () async {
    final start = DateTime(2026, 5);
    final end = DateTime(2026, 6);
    await seed('atStart', start, 4); // inclusive → included
    await seed('atEnd', end, 4); // exclusive → excluded

    final rows = await db.watchCrisesInRange(userId: userId, start: start, end: end).first;
    expect(rows.map((r) => r.id).toList(), ['atStart']);
  });

  test('stream re-emits when a crisis is inserted in range', () async {
    final start = DateTime(2026, 5);
    final end = DateTime(2026, 6);
    final emitted = <int>[];
    final sub = db
        .watchCrisesInRange(userId: userId, start: start, end: end)
        .listen((rows) => emitted.add(rows.length));

    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(emitted.last, 0);

    await seed('x', DateTime(2026, 5, 20, 9), 6);
    await Future<void>.delayed(const Duration(milliseconds: 100));

    expect(emitted.last, 1);
    await sub.cancel();
  });
}
