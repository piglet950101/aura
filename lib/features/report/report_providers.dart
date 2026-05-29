import 'package:aura/data/auth/auth_repository_provider.dart';
import 'package:aura/data/local/database_provider.dart';
import 'package:aura/data/report/report_repository.dart';
import 'package:aura/domain/report/report_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository(
    database: ref.watch(auraDatabaseProvider),
    auth: ref.watch(authRepositoryProvider),
  );
});

/// Selected report window in days (30 or 90).
final reportPeriodDaysProvider = StateProvider.autoDispose<int>((ref) => 30);

final reportDataProvider = FutureProvider.autoDispose<ReportData>((ref) {
  final days = ref.watch(reportPeriodDaysProvider);
  return ref.watch(reportRepositoryProvider).gather(period: Duration(days: days));
});
