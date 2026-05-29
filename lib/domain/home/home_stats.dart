/// Aggregated counts for the home-screen "Últimos 30 dias" section.
///
/// All counts are "number of distinct calendar days" within the rolling
/// 30-day window ending today (device local time). A day with two crises
/// of intensity 5 and 8 counts in BOTH `daysModerada` and `daysForte` —
/// the buckets are independent because that's how the breakdown rows
/// in the UI read.
class HomeStats {
  const HomeStats({
    required this.daysNoPain,
    required this.daysLeve,
    required this.daysModerada,
    required this.daysForte,
    required this.daysWithMedication,
    required this.daysWithSosMedication,
    required this.totalCrises,
  });

  /// Days in the last 30 with no recorded crisis. Computed as 30 minus
  /// the count of distinct days that had at least one crisis.
  final int daysNoPain;

  /// Days with at least one crisis of intensity 1..3.
  final int daysLeve;

  /// Days with at least one crisis of intensity 4..6.
  final int daysModerada;

  /// Days with at least one crisis of intensity 7..10.
  final int daysForte;

  /// Days with at least one crisis where any medication was taken.
  final int daysWithMedication;

  /// Days with at least one crisis where an *acute / SOS* medication was taken
  /// (kind = 'sos', or a since-deleted medication — assumed acute because it
  /// was logged during a crisis). This is the medication-overuse indicator
  /// neurologists watch, so it's surfaced separately from total medication use.
  final int daysWithSosMedication;

  /// Total number of crises in the window (not distinct days — every
  /// registered crisis row counts). Used to drive the empty state.
  final int totalCrises;

  static const empty = HomeStats(
    daysNoPain: 30,
    daysLeve: 0,
    daysModerada: 0,
    daysForte: 0,
    daysWithMedication: 0,
    daysWithSosMedication: 0,
    totalCrises: 0,
  );

  bool get isEmpty => totalCrises == 0;
}
