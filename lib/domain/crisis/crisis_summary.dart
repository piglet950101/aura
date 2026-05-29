/// A read-model of a crisis for list / calendar surfaces.
///
/// Deliberately decoupled from the Drift `Crisis` row class so the calendar
/// and (Day 9) detail features depend on the domain, not the persistence
/// layer. The mapping from a Drift row lives in the feature provider.
///
/// [occurredAt] is in **device local time** — the calendar bins crises by the
/// day the user perceived them, which is the local calendar day.
class CrisisSummary {
  const CrisisSummary({
    required this.id,
    required this.occurredAt,
    required this.intensity,
    this.notes,
    this.hasAura = false,
  });

  final String id;
  final DateTime occurredAt;
  final int intensity;
  final String? notes;

  /// True when this crisis recorded an aura — surfaced as a ✨ on the calendar.
  final bool hasAura;
}
