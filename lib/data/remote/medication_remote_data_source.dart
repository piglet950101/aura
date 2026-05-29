// Medication remote data source — same shape as crisis, different table.

import 'package:aura/data/local/database.dart' as db;
import 'package:drift/drift.dart' show Value;
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class MedicationRemoteDataSource {
  Future<void> upsert(db.Medication row);
  Future<void> delete(String id);
  Future<List<db.MedicationsCompanion>> fetchUpdatedAfter({
    required DateTime since,
    required String userId,
  });
}

class SupabaseMedicationRemoteDataSource implements MedicationRemoteDataSource {
  SupabaseMedicationRemoteDataSource(this._client);

  final SupabaseClient _client;

  static const _table = 'medications';

  @override
  Future<void> upsert(db.Medication row) async {
    await _client.from(_table).upsert(_rowToJson(row));
  }

  @override
  Future<void> delete(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }

  @override
  Future<List<db.MedicationsCompanion>> fetchUpdatedAfter({
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

Map<String, dynamic> _rowToJson(db.Medication row) => <String, dynamic>{
  'id': row.id,
  'user_id': row.userId,
  'name': row.name,
  'dose_mg': row.doseMg,
  'kind': row.kind,
  'is_default': row.isDefault,
  'archived': row.archived,
};

db.MedicationsCompanion _jsonToCompanion(Map<String, dynamic> j) {
  return db.MedicationsCompanion.insert(
    id: j['id'] as String,
    userId: j['user_id'] as String,
    name: j['name'] as String,
    doseMg: Value(j['dose_mg'] != null ? (j['dose_mg'] as num).toDouble() : null),
    kind: Value(j['kind'] as String? ?? 'sos'),
    isDefault: Value(j['is_default'] as bool? ?? false),
    archived: Value(j['archived'] as bool? ?? false),
  );
}
