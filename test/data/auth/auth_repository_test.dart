// Light tests for the AuthRepository abstraction.
//
// The Supabase concrete impl (SupabaseAuthRepository) is intentionally NOT
// unit-tested in isolation — mocking SupabaseClient.auth produces fragile
// tests that prove nothing about the real upgrade contract. The truth-source
// proof for the Supabase impl is the on-device canary in Day 4's commit
// history: it inserted a crisis tied to uid_A, ran the email upgrade, and
// confirmed uid_A still owned the same crisis afterward.
//
// What these tests cover:
//   - The AppUser value class and the UpgradeResult/MagicLinkResult sealed
//     unions behave correctly with the sealed-class exhaustive switch.
//   - A fake AuthRepository is a usable building block for higher-layer
//     tests (e.g., a future "PDF export" screen test that needs to assert
//     the upgrade flow is triggered before unlocking the share button).

import 'dart:async';

import 'package:aura/data/auth/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppUser', () {
    test('toString includes id and isAnonymous', () {
      const u = AppUser(id: 'abc', isAnonymous: true);
      expect(u.toString(), contains('abc'));
      expect(u.toString(), contains('isAnonymous=true'));
    });
  });

  group('UpgradeResult sealed switch', () {
    test('switches exhaustively over success / failure', () {
      String describe(UpgradeResult r) => switch (r) {
        UpgradeSuccess(:final user) => 'ok ${user.id}',
        UpgradeFailure(:final message) => 'fail $message',
      };

      const success = UpgradeSuccess(
        user: AppUser(id: 'u-1', email: 'm@a.dev', isAnonymous: false),
        requiresEmailConfirmation: false,
      );
      expect(describe(success), 'ok u-1');

      const failure = UpgradeFailure('email already taken');
      expect(describe(failure), 'fail email already taken');
    });
  });

  group('MagicLinkResult sealed switch', () {
    test('switches exhaustively over sent / failure', () {
      String describe(MagicLinkResult r) => switch (r) {
        MagicLinkSent() => 'sent',
        MagicLinkFailure(:final message) => 'failed: $message',
      };
      expect(describe(const MagicLinkSent()), 'sent');
      expect(describe(const MagicLinkFailure('SMTP down')), 'failed: SMTP down');
    });
  });

  group('FakeAuthRepository', () {
    test('upgrade flips isAnonymous and emits new user on the stream', () async {
      final fake = _FakeAuthRepo(initial: const AppUser(id: 'u-1', isAnonymous: true));

      // Subscribe and wait for the async* generator to attach BOTH yields
      // (the initial value AND the subscription to the underlying broadcast).
      // Without this delay, the controller.add() inside upgrade fires before
      // the listener is attached and gets dropped.
      final emitted = <AppUser?>[];
      final sub = fake.watchCurrentUser().listen(emitted.add);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final result = await fake.upgradeToEmailPassword(
        email: 'marta@aura.dev',
        password: 'hunter2',
      );

      expect(result, isA<UpgradeSuccess>());
      expect(fake.currentUser!.id, 'u-1'); // INVARIANT: id preserved
      expect(fake.currentUser!.isAnonymous, isFalse);
      expect(fake.currentUser!.email, 'marta@aura.dev');

      // Let the broadcast event fan out to our listener.
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(emitted, hasLength(2));
      expect(emitted.first?.isAnonymous, isTrue);
      expect(emitted.last?.isAnonymous, isFalse);
      expect(emitted.last?.id, 'u-1');

      await sub.cancel();
    });

    test('signOut nulls the current user', () async {
      final fake = _FakeAuthRepo(initial: const AppUser(id: 'u-1', isAnonymous: true));
      await fake.signOut();
      expect(fake.currentUser, isNull);
    });
  });
}

// ---------------------------------------------------------------------------
// Fake implementation used in these tests and re-usable by future widget
// tests (e.g. PDF export sheet) that need an injectable auth source.
// ---------------------------------------------------------------------------

class _FakeAuthRepo implements AuthRepository {
  _FakeAuthRepo({AppUser? initial}) : _current = initial;

  AppUser? _current;
  final _controller = StreamController<AppUser?>.broadcast();

  @override
  AppUser? get currentUser => _current;

  @override
  Stream<AppUser?> watchCurrentUser() async* {
    // Match the production contract: emit the latest value to new subscribers,
    // then forward every subsequent change.
    yield _current;
    yield* _controller.stream;
  }

  @override
  Future<UpgradeResult> upgradeToEmailPassword({
    required String email,
    required String password,
  }) async {
    final cur = _current;
    if (cur == null) return const UpgradeFailure('no session');
    _current = AppUser(id: cur.id, email: email, isAnonymous: false);
    _controller.add(_current);
    return UpgradeSuccess(user: _current!, requiresEmailConfirmation: false);
  }

  @override
  Future<MagicLinkResult> sendMagicLink({required String email}) async {
    return const MagicLinkSent();
  }

  @override
  Future<void> signOut() async {
    _current = null;
    _controller.add(null);
  }
}
