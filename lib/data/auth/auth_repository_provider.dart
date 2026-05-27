import 'package:aura/data/auth/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// App-wide AuthRepository, backed by the singleton SupabaseClient.
///
/// Construction is cheap — the underlying `Supabase.instance.client` must
/// already be initialized (done in bootstrap.dart). Reads outside the
/// post-init window will throw, and that's the correct behavior.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return SupabaseAuthRepository(Supabase.instance.client);
});

/// Convenience stream of the current user. UI listens to this to show
/// "you're anonymous" hints or hide upgrade prompts after sign-in.
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).watchCurrentUser();
});
