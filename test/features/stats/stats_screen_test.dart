// Widget test for the Dados (statistics) screen: it renders its sections and
// charts from seeded data without throwing.

import 'package:aura/data/auth/auth_repository.dart';
import 'package:aura/data/auth/auth_repository_provider.dart';
import 'package:aura/data/local/database.dart';
import 'package:aura/data/local/database_provider.dart';
import 'package:aura/features/stats/stats_screen.dart';
import 'package:aura/l10n/app_l10n.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  late AuraDatabase db;

  setUpAll(() async {
    await initializeDateFormatting();
  });

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
      home: StatsScreen(),
    ),
  );

  testWidgets('renders stat sections from seeded data', (tester) async {
    await db.insertCrisis(
      CrisesCompanion.insert(
        id: 'c1',
        userId: 'u-marta',
        occurredAt: DateTime.now().subtract(const Duration(days: 2)),
        intensity: 7,
      ),
    );
    await db
        .into(db.crisisSymptoms)
        .insert(CrisisSymptomsCompanion.insert(crisisId: 'c1', symptom: 'nausea'));

    await tester.pumpWidget(harness());
    await tester.pump(); // resolve the FutureProvider
    await tester.pump(const Duration(milliseconds: 100));

    // Title renamed in the final spec round (Dados → Estatísticas).
    expect(find.text('Estatísticas'), findsOneWidget);

    // The Wave 5 rewrite restructured the page into 5 section headers
    // (uppercased) with chart cards (sentence-case titles) beneath.
    expect(find.text('EVOLUÇÃO E IMPACTO'), findsOneWidget);
    expect(find.text('Crises por semana'), findsOneWidget);

    // Period chip is now compact ("30d" instead of "30 dias").
    expect(find.text('30d'), findsOneWidget);

    // The symptom card is below the fold in the lazy ListView — scroll until
    // either the SEVERIDADE header or the symptom card title is visible.
    await tester.scrollUntilVisible(
      find.text('Sintomas mais frequentes'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Sintomas mais frequentes'), findsOneWidget);
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
