import 'package:aura/data/auth/auth_repository_provider.dart';
import 'package:aura/data/local/database_provider.dart';
import 'package:aura/domain/home/home_stats.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reactive stream of last-30-days stats for the home dashboard. Emits
/// [HomeStats.empty] when there is no signed-in user, which lets the UI
/// render the welcoming empty state without special-casing.
final homeStatsProvider = StreamProvider<HomeStats>((ref) {
  final db = ref.watch(auraDatabaseProvider);
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) {
    return Stream<HomeStats>.value(HomeStats.empty);
  }
  return db.watchHomeStatsLast30Days(userId: user.id);
});
