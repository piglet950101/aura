// Profile is stored locally (it feeds the PDF report header and Settings).
// Multi-device sync is an explicit MVP non-goal, so this isn't pushed through
// the outbox yet — it can be later with the same pattern as medications.

import 'package:aura/data/local/database.dart';
import 'package:drift/drift.dart' show Value;

class ProfileRepository {
  ProfileRepository(this._db);

  final AuraDatabase _db;

  Future<void> save({required String userId, String? displayName, int? birthYear, String? sex}) {
    final name = displayName?.trim();
    return _db.upsertProfile(
      ProfilesCompanion(
        id: Value(userId),
        displayName: Value(name == null || name.isEmpty ? null : name),
        birthYear: Value(birthYear),
        sex: Value(sex),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
