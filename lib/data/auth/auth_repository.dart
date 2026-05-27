// AURA · AuthRepository
// ----------------------------------------------------------------------------
// Thin domain-facing wrapper over Supabase auth. The whole point of going
// through this abstraction (instead of touching `Supabase.instance.client.auth`
// from widgets) is so that:
//   1. The rest of the app doesn't import `supabase_flutter` outside this dir.
//   2. We can fake auth state in tests without mocking the whole SDK.
//   3. The anon → identified upgrade has one place that owns the contract:
//      "the user.id MUST NOT change across upgrade — that's the whole reason
//      anonymous sessions are useful for offline-first work".

import 'package:supabase_flutter/supabase_flutter.dart';

/// Domain user — no Supabase types leak past this boundary.
class AppUser {
  const AppUser({required this.id, required this.isAnonymous, this.email});

  final String id;
  final String? email;
  final bool isAnonymous;

  @override
  String toString() => 'AppUser(id=$id, email=${email ?? "-"}, isAnonymous=$isAnonymous)';
}

/// Result of an attempt to upgrade an anonymous account to an identified one.
sealed class UpgradeResult {
  const UpgradeResult();
}

final class UpgradeSuccess extends UpgradeResult {
  const UpgradeSuccess({required this.user, required this.requiresEmailConfirmation});

  final AppUser user;

  /// True when the project still has email-confirmation enabled: the user's
  /// email is recorded but the row's `email_confirmed_at` is null until they
  /// click the link. The session continues to work in the meantime.
  final bool requiresEmailConfirmation;
}

final class UpgradeFailure extends UpgradeResult {
  const UpgradeFailure(this.message);
  final String message;
}

/// Result of a magic-link request — there's no "success" user yet because
/// the actual sign-in happens when the user opens the link.
sealed class MagicLinkResult {
  const MagicLinkResult();
}

final class MagicLinkSent extends MagicLinkResult {
  const MagicLinkSent();
}

final class MagicLinkFailure extends MagicLinkResult {
  const MagicLinkFailure(this.message);
  final String message;
}

abstract class AuthRepository {
  /// Current user from the last known session, or null if signed out.
  AppUser? get currentUser;

  /// Stream of user state. Emits the current value on subscribe, then
  /// every change (anon sign-in completes, upgrade lands, sign-out).
  Stream<AppUser?> watchCurrentUser();

  /// Upgrade an anonymous session to an email+password identity.
  /// **Invariant**: the resulting [AppUser.id] must equal the pre-upgrade id.
  /// Drop the result on the floor at your peril — failures must be shown to
  /// the user (e.g. "email already in use").
  Future<UpgradeResult> upgradeToEmailPassword({required String email, required String password});

  /// Same upgrade, but the user proves email ownership by clicking a link
  /// in their inbox instead of choosing a password.
  Future<MagicLinkResult> sendMagicLink({required String email});

  /// Sign out locally. The next launch will create a fresh anonymous session
  /// (zero-friction first run).
  Future<void> signOut();
}

// ---------------------------------------------------------------------------
// Supabase implementation
// ---------------------------------------------------------------------------

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  @override
  AppUser? get currentUser => _fromUser(_client.auth.currentUser);

  @override
  Stream<AppUser?> watchCurrentUser() async* {
    yield currentUser;
    yield* _client.auth.onAuthStateChange.map((event) => _fromUser(event.session?.user));
  }

  @override
  Future<UpgradeResult> upgradeToEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(email: email, password: password),
      );
      final user = response.user;
      if (user == null) {
        return const UpgradeFailure('Supabase returned no user after updateUser');
      }
      // GoTrue sets `email` immediately, sets `email_confirmed_at` only after
      // the user clicks the confirmation link (or never if mailer_autoconfirm
      // is on for this project).
      final needsConfirmation = user.emailConfirmedAt == null;
      return UpgradeSuccess(user: _fromUser(user)!, requiresEmailConfirmation: needsConfirmation);
    } on AuthException catch (e) {
      return UpgradeFailure(e.message);
    } on Object catch (e) {
      return UpgradeFailure(e.toString());
    }
  }

  @override
  Future<MagicLinkResult> sendMagicLink({required String email}) async {
    try {
      // For an already-signed-in anonymous user, `signInWithOtp` upgrades
      // the existing session in place — same user.id, just adds the email
      // identity on link-click.
      await _client.auth.signInWithOtp(email: email);
      return const MagicLinkSent();
    } on AuthException catch (e) {
      return MagicLinkFailure(e.message);
    } on Object catch (e) {
      return MagicLinkFailure(e.toString());
    }
  }

  @override
  Future<void> signOut() => _client.auth.signOut();
}

AppUser? _fromUser(User? u) {
  if (u == null) return null;
  return AppUser(id: u.id, email: u.email, isAnonymous: u.isAnonymous);
}
