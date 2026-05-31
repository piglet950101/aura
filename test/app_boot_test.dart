// Boot smoke test for the AURA app.
//
// Validates that:
//   - the app builds and renders without throwing
//   - the home screen mounts under the dark theme
//   - design-token-driven elements are present
//
// Drift + auth providers are overridden so the test doesn't need
// platform channels (path_provider, Supabase init, etc.).

import 'package:aura/app/app.dart';
import 'package:aura/core/theme/aura_colors.dart';
import 'package:aura/data/auth/auth_repository.dart';
import 'package:aura/data/auth/auth_repository_provider.dart';
import 'package:aura/data/local/database.dart';
import 'package:aura/data/local/database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  late AuraDatabase db;

  setUpAll(() async {
    // The home-screen greeting uses DateFormat for the active locale; production
    // code initializes this in bootstrap.dart. Tests pump AuraApp directly so
    // we have to do the same once before any test runs. Initialize all locales
    // since the app can switch language at runtime.
    await initializeDateFormatting();
  });

  setUp(() {
    db = AuraDatabase.test(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Widget appHarness() => ProviderScope(
    overrides: [
      auraDatabaseProvider.overrideWithValue(db),
      authRepositoryProvider.overrideWithValue(
        _StubAuth(const AppUser(id: 'u-test', isAnonymous: true)),
      ),
    ],
    child: const AuraApp(),
  );

  // Drift's StreamQuery schedules a `Timer.run` cleanup when its
  // subscription is cancelled (on widget tree disposal). Flutter's test
  // framework asserts no pending timers immediately after the test body
  // completes — so we have to dispose the tree and pump inside the body
  // to let that 0-duration timer fire.
  Future<void> teardownTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('AURA app boots and renders the home dashboard', (tester) async {
    await tester.pumpWidget(appHarness());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Brand mark in the top bar.
    expect(find.text('AURA'), findsOneWidget);

    // Empty-state copy appears because no crises were seeded.
    expect(find.text('Bem-vindo'), findsOneWidget);

    // CTA on the bottom bar.
    expect(find.text('Registar crise'), findsOneWidget);

    // Dark theme + scaffold background token applied.
    final theme = Theme.of(tester.element(find.byType(Scaffold)));
    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, AuraColors.bgBase);

    await teardownTree(tester);
  });

  testWidgets('CTA buttons respect 56dp minimum tap target via theme', (tester) async {
    await tester.pumpWidget(appHarness());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final theme = Theme.of(tester.element(find.byType(ElevatedButton).first));
    final minHeight = theme.elevatedButtonTheme.style?.minimumSize
        ?.resolve(<WidgetState>{})
        ?.height;
    expect(minHeight, isNotNull);
    expect(minHeight, greaterThanOrEqualTo(56));

    final outlinedMin = theme.outlinedButtonTheme.style?.minimumSize
        ?.resolve(<WidgetState>{})
        ?.height;
    expect(outlinedMin, greaterThanOrEqualTo(56));

    await teardownTree(tester);
  });
}

class _StubAuth implements AuthRepository {
  _StubAuth(this._user);
  final AppUser _user;

  @override
  AppUser? get currentUser => _user;

  @override
  Stream<AppUser?> watchCurrentUser() async* {
    yield _user;
  }

  @override
  Future<UpgradeResult> upgradeToEmailPassword({
    required String email,
    required String password,
  }) async => const UpgradeFailure('not used');

  @override
  Future<MagicLinkResult> sendMagicLink({required String email}) async => const MagicLinkSent();

  @override
  Future<void> signOut() async {}
}
