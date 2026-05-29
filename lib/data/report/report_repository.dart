// Gathers everything the clinical PDF report needs for a period: the user's
// crises (with symptoms + medications resolved to their kind) plus the profile.

import 'package:aura/data/auth/auth_repository.dart';
import 'package:aura/data/local/database.dart';
import 'package:aura/domain/report/report_data.dart';

class ReportRepository {
  ReportRepository({required AuraDatabase database, required AuthRepository auth})
    : _db = database,
      _auth = auth;

  final AuraDatabase _db;
  final AuthRepository _auth;

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

    final crises = <ReportCrisis>[];
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
      crises.add(
        ReportCrisis(
          occurredAt: c.occurredAt.toLocal(),
          intensity: c.intensity,
          symptomCodes: symptoms,
          medications: meds,
        ),
      );
    }

    return ReportData(
      start: start,
      end: end,
      generatedAt: t,
      crises: crises,
      patientName: profile?.displayName,
      birthYear: profile?.birthYear,
    );
  }
}
