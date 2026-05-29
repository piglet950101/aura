import 'package:aura/domain/report/report_data.dart';
import 'package:aura/features/report/report_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The Dados (in-app statistics) screen reuses the report's data gathering with
/// its own period selection so it doesn't fight the report screen's state.
final statsPeriodDaysProvider = StateProvider.autoDispose<int>((ref) => 30);

final statsDataProvider = FutureProvider.autoDispose<ReportData>((ref) {
  final days = ref.watch(statsPeriodDaysProvider);
  return ref.watch(reportRepositoryProvider).gather(period: Duration(days: days));
});
