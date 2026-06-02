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
    this.hasSosMedication = false,
  });

  final String id;
  final DateTime occurredAt;
  final int intensity;
  final String? notes;

  /// True when this crisis recorded an aura — surfaced as a ✨ on the calendar.
  final bool hasAura;

  /// True when this crisis logged a medication whose kind is SOS (or had a
  /// medication snapshot but no catalog row — assumed acute since it was
  /// taken during a crisis). Surfaced as a pill icon on the calendar cell
  /// and counted by the per-month CAM (>10 SOS days) alert.
  final bool hasSosMedication;
}
