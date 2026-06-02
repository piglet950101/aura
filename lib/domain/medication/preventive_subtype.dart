/// Sub-classification of a preventive medication. Only meaningful when
/// `MedicationKind = preventive`. Drives the editor (which fields show,
/// time-of-day picker vs period picker) AND the scheduler (daily for pills,
/// monthly/quarterly one-shot recurrence for injections).
enum PreventiveSubtype {
  pill('pill'),
  injection('injection');

  const PreventiveSubtype(this.code);

  final String code;

  static PreventiveSubtype? fromCode(String? code) {
    if (code == null) return null;
    for (final s in PreventiveSubtype.values) {
      if (s.code == code) return s;
    }
    return null;
  }
}

/// Recurrence cadence for injection-type preventives. The integer is the
/// period in days, which is what the Drift column stores.
enum InjectionPeriod {
  monthly(30),
  quarterly(90);

  const InjectionPeriod(this.days);

  final int days;

  static InjectionPeriod? fromDays(int? days) {
    if (days == null) return null;
    for (final p in InjectionPeriod.values) {
      if (p.days == days) return p;
    }
    return null;
  }
}
