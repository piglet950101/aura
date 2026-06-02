import 'dart:convert';

import 'package:aura/data/auth/auth_repository.dart';
import 'package:aura/data/local/database.dart';
import 'package:aura/domain/hit6/hit6.dart';
import 'package:drift/drift.dart' show OrderingTerm;
import 'package:uuid/uuid.dart';

class Hit6Repository {
  Hit6Repository({
    required AuraDatabase database,
    required AuthRepository auth,
    Uuid uuid = const Uuid(),
  }) : _db = database,
       _auth = auth,
       _uuid = uuid;

  final AuraDatabase _db;
  final AuthRepository _auth;
  final Uuid _uuid;

  /// Saves a fresh submission and returns its id. The answer order matters
  /// (q1..q6) — pass them in that order so future re-categorisation can use
  /// per-question weights.
  Future<String> submit(List<Hit6Answer> answers) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Hit6Repository.submit called without a signed-in user');
    }
    if (answers.length != 6) {
      throw ArgumentError('HIT-6 needs exactly 6 answers, got ${answers.length}');
    }
    final id = _uuid.v4();
    final score = answers.fold<int>(0, (s, a) => s + a.points);
    await _db
        .into(_db.hit6Responses)
        .insert(
          Hit6ResponsesCompanion.insert(
            id: id,
            userId: user.id,
            submittedAt: DateTime.now(),
            score: score,
            responses: jsonEncode(answers.map((a) => a.code).toList()),
          ),
        );
    return id;
  }

  /// Most recent submission for the signed-in user, or null when none.
  Future<Hit6Submission?> latest() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final row =
        await (_db.select(_db.hit6Responses)
              ..where((r) => r.userId.equals(user.id))
              ..orderBy([(r) => OrderingTerm.desc(r.submittedAt)])
              ..limit(1))
            .getSingleOrNull();
    if (row == null) return null;
    return _toSubmission(row);
  }

  /// Full chronological history (oldest → newest) for the report's HIT-6
  /// evolution chart. Cheap query — a HIT-6 every 30 days for a year is just
  /// 12 rows.
  Future<List<Hit6Submission>> history() async {
    final user = _auth.currentUser;
    if (user == null) return const [];
    final rows =
        await (_db.select(_db.hit6Responses)
              ..where((r) => r.userId.equals(user.id))
              ..orderBy([(r) => OrderingTerm.asc(r.submittedAt)]))
            .get();
    return rows.map(_toSubmission).toList();
  }

  Hit6Submission _toSubmission(Hit6Response row) {
    final codes = (jsonDecode(row.responses) as List).cast<String>();
    final answers = codes.map(Hit6Answer.fromCode).whereType<Hit6Answer>().toList();
    return Hit6Submission(
      id: row.id,
      submittedAt: row.submittedAt,
      score: row.score,
      answers: answers,
    );
  }
}
