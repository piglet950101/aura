// Use case: create / edit / delete a registered crisis in the local DB and
// enqueue it for sync.
// ----------------------------------------------------------------------------
// Each operation is wrapped in one Drift transaction so the crisis row, its
// m:n children, and the outbox entry land atomically. If anything throws, the
// user sees an error and nothing was written — they can retry without dups.

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
    final user = _requireUser();
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

      if (draft.hasMedication) {
        final medId = await _resolveMedicationId(userId: user.id, draft: draft);
        await _db.insertCrisisMedication(
          CrisisMedicationsCompanion.insert(
            id: _uuid.v4(),
            crisisId: id,
            medicationId: Value(medId),
            medicationNameSnapshot: draft.takenMedicationName ?? 'Medicação',
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

  /// Edits an existing crisis. Symptoms and medication are replaced to match
  /// the draft; a previously recorded medication response is preserved when the
  /// same medication is kept. Re-queues the crisis so the new state syncs.
  Future<void> update({required String crisisId, required CrisisDraft draft}) async {
    final user = _requireUser();
    if (!draft.isSaveable) {
      throw DraftIncompleteError('intensity is required');
    }
    final occurredAt = (draft.occurredAt ?? DateTime.now()).toUtc();

    await _db.transaction(() async {
      await _db.updateCrisisFields(
        id: crisisId,
        occurredAt: occurredAt,
        intensity: draft.intensity!,
        notes: draft.notes,
      );

      await _db.deleteSymptomsFor(crisisId);
      for (final s in draft.symptoms) {
        await _db
            .into(_db.crisisSymptoms)
            .insert(CrisisSymptomsCompanion.insert(crisisId: crisisId, symptom: s.code));
      }

      // Replace the medication. Capture the prior row first so a recorded
      // response/relief survives an edit that keeps the same medication.
      final existing = await _db.crisisMedicationsFor(crisisId);
      await _db.deleteCrisisMedicationsFor(crisisId);
      if (draft.hasMedication) {
        final medId = await _resolveMedicationId(userId: user.id, draft: draft);
        CrisisMedication? prior;
        for (final m in existing) {
          if (m.medicationId == medId) {
            prior = m;
            break;
          }
        }
        await _db.insertCrisisMedication(
          CrisisMedicationsCompanion.insert(
            id: prior?.id ?? _uuid.v4(),
            crisisId: crisisId,
            medicationId: Value(medId),
            medicationNameSnapshot: draft.takenMedicationName ?? 'Medicação',
            doseMg: Value(draft.takenMedicationDoseMg),
            takenAt: occurredAt,
            reliefAt: Value(prior?.reliefAt),
            effective: Value(prior?.effective),
            response: Value(prior?.response),
          ),
        );
      }

      await _db.enqueueOutbox(
        entityType: OutboxEntityType.crisis,
        entityId: crisisId,
        operation: OutboxOperation.upsert,
      );
    });
  }

  /// Deletes a crisis. Local FK cascade removes its symptoms / medications; the
  /// outbox delete makes the server cascade too.
  Future<void> delete({required String crisisId}) async {
    await _db.transaction(() async {
      await _db.deleteCrisis(crisisId);
      await _db.enqueueOutbox(
        entityType: OutboxEntityType.crisis,
        entityId: crisisId,
        operation: OutboxOperation.delete,
      );
    });
  }

  AppUser _requireUser() {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('RegisterCrisisUseCase called without a signed-in user');
    }
    return user;
  }

  /// Resolves the draft's medication to a catalog id. A catalog pick already
  /// has an id; a preset (name only) is matched to an existing active
  /// medication or created as a new SOS catalog entry (and queued for sync) so
  /// it counts toward the SOS-days metric and is reusable next time.
  Future<String> _resolveMedicationId({required String userId, required CrisisDraft draft}) async {
    final existingId = draft.takenMedicationId;
    if (existingId != null) return existingId;

    final name = draft.takenMedicationName ?? 'Medicação';
    final existing = await _db.findActiveMedicationByName(userId: userId, name: name);
    if (existing != null) return existing.id;

    final medId = _uuid.v4();
    await _db.insertMedication(
      MedicationsCompanion.insert(
        id: medId,
        userId: userId,
        name: name,
        doseMg: Value(draft.takenMedicationDoseMg),
        kind: const Value('sos'),
      ),
    );
    await _db.enqueueOutbox(
      entityType: OutboxEntityType.medication,
      entityId: medId,
      operation: OutboxOperation.upsert,
    );
    return medId;
  }
}

class DraftIncompleteError extends Error {
  DraftIncompleteError(this.message);
  final String message;
  @override
  String toString() => 'DraftIncompleteError: $message';
}
