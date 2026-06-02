import 'package:aura/domain/calendar/month_overview.dart' show IntensityTier;
import 'package:aura/domain/crisis/symptom.dart';
import 'package:aura/domain/hit6/hit6.dart';

/// One crisis row for the clinical report. Times are local.
class ReportCrisis {
  const ReportCrisis({
    required this.occurredAt,
    required this.intensity,
    required this.symptomCodes,
    required this.medications,
    this.menstruation,
  });

  final DateTime occurredAt;
  final int intensity;
  final List<String> symptomCodes;
  final List<ReportMedication> medications;
  final bool? menstruation;

  IntensityTier get tier => IntensityTier.fromIntensity(intensity);
  bool get tookSos => medications.any((m) => m.kind == 'sos');
  bool get hasAura => symptomCodes.contains('aura');
}

/// A medication logged on a crisis, with its kind and the user's response.
class ReportMedication {
  const ReportMedication({required this.name, required this.kind, this.response});

  final String name;
  final String kind; // 'sos' | 'preventive'
  final String? response; // 'none' | 'partial' | 'total' | null
}

/// Everything the PDF generator needs for one report period. Stats are computed
/// here so the generator stays pure layout.
class ReportData {
  ReportData({
    required this.start,
    required this.end,
    required this.generatedAt,
    required this.crises,
    this.patientName,
    this.patientEmail,
    this.birthYear,
    this.sex,
    this.nextAppointment,
    this.latestHit6,
    this.hit6History = const [],
    this.previousCrises = const [],
  });

  /// Inclusive start / exclusive end of the period (local).
  final DateTime start;
  final DateTime end;
  final DateTime generatedAt;
  final List<ReportCrisis> crises;
  final String? patientName;
  final String? patientEmail;
  final int? birthYear;

  /// 'f' / 'm' / 'other' / 'na' / null. Drives the gender-conditional fields
  /// in the report header (and on screen — see crisis form).
  final String? sex;

  /// First upcoming appointment after [generatedAt], if any — surfaced in
  /// the report's "Contexto de consulta" line so the doctor sees when the
  /// patient is bringing this in.
  final ReportAppointment? nextAppointment;

  /// Most recent HIT-6 submission, used in the score card on the report.
  final Hit6Submission? latestHit6;

  /// Full HIT-6 history (oldest → newest) for the evolution sparkline.
  final List<Hit6Submission> hit6History;

  /// Crises of the immediately preceding window of the same length, used by
  /// the "vs. anterior" comparative summary. Empty when no prior crises.
  final List<ReportCrisis> previousCrises;

  int get periodDays => end.difference(start).inDays;

  int? get age => birthYear == null ? null : generatedAt.year - birthYear!;

  int get totalCrises => crises.length;

  Iterable<DateTime> get _days =>
      crises.map((c) => DateTime(c.occurredAt.year, c.occurredAt.month, c.occurredAt.day));

  int get affectedDays => _days.toSet().length;

  int get daysNoPain => (periodDays - affectedDays).clamp(0, periodDays);

  double? get averageIntensity {
    if (crises.isEmpty) return null;
    final sum = crises.fold<int>(0, (s, c) => s + c.intensity);
    return sum / crises.length;
  }

  int _tierDays(IntensityTier tier) {
    final days = <DateTime>{};
    for (final c in crises) {
      if (c.tier == tier) {
        days.add(DateTime(c.occurredAt.year, c.occurredAt.month, c.occurredAt.day));
      }
    }
    return days.length;
  }

  int get daysLeve => _tierDays(IntensityTier.low);
  int get daysModerada => _tierDays(IntensityTier.med);
  int get daysForte => _tierDays(IntensityTier.high);

  /// Distinct days with an acute (SOS) medication — the overuse indicator.
  int get sosDays {
    final days = <DateTime>{};
    for (final c in crises) {
      if (c.tookSos) {
        days.add(DateTime(c.occurredAt.year, c.occurredAt.month, c.occurredAt.day));
      }
    }
    return days.length;
  }

  /// Symptom → count across all crises, most frequent first.
  List<MapEntry<Symptom, int>> get symptomFrequency {
    final counts = <Symptom, int>{};
    for (final c in crises) {
      for (final code in c.symptomCodes) {
        final s = Symptom.fromCode(code);
        if (s != null) counts[s] = (counts[s] ?? 0) + 1;
      }
    }
    final entries = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  /// Medication name → usage summary (times taken + response breakdown).
  List<MedicationUsage> get medicationUsage {
    final byName = <String, MedicationUsage>{};
    for (final c in crises) {
      for (final m in c.medications) {
        final u = byName.putIfAbsent(m.name, () => MedicationUsage(name: m.name));
        u.times++;
        switch (m.response) {
          case 'none':
            u.none++;
          case 'partial':
            u.partial++;
          case 'total':
            u.total++;
        }
      }
    }
    final list = byName.values.toList()..sort((a, b) => b.times.compareTo(a.times));
    return list;
  }

  /// Crises grouped into consecutive 7-day buckets from [start], oldest first.
  /// Drives the "crises por semana" bar chart on the Dados screen.
  List<int> get crisesPerWeek {
    final weeks = (periodDays / 7).ceil().clamp(1, 53);
    final counts = List<int>.filled(weeks, 0);
    for (final c in crises) {
      final dayIndex = c.occurredAt.difference(start).inDays;
      if (dayIndex < 0) continue;
      counts[(dayIndex ~/ 7).clamp(0, weeks - 1)]++;
    }
    return counts;
  }

  /// Day-of-week → mean intensity of crises that occurred on that weekday.
  /// Mon=1..Sun=7 to match `DateTime.weekday`. NaN-safe: a weekday with no
  /// crises maps to 0 (the heat map renders these as empty cells).
  Map<int, double> get intensityByWeekday {
    final sums = <int, int>{};
    final counts = <int, int>{};
    for (final c in crises) {
      final w = c.occurredAt.weekday;
      sums[w] = (sums[w] ?? 0) + c.intensity;
      counts[w] = (counts[w] ?? 0) + 1;
    }
    final out = <int, double>{};
    for (var w = 1; w <= 7; w++) {
      final n = counts[w] ?? 0;
      out[w] = n == 0 ? 0 : (sums[w]! / n);
    }
    return out;
  }

  /// Distinct days with at least one crisis that recorded `menstruation = true`.
  int get daysWithMenstruation {
    final days = <DateTime>{};
    for (final c in crises) {
      if (c.menstruation ?? false) {
        days.add(DateTime(c.occurredAt.year, c.occurredAt.month, c.occurredAt.day));
      }
    }
    return days.length;
  }

  /// Distinct days with at least one aura crisis.
  int get auraDays {
    final days = <DateTime>{};
    for (final c in crises) {
      if (c.hasAura) {
        days.add(DateTime(c.occurredAt.year, c.occurredAt.month, c.occurredAt.day));
      }
    }
    return days.length;
  }

  bool get isEmpty => crises.isEmpty;
}

/// Lightweight appointment snapshot the report carries — kept independent of
/// the Drift row class so the domain layer doesn't depend on persistence.
class ReportAppointment {
  const ReportAppointment({required this.occursAt, this.doctorName, this.location});

  final DateTime occursAt;
  final String? doctorName;
  final String? location;
}

class MedicationUsage {
  MedicationUsage({required this.name});

  final String name;
  int times = 0;
  int none = 0;
  int partial = 0;
  int total = 0;
}
