import 'package:aura/domain/calendar/month_overview.dart' show IntensityTier;
import 'package:aura/domain/crisis/symptom.dart';

/// One crisis row for the clinical report. Times are local.
class ReportCrisis {
  const ReportCrisis({
    required this.occurredAt,
    required this.intensity,
    required this.symptomCodes,
    required this.medications,
  });

  final DateTime occurredAt;
  final int intensity;
  final List<String> symptomCodes;
  final List<ReportMedication> medications;

  IntensityTier get tier => IntensityTier.fromIntensity(intensity);
  bool get tookSos => medications.any((m) => m.kind == 'sos');
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
    this.birthYear,
  });

  /// Inclusive start / exclusive end of the period (local).
  final DateTime start;
  final DateTime end;
  final DateTime generatedAt;
  final List<ReportCrisis> crises;
  final String? patientName;
  final int? birthYear;

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

  bool get isEmpty => crises.isEmpty;
}

class MedicationUsage {
  MedicationUsage({required this.name});

  final String name;
  int times = 0;
  int none = 0;
  int partial = 0;
  int total = 0;
}
