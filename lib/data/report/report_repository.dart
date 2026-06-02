// Gathers everything the clinical PDF report needs for a period: the user's
// crises (with symptoms + medications resolved to their kind) plus the profile.

import 'package:aura/data/auth/auth_repository.dart';
import 'package:aura/data/local/database.dart';
import 'package:aura/domain/hit6/hit6_repository.dart';
import 'package:aura/domain/report/report_data.dart';

class ReportRepository {
  ReportRepository({
    required AuraDatabase database,
    required AuthRepository auth,
    required Hit6Repository hit6,
  }) : _db = database,
       _auth = auth,
       _hit6 = hit6;

  final AuraDatabase _db;
  final AuthRepository _auth;
  final Hit6Repository _hit6;

  Future<ReportData> gather({required Duration period, DateTime? now}) async {
    final t = now ?? DateTime.now();
    // Whole local days: end = start of tomorrow (exclusive); start = period back.
    final end = DateTime(t.year, t.month, t.day).add(const Duration(days: 1));
    final start = end.subtract(period);

    final user = _auth.currentUser;
    if (user == null) {
      return ReportData(start: start, end: end, generatedAt: t, crises: const []);
    }

    final profile = await _db.getProfile(user.id);
    final medsById = {for (final m in await _db.allMedications(user.id)) m.id: m};
    final rows = await _db.crisesInRange(userId: user.id, start: start, end: end);

    Future<List<ReportCrisis>> resolve(List<Crisis> rows) async {
      final out = <ReportCrisis>[];
      for (final c in rows) {
        final symptoms = await _db.symptomsFor(c.id);
        final cms = await _db.crisisMedicationsFor(c.id);
        final meds = [
          for (final m in cms)
            ReportMedication(
              name: m.medicationNameSnapshot,
              // A since-deleted link defaults to 'sos' (logged during a crisis).
              kind: m.medicationId != null ? (medsById[m.medicationId]?.kind ?? 'sos') : 'sos',
              response: m.response,
            ),
        ];
        out.add(
          ReportCrisis(
            occurredAt: c.occurredAt.toLocal(),
            intensity: c.intensity,
            symptomCodes: symptoms,
            medications: meds,
            menstruation: c.menstruation,
          ),
        );
      }
      return out;
    }

    final crises = await resolve(rows);

    // Previous-period crises for the "vs. anterior" comparative summary.
    final prevStart = start.subtract(period);
    final prevRows = await _db.crisesInRange(userId: user.id, start: prevStart, end: start);
    final previousCrises = await resolve(prevRows);

    // Next upcoming appointment for the "Contexto de consulta" header line.
    final upcoming = await _db.allAppointments(user.id);
    ReportAppointment? next;
    for (final a in upcoming) {
      if (a.occursAt.isAfter(t)) {
        next = ReportAppointment(
          occursAt: a.occursAt,
          doctorName: a.doctorName,
          location: a.location,
        );
        break;
      }
    }

    final hit6History = await _hit6.history();
    final latestHit6 = hit6History.isEmpty ? null : hit6History.last;

    return ReportData(
      start: start,
      end: end,
      generatedAt: t,
      crises: crises,
      patientName: profile?.displayName,
      patientEmail: profile?.email,
      birthYear: profile?.birthYear,
      sex: profile?.sex,
      nextAppointment: next,
      latestHit6: latestHit6,
      hit6History: hit6History,
      previousCrises: previousCrises,
    );
  }
}
