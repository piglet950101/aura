// Use case: write a registered crisis to local DB and enqueue it for sync.
// ----------------------------------------------------------------------------
// The whole operation is wrapped in one Drift transaction so the crisis row
// and its m:n children + the outbox entry land atomically. If anything in
// here throws, the user sees an error toast and nothing was written — they
// can retry without dups.

import 'package:aura/data/auth/auth_repository.dart';
import 'package:aura/data/local/database.dart';
import 'package:aura/data/sync/outbox_worker.dart';
import 'package:aura/domain/crisis/crisis_draft.dart';
import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

class RegisterCrisisUseCase {
  RegisterCrisisUseCase({
    required AuraDatabase database,
    required AuthRepository auth,
    Uuid uuid = const Uuid(),
  }) : _db = database,
       _auth = auth,
       _uuid = uuid;

  final AuraDatabase _db;
  final AuthRepository _auth;
  final Uuid _uuid;

  /// Returns the new crisis id. Throws [StateError] if there is no signed-in
  /// user (which shouldn't happen post-bootstrap) and [DraftIncompleteError]
  /// if the draft has no intensity (the only mandatory field).
  Future<String> register({required CrisisDraft draft}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('RegisterCrisisUseCase called without a signed-in user');
    }
    if (!draft.isSaveable) {
      throw DraftIncompleteError('intensity is required');
    }

    final id = _uuid.v4();
    final occurredAt = (draft.occurredAt ?? DateTime.now()).toUtc();

    await _db.transaction(() async {
      await _db
          .into(_db.crises)
          .insert(
            CrisesCompanion.insert(
              id: id,
              userId: user.id,
              occurredAt: occurredAt,
              intensity: draft.intensity!,
              notes: Value(draft.notes),
            ),
          );

      for (final s in draft.symptoms) {
        await _db
            .into(_db.crisisSymptoms)
            .insert(CrisisSymptomsCompanion.insert(crisisId: id, symptom: s.code));
      }

      final t = draft.trigger;
      if (t != null) {
        await _db
            .into(_db.crisisTriggers)
            .insert(CrisisTriggersCompanion.insert(crisisId: id, trigger: t.code));
      }

      await _db.enqueueOutbox(
        entityType: OutboxEntityType.crisis,
        entityId: id,
        operation: OutboxOperation.upsert,
      );
    });

    return id;
  }
}

class DraftIncompleteError extends Error {
  DraftIncompleteError(this.message);
  final String message;
  @override
  String toString() => 'DraftIncompleteError: $message';
}
