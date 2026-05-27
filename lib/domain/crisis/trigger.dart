/// Trigger codes recorded with a crisis. Same shape and rationale as
/// `Symptom` — see `symptom.dart` for the design reasoning.
enum CrisisTrigger {
  sleep('sleep', 'Sono'),
  stress('stress', 'Stress'),
  weather('weather', 'Tempo');

  const CrisisTrigger(this.code, this.labelPt);

  final String code;
  final String labelPt;

  static CrisisTrigger? fromCode(String code) {
    for (final t in CrisisTrigger.values) {
      if (t.code == code) return t;
    }
    return null;
  }
}
