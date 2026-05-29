// Captures the medication efficacy answer (none/partial/total) when the app
// reopens >= 2h after a dose — the client-chosen mechanism for question 5 of
// the crisis form. Recording the answer re-queues the crisis so the response
// syncs to Supabase via the existing setMedications path.

import 'package:aura/data/auth/auth_repository.dart';
import 'package:aura/data/local/database.dart';
import 'package:aura/data/sync/outbox_worker.dart';
import 'package:aura/domain/medication/pending_medication_response.dart';

class MedicationResponseRepository {
  MedicationResponseRepository({required AuraDatabase database, required AuthRepository auth})
    : _db = database,
      _auth = auth;

  final AuraDatabase _db;
  final AuthRepository _auth;

  /// Window bounds: ask about doses taken at least 2h ago (so the med has had
  /// time to act) and within the last 7 days (older ones aren't worth asking).
  static const askAfter = Duration(hours: 2);
  static const forgetAfter = Duration(days: 7);

  /// The most recent dose awaiting a response, or null.
  Future<PendingMedicationResponse?> nextPending({DateTime? now}) async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final t = now ?? DateTime.now();
    final list = await _db.pendingMedicationResponses(
      userId: user.id,
      notBefore: t.subtract(forgetAfter),
      notAfter: t.subtract(askAfter),
    );
    return list.isEmpty ? null : list.first;
  }

  Future<void> record({
    required PendingMedicationResponse pending,
    required MedicationResponse response,
  }) async {
    await _db.transaction(() async {
      await _db.setCrisisMedicationResponse(
        id: pending.crisisMedicationId,
        response: response.code,
      );
      await _db.enqueueOutbox(
        entityType: OutboxEntityType.crisis,
        entityId: pending.crisisId,
        operation: OutboxOperation.upsert,
      );
    });
  }
}
