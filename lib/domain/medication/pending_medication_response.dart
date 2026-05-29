/// A medication dose logged during a crisis that is now due a
/// "did it work?" answer (asked when the app reopens, ≥2h after the dose).
class PendingMedicationResponse {
  const PendingMedicationResponse({
    required this.crisisMedicationId,
    required this.crisisId,
    required this.medicationName,
    required this.takenAt,
  });

  final String crisisMedicationId;
  final String crisisId;
  final String medicationName;
  final DateTime takenAt;
}

/// The three allowed medication responses. Stored as [code] in
/// crisis_medications.response.
enum MedicationResponse {
  none('none', 'Nenhuma'),
  partial('partial', 'Parcial'),
  total('total', 'Total');

  const MedicationResponse(this.code, this.labelPt);

  final String code;
  final String labelPt;
}
