/// Symptom codes recorded with a crisis.
///
/// The string [code] is the canonical identifier — matches the
/// `crisis_symptoms.symptom` CHECK constraint in the Supabase schema and
/// is what we send over the wire / write to the DB. [labelPt] is the
/// current presentation string; it moves into ARB files on Day 12.
enum Symptom {
  nausea('nausea', 'Náusea'),
  photophobia('photophobia', 'Fotofobia'),
  phonophobia('phonophobia', 'Som'),
  aura('aura', 'Aura'),
  vomiting('vomiting', 'Vómito'),
  dizziness('dizziness', 'Tontura');

  const Symptom(this.code, this.labelPt);

  final String code;
  final String labelPt;

  /// Parses a stored DB / server code back to the enum, or null if
  /// it's something we no longer surface (e.g. 'tingling' which exists
  /// in the schema but isn't a chip in v1).
  static Symptom? fromCode(String code) {
    for (final s in Symptom.values) {
      if (s.code == code) return s;
    }
    return null;
  }
}
