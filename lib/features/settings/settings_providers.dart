import 'package:aura/data/account/account_service.dart';
import 'package:aura/data/auth/auth_repository_provider.dart';
import 'package:aura/data/local/database.dart';
import 'package:aura/data/local/database_provider.dart';
import 'package:aura/domain/profile/profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(auraDatabaseProvider));
});

final accountServiceProvider = Provider<AccountService>((ref) {
  return AccountService(
    database: ref.watch(auraDatabaseProvider),
    auth: ref.watch(authRepositoryProvider),
  );
});

/// Reactive profile for the signed-in user (null until first edited).
final profileProvider = StreamProvider.autoDispose<Profile?>((ref) {
  final db = ref.watch(auraDatabaseProvider);
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) return Stream<Profile?>.value(null);
  return db.watchProfile(user.id);
});
