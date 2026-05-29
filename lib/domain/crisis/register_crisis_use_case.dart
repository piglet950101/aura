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

      if (draft.hasMedication) {
        // Resolve the chosen medication to a catalog row. A catalog pick
        // already has an id; a preset (name only) is matched to an existing
        // active medication or created as a new SOS catalog entry so it's
        // counted in the SOS-days metric and reusable next time.
        var medId = draft.takenMedicationId;
        final medName = draft.takenMedicationName ?? 'Medicação';
        if (medId == null) {
          final existing = await _db.findActiveMedicationByName(userId: user.id, name: medName);
          if (existing != null) {
            medId = existing.id;
          } else {
            medId = _uuid.v4();
            await _db.insertMedication(
              MedicationsCompanion.insert(
                id: medId,
                userId: user.id,
                name: medName,
                doseMg: Value(draft.takenMedicationDoseMg),
                kind: const Value('sos'),
              ),
            );
            await _db.enqueueOutbox(
              entityType: OutboxEntityType.medication,
              entityId: medId,
              operation: OutboxOperation.upsert,
            );
          }
        }

        await _db.insertCrisisMedication(
          CrisisMedicationsCompanion.insert(
            id: _uuid.v4(),
            crisisId: id,
            medicationId: Value(medId),
            medicationNameSnapshot: medName,
            doseMg: Value(draft.takenMedicationDoseMg),
            takenAt: occurredAt,
          ),
        );
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
