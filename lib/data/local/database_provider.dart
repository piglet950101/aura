import 'package:aura/data/local/database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App-wide Drift database singleton.
///
/// Written manually (without `@Riverpod` codegen) because the Riverpod
/// generator currently pulls a broken `analyzer_plugin` transitive — see
/// the note in `pubspec.yaml`. When that resolves, this can become an
/// `@Riverpod(keepAlive: true)` function with no behavior change.
///
/// The DB is closed when the provider container disposes (in practice,
/// only at app shutdown).
final auraDatabaseProvider = Provider<AuraDatabase>((ref) {
  final db = AuraDatabase();
  ref.onDispose(db.close);
  return db;
});
