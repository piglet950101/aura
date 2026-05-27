// Crisis remote data source.
// ----------------------------------------------------------------------------
// Wraps Supabase REST calls for the `crises` table. The interface is kept
// minimal so the OutboxWorker can be unit-tested with a fake implementation
// (no Supabase mock plumbing required).
//
// JSON conversion lives here, alongside the calls that use it — keeping all
// `crises` table knowledge in one file beats spreading it across mappers.

import 'package:aura/data/local/database.dart' as db;
import 'package:drift/drift.dart' show Value;
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class CrisisRemoteDataSource {
  /// Insert or update — Supabase handles the conflict on the primary key.
  Future<void> upsert(db.Crisis row);

  /// Remove by id. Idempotent — a 404 is treated as success because the row
  /// being gone is the desired end state.
  Future<void> delete(String id);

  /// Replace the symptom set for a crisis. Implemented as delete-then-insert
  /// so the client doesn't need to compute a diff; sending the desired final
  /// state is enough. RLS rejects any attempt to touch another user's crisis.
  Future<void> setSymptoms(String crisisId, Iterable<String> codes);

  /// Replace the trigger set for a crisis. Same delete-then-insert pattern
  /// as [setSymptoms]; the table currently stores at most one row per
  /// crisis in practice but the schema allows many.
  Future<void> setTriggers(String crisisId, Iterable<String> codes);

  /// Fetch every crisis updated server-side strictly after [since], for the
  /// given [userId]. RLS will only return the user's own rows even if a bug
  /// asks for someone else's.
  Future<List<db.CrisesCompanion>> fetchUpdatedAfter({
    required DateTime since,
    required String userId,
  });
}

class SupabaseCrisisRemoteDataSource implements CrisisRemoteDataSource {
  SupabaseCrisisRemoteDataSource(this._client);

  final SupabaseClient _client;

  static const _table = 'crises';

  @override
  Future<void> upsert(db.Crisis row) async {
    await _client.from(_table).upsert(_rowToJson(row));
  }

  @override
  Future<void> delete(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }

  @override
  Future<void> setSymptoms(String crisisId, Iterable<String> codes) => _replaceJoinRows(
    table: 'crisis_symptoms',
    crisisId: crisisId,
    rows: [
      for (final c in codes) {'crisis_id': crisisId, 'symptom': c},
    ],
  );

  @override
  Future<void> setTriggers(String crisisId, Iterable<String> codes) => _replaceJoinRows(
    table: 'crisis_triggers',
    crisisId: crisisId,
    rows: [
      for (final c in codes) {'crisis_id': crisisId, 'trigger': c},
    ],
  );

  Future<void> _replaceJoinRows({
    required String table,
    required String crisisId,
    required List<Map<String, dynamic>> rows,
  }) async {
    await _client.from(table).delete().eq('crisis_id', crisisId);
    if (rows.isNotEmpty) {
      await _client.from(table).insert(rows);
    }
  }

  @override
  Future<List<db.CrisesCompanion>> fetchUpdatedAfter({
    required DateTime since,
    required String userId,
  }) async {
    final rows = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .gt('updated_at', since.toUtc().toIso8601String())
        .order('updated_at');
    return rows.map(_jsonToCompanion).toList();
  }
}

Map<String, dynamic> _rowToJson(db.Crisis row) => <String, dynamic>{
  'id': row.id,
  'user_id': row.userId,
  'occurred_at': row.occurredAt.toUtc().toIso8601String(),
  'intensity': row.intensity,
  'location': row.location,
  'notes': row.notes,
  'resolved_at': row.resolvedAt?.toUtc().toIso8601String(),
  // created_at / updated_at left to server defaults / triggers
};

db.CrisesCompanion _jsonToCompanion(Map<String, dynamic> j) {
  return db.CrisesCompanion.insert(
    id: j['id'] as String,
    userId: j['user_id'] as String,
    occurredAt: DateTime.parse(j['occurred_at'] as String),
    intensity: j['intensity'] as int,
    location: Value(j['location'] as String?),
    notes: Value(j['notes'] as String?),
    resolvedAt: Value(j['resolved_at'] != null ? DateTime.parse(j['resolved_at'] as String) : null),
  );
}
