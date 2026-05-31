import 'package:aura/data/auth/auth_repository_provider.dart';
import 'package:aura/data/local/database.dart';
import 'package:aura/data/local/database_provider.dart';
import 'package:aura/domain/appointment/appointment_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  return AppointmentRepository(
    database: ref.watch(auraDatabaseProvider),
    auth: ref.watch(authRepositoryProvider),
  );
});

/// Reactive list of the signed-in user's appointments, chronologically ascending.
/// The UI splits "próximas" (>= now) from "passadas" (< now) without a second
/// query — one stream, two sections, recomputed when the table changes.
final appointmentsProvider = StreamProvider.autoDispose<List<Appointment>>((ref) {
  final db = ref.watch(auraDatabaseProvider);
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) {
    return Stream<List<Appointment>>.value(const <Appointment>[]);
  }
  return db.watchAppointments(user.id);
});
