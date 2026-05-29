import 'package:aura/data/auth/auth_repository_provider.dart';
import 'package:aura/data/local/database_provider.dart';
import 'package:aura/domain/calendar/month_overview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The month currently shown in the calendar (first-of-month, local time).
/// The ‹ › nav and swipe gestures write to this; the overview stream watches
/// it. Defaults to the current month.
final calendarMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

/// Reactive [MonthOverview] for [calendarMonthProvider]. Re-emits whenever a
/// crisis is added/removed (Drift table watch) so registering from the day
/// sheet updates the grid without manual refresh.
final monthOverviewProvider = StreamProvider.autoDispose<MonthOverview>((ref) {
  final db = ref.watch(auraDatabaseProvider);
  final user = ref.watch(authRepositoryProvider).currentUser;
  final month = ref.watch(calendarMonthProvider);

  if (user == null) {
    return Stream<MonthOverview>.value(MonthOverview.empty(month));
  }

  // Over-fetch by one day each side so a crisis logged near local midnight
  // (whose UTC instant may land in an adjacent day) is still considered; the
  // overview trims to the exact month after binning by local day.
  final start = DateTime(month.year, month.month).subtract(const Duration(days: 1));
  final end = DateTime(month.year, month.month + 1).add(const Duration(days: 1));

  return db
      .watchCrisisSummariesInRange(userId: user.id, start: start, end: end)
      .map((summaries) => MonthOverview.fromCrises(month: month, crises: summaries));
});
