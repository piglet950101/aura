// Doctor-appointment writes (create / edit / delete). Local-only for v1 —
// the table lives on the device and feeds the "Consulta Médica" screen.
// Add an outbox push later if multi-device sync ever becomes a requirement.

import 'package:aura/data/auth/auth_repository.dart';
import 'package:aura/data/local/database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

class AppointmentRepository {
  AppointmentRepository({
    required AuraDatabase database,
    required AuthRepository auth,
    Uuid uuid = const Uuid(),
  }) : _db = database,
       _auth = auth,
       _uuid = uuid;

  final AuraDatabase _db;
  final AuthRepository _auth;
  final Uuid _uuid;

  /// Upsert. Returns the id (newly minted when [id] is null).
  Future<String> save({
    required DateTime occursAt,
    String? id,
    String? doctorName,
    String? location,
    String? notes,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('AppointmentRepository.save called without a signed-in user');
    }
    final apptId = id ?? _uuid.v4();
    await _db.upsertAppointment(
      AppointmentsCompanion(
        id: Value(apptId),
        userId: Value(user.id),
        occursAt: Value(occursAt),
        doctorName: Value(_nullIfBlank(doctorName)),
        location: Value(_nullIfBlank(location)),
        notes: Value(_nullIfBlank(notes)),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return apptId;
  }

  Future<void> delete(String id) async {
    await _db.deleteAppointment(id);
  }

  String? _nullIfBlank(String? s) {
    final t = s?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }
}
