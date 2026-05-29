// Medication catalog writes — create / edit / archive, each in one Drift
// transaction that also enqueues the sync outbox entry.
//
// The "one default per user" invariant is enforced here AND must survive sync:
// Supabase has a partial unique index (one is_default=true per user). So when
// a medication is promoted to default, any previous default is demoted *and*
// its upsert is enqueued BEFORE the new default's. The outbox drains FIFO, so
// the server clears the old default first and never trips the unique index.

import 'package:aura/data/auth/auth_repository.dart';
import 'package:aura/data/local/database.dart';
import 'package:aura/data/sync/outbox_worker.dart';
import 'package:aura/domain/medication/medication_kind.dart';
import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

class MedicationRepository {
  MedicationRepository({
    required AuraDatabase database,
    required AuthRepository auth,
    Uuid uuid = const Uuid(),
  }) : _db = database,
       _auth = auth,
       _uuid = uuid;

  final AuraDatabase _db;
  final AuthRepository _auth;
  final Uuid _uuid;

  /// Creates a new medication (when [id] is null) or updates an existing one.
  /// Returns the medication id. Throws [StateError] if no user is signed in.
  Future<String> save({
    required String name,
    required MedicationKind kind,
    required bool isDefault,
    String? id,
    double? doseMg,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('MedicationRepository.save called without a signed-in user');
    }
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('medication name cannot be empty');
    }

    final medId = id ?? _uuid.v4();

    await _db.transaction(() async {
      if (isDefault) {
        // Demote any other current default and queue its sync FIRST so the
        // server clears it before the new default upsert (unique-index safe).
        final demoted = await _db.demoteOtherDefaultMedications(userId: user.id, exceptId: medId);
        for (final demotedId in demoted) {
          await _db.enqueueOutbox(
            entityType: OutboxEntityType.medication,
            entityId: demotedId,
            operation: OutboxOperation.upsert,
          );
        }
      }

      final existing = await _db.findMedication(medId);
      if (existing == null) {
        await _db.insertMedication(
          MedicationsCompanion.insert(
            id: medId,
            userId: user.id,
            name: trimmed,
            doseMg: Value(doseMg),
            kind: Value(kind.code),
            isDefault: Value(isDefault),
          ),
        );
      } else {
        await _db.updateMedicationFields(
          id: medId,
          name: trimmed,
          doseMg: doseMg,
          kind: kind.code,
          isDefault: isDefault,
        );
      }

      await _db.enqueueOutbox(
        entityType: OutboxEntityType.medication,
        entityId: medId,
        operation: OutboxOperation.upsert,
      );
    });

    return medId;
  }

  /// Soft-deletes a medication: archived rows leave the active list / pickers
  /// but stay so historical crisis_medications keep a real reference. An
  /// archived medication can never remain the default.
  Future<void> archive(String id) async {
    await _db.transaction(() async {
      await _db.archiveMedicationById(id);
      await _db.enqueueOutbox(
        entityType: OutboxEntityType.medication,
        entityId: id,
        operation: OutboxOperation.upsert,
      );
    });
  }
}
