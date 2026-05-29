// Widget test for the Dados (statistics) screen: it renders its sections and
// charts from seeded data without throwing.

import 'package:aura/data/auth/auth_repository.dart';
import 'package:aura/data/auth/auth_repository_provider.dart';
import 'package:aura/data/local/database.dart';
import 'package:aura/data/local/database_provider.dart';
import 'package:aura/features/stats/stats_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  late AuraDatabase db;

  setUpAll(() async {
    await initializeDateFormatting('pt_PT');
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
    child: const MaterialApp(home: StatsScreen()),
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

    expect(find.text('Dados'), findsOneWidget);
    expect(find.text('CRISES POR SEMANA'), findsOneWidget);
    expect(find.text('INTENSIDADE (DIAS)'), findsOneWidget);
    expect(find.text('30 dias'), findsOneWidget);

    // The symptom section is below the fold in the lazy ListView — scroll to it.
    await tester.scrollUntilVisible(
      find.text('SINTOMAS MAIS FREQUENTES'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('SINTOMAS MAIS FREQUENTES'), findsOneWidget);
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
