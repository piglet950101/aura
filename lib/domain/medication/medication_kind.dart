/// How a medication is used. Stored as the stable [code] string in both Drift
/// and Supabase (`medications.kind`), matching the CHECK constraint there.
///
/// The distinction is clinical: counting *acute* (SOS) medication days is the
/// medication-overuse-headache indicator neurologists watch, so it's surfaced
/// separately from preventive use.
enum MedicationKind {
  sos('sos', 'SOS', 'Tomada durante a crise'),
  preventive('preventive', 'Preventiva', 'Diária / preventiva');

  const MedicationKind(this.code, this.labelPt, this.descriptionPt);

  final String code;
  final String labelPt;
  final String descriptionPt;

  static MedicationKind fromCode(String code) =>
      MedicationKind.values.firstWhere((k) => k.code == code, orElse: () => MedicationKind.sos);
}
