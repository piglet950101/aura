/// Symptom codes recorded with a crisis.
///
/// The string [code] is the canonical identifier — matches the
/// `crisis_symptoms.symptom` CHECK constraint in the Supabase schema and
/// is what we send over the wire / write to the DB. [labelPt] is the
/// current presentation string; it moves into ARB files on Day 12.
enum Symptom {
  nausea('nausea', 'Náusea'),
  vomiting('vomiting', 'Vómito'),
  photophobia('photophobia', 'Sensibilidade à luz'),
  phonophobia('phonophobia', 'Sensibilidade ao som'),
  dizziness('dizziness', 'Tontura'),
  fatigue('fatigue', 'Fadiga'),
  other('other', 'Outro sintoma'),
  // Aura stays a valid symptom code (stored in crisis_symptoms) but is NOT
  // shown as a chip — the registration form asks it as a separate Sim/Não
  // question. It's last so `chips` can simply drop it.
  aura('aura', 'Aura');

  const Symptom(this.code, this.labelPt);

  final String code;
  final String labelPt;

  /// Symptoms shown as multi-select chips (everything except [aura], which
  /// has its own Sim/Não toggle in the form).
  static List<Symptom> get chips => Symptom.values.where((s) => s != Symptom.aura).toList();

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
