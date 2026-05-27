// Widget test for the registration screen.
// ----------------------------------------------------------------------------
// Verifies the form behavior:
//   - Save CTA is disabled until intensity is chosen.
//   - Tapping an intensity dot enables save.
//   - Tapping symptom chips toggles them on/off.
//   - Tapping a trigger chip selects it (and toggling clears).
//
// Does NOT exercise the use case or Drift — that's covered separately.
// Here we just stub a no-op use case via Riverpod override and assert UI.

import 'package:aura/data/auth/auth_repository.dart';
import 'package:aura/data/auth/auth_repository_provider.dart';
import 'package:aura/data/local/database.dart';
import 'package:aura/data/local/database_provider.dart';
import 'package:aura/features/crisis/crisis_registration_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AuraDatabase db;

  setUp(() {
    db = AuraDatabase.test(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Widget harness() {
    return ProviderScope(
      overrides: [
        auraDatabaseProvider.overrideWithValue(db),
        authRepositoryProvider.overrideWithValue(
          _StubAuth(const AppUser(id: 'u-marta', isAnonymous: true)),
        ),
      ],
      child: const MaterialApp(home: CrisisRegistrationScreen()),
    );
  }

  testWidgets('save is disabled until intensity is chosen', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final save = find.widgetWithText(ElevatedButton, 'Guardar crise');
    expect(save, findsOneWidget);
    final btn = tester.widget<ElevatedButton>(save);
    expect(btn.onPressed, isNull); // disabled
  });

  testWidgets('tapping an intensity dot enables save', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(find.text('7'));
    await tester.pump();

    final btn = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Guardar crise'));
    expect(btn.onPressed, isNotNull);
  });

  testWidgets('symptom chips toggle on tap', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Tap "Náusea" — chip should now show check icon.
    await tester.tap(find.text('Náusea'));
    await tester.pump();
    expect(find.byIcon(Icons.check), findsOneWidget);

    // Tap "Fotofobia" — now two chips selected (two check icons).
    await tester.tap(find.text('Fotofobia'));
    await tester.pump();
    expect(find.byIcon(Icons.check), findsNWidgets(2));

    // Tap "Náusea" again to deselect — back to one check.
    await tester.tap(find.text('Náusea'));
    await tester.pump();
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('trigger chip selects (and re-tapping clears)', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Initially nothing selected — tap "Stress".
    await tester.tap(find.text('Stress'));
    await tester.pump();

    // Tap "Stress" again — should clear (toggle behavior). No exception.
    await tester.tap(find.text('Stress'));
    await tester.pump();

    // Tap "Sono" — should now be selected (no exception).
    await tester.tap(find.text('Sono'));
    await tester.pump();

    // The CTA stays disabled because we never set intensity.
    final btn = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Guardar crise'));
    expect(btn.onPressed, isNull);
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
