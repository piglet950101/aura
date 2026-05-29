// Verifies ReportGenerator produces a valid, non-trivial PDF for both a
// populated and an empty period (no exceptions, real %PDF bytes).

import 'package:aura/data/report/report_generator.dart';
import 'package:aura/domain/report/report_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_PT');
  });

  ReportData populated() => ReportData(
    start: DateTime(2026, 4, 30),
    end: DateTime(2026, 5, 30),
    generatedAt: DateTime(2026, 5, 29, 12),
    patientName: 'Marta',
    birthYear: 1990,
    crises: [
      ReportCrisis(
        occurredAt: DateTime(2026, 5, 28, 9),
        intensity: 7,
        symptomCodes: const ['aura', 'nausea'],
        medications: const [ReportMedication(name: 'Sumatriptano', kind: 'sos', response: 'total')],
      ),
      ReportCrisis(
        occurredAt: DateTime(2026, 5, 25, 14),
        intensity: 3,
        symptomCodes: const ['fatigue'],
        medications: const [],
      ),
    ],
  );

  bool isPdf(List<int> bytes) =>
      bytes.length > 1000 &&
      bytes[0] == 0x25 && // %
      bytes[1] == 0x50 && // P
      bytes[2] == 0x44 && // D
      bytes[3] == 0x46; // F

  test('generates a valid PDF for a populated period', () async {
    final bytes = await const ReportGenerator().generate(populated());
    expect(isPdf(bytes), isTrue, reason: 'starts with %PDF and is non-trivial');
  });

  test('generates a valid PDF for an empty period', () async {
    final data = ReportData(
      start: DateTime(2026, 4, 30),
      end: DateTime(2026, 5, 30),
      generatedAt: DateTime(2026, 5, 29, 12),
      crises: const [],
    );
    final bytes = await const ReportGenerator().generate(data);
    expect(isPdf(bytes), isTrue);
  });
}
