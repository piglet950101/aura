import 'package:aura/data/auth/auth_repository_provider.dart';
import 'package:aura/data/local/database_provider.dart';
import 'package:aura/domain/hit6/hit6.dart';
import 'package:aura/domain/hit6/hit6_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final hit6RepositoryProvider = Provider<Hit6Repository>((ref) {
  return Hit6Repository(
    database: ref.watch(auraDatabaseProvider),
    auth: ref.watch(authRepositoryProvider),
  );
});

/// Most-recent HIT-6 submission for the signed-in user, refreshed when a new
/// one is submitted via `ref.invalidate(latestHit6Provider)`.
final latestHit6Provider = FutureProvider.autoDispose<Hit6Submission?>((ref) {
  return ref.watch(hit6RepositoryProvider).latest();
});

/// Full chronological history — drives the report's evolution chart.
final hit6HistoryProvider = FutureProvider.autoDispose<List<Hit6Submission>>((ref) {
  return ref.watch(hit6RepositoryProvider).history();
});
