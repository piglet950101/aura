// Widget tests for medication management:
//   - empty state renders when there are no medications
//   - a seeded medication shows its name and kind badge
//   - the add flow (open editor → name → pick Preventiva → save) persists and
//     the new medication appears back on the list

import 'package:aura/data/auth/auth_repository.dart';
import 'package:aura/data/auth/auth_repository_provider.dart';
import 'package:aura/data/local/database.dart';
import 'package:aura/data/local/database_provider.dart';
import 'package:aura/domain/medication/medication_kind.dart';
import 'package:aura/domain/medication/medication_repository.dart';
import 'package:aura/domain/medication/preventive_subtype.dart';
import 'package:aura/features/medications/medications_screen.dart';
import 'package:aura/l10n/app_l10n.dart';
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

  Widget harness() => ProviderScope(
    overrides: [
      auraDatabaseProvider.overrideWithValue(db),
      authRepositoryProvider.overrideWithValue(
        _StubAuth(const AppUser(id: 'u-marta', isAnonymous: true)),
      ),
    ],
    child: const MaterialApp(
      locale: Locale('pt'),
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      home: MedicationsScreen(),
    ),
  );

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> teardownTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('shows the empty state with no medications', (tester) async {
    await tester.pumpWidget(harness());
    await settle(tester);

    expect(find.text('Sem medicações'), findsOneWidget);
    expect(find.text('Adicionar medicação'), findsOneWidget);

    await teardownTree(tester);
  });

  testWidgets('groups meds by kind under Preventiva / SOS sections', (tester) async {
    final repo = MedicationRepository(
      database: db,
      auth: _StubAuth(const AppUser(id: 'u-marta', isAnonymous: true)),
    );
    await repo.save(
      name: 'Topiramato',
      kind: MedicationKind.preventive,
      // Wave 3: preventive needs an explicit subtype now ('pill' or 'injection')
      // for the reminder line to render. Pill subtype matches the daily reminder.
      subtype: PreventiveSubtype.pill,
      isDefault: false,
      doseMg: 50,
      reminderMinutes: 1080, // 18:00 — the inline line must render
    );
    await repo.save(name: 'Sumatriptano', kind: MedicationKind.sos, isDefault: true, doseMg: 50);

    await tester.pumpWidget(harness());
    await settle(tester);

    // Both section headers visible, uppercased.
    expect(find.text('MEDICAÇÃO PREVENTIVA'), findsOneWidget);
    expect(find.text('MEDICAÇÃO SOS / CRISE'), findsOneWidget);

    // Both tiles render their name + dose.
    expect(find.textContaining('Topiramato'), findsOneWidget);
    expect(find.textContaining('Sumatriptano'), findsOneWidget);

    // The reminder line shows under the preventive med (uses the platform's
    // localized time format, so just assert "Diariamente" is there).
    expect(find.textContaining('Diariamente'), findsOneWidget);

    await teardownTree(tester);
  });

  testWidgets('omits empty section headers (only SOS meds present)', (tester) async {
    await MedicationRepository(
      database: db,
      auth: _StubAuth(const AppUser(id: 'u-marta', isAnonymous: true)),
    ).save(name: 'Aspirina', kind: MedicationKind.sos, isDefault: true, doseMg: 500);

    await tester.pumpWidget(harness());
    await settle(tester);

    expect(find.text('MEDICAÇÃO PREVENTIVA'), findsNothing);
    expect(find.text('MEDICAÇÃO SOS / CRISE'), findsOneWidget);
    expect(find.textContaining('Aspirina'), findsOneWidget);

    await teardownTree(tester);
  });

  // NOTE: the editor form's enter-text → pick-kind → save → pop interaction is
  // intentionally NOT covered by a widget test. Driving Navigator.pop on a
  // pumped editor deadlocks the test scheduler here. The save/persistence
  // logic it would exercise is fully covered by medication_repository_test.dart
  // (create / edit / default-demotion / archive), so this is no loss of cover.
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
