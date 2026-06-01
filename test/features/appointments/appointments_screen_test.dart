// Widget tests for the Consulta Médica hub layout (Marcelo's mockup):
//   - empty próxima collapses into a friendly Agendar card + button
//   - a seeded upcoming + past pair renders BOTH sections plus the
//     "Relatório para o médico" tiles (PDF + Código de Acesso Web)
//   - tapping the web-access tile shows the "Em breve" SnackBar (proves the
//     placeholder is wired but harmless — no crash, no broken nav)

import 'package:aura/data/auth/auth_repository.dart';
import 'package:aura/data/auth/auth_repository_provider.dart';
import 'package:aura/data/local/database.dart';
import 'package:aura/data/local/database_provider.dart';
import 'package:aura/features/appointments/appointments_screen.dart';
import 'package:aura/l10n/app_l10n.dart';
import 'package:drift/drift.dart' show Value;
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
      home: AppointmentsScreen(),
    ),
  );

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> teardownTree(WidgetTester tester) async {
    // The appointments stream cancels on dispose; pump to drain its 0-tick
    // cleanup timer before the no-pending-timers invariant runs.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> seed(String id, DateTime when, {String? doctor, String? location}) {
    return db.upsertAppointment(
      AppointmentsCompanion(
        id: Value(id),
        userId: const Value('u-marta'),
        occursAt: Value(when),
        doctorName: Value(doctor),
        location: Value(location),
      ),
    );
  }

  testWidgets('empty state shows the friendly Agendar card + button', (tester) async {
    await tester.pumpWidget(harness());
    await settle(tester);

    // Section headers are uppercased by the layout.
    expect(find.text('PRÓXIMA CONSULTA'), findsOneWidget);
    expect(find.text('RELATÓRIO PARA O MÉDICO'), findsOneWidget);

    // Empty hint copy + the inline button. Histórico section is omitted
    // when there are no past appointments — matches the mockup intent of
    // not showing empty sections.
    expect(find.text('Adiciona a próxima consulta para a teres à mão.'), findsOneWidget);
    expect(find.text('HISTÓRICO'), findsNothing);
    expect(find.widgetWithText(OutlinedButton, 'Agendar'), findsOneWidget);

    // Both report-section tiles are present (PDF + Web Access Code).
    expect(find.text('Relatório médico'), findsOneWidget);
    expect(find.text('Código de Acesso Web'), findsOneWidget);

    await teardownTree(tester);
  });

  testWidgets('upcoming + past split renders both lists with the report tiles', (tester) async {
    final now = DateTime.now();
    await seed(
      'up1',
      now.add(const Duration(days: 7)),
      doctor: 'Dra. Silva',
      location: 'Hospital de Santa Maria',
    );
    await seed('past1', now.subtract(const Duration(days: 30)), doctor: 'Dr. Costa');

    await tester.pumpWidget(harness());
    await settle(tester);

    // Section labels both visible.
    expect(find.text('PRÓXIMA CONSULTA'), findsOneWidget);
    expect(find.text('HISTÓRICO'), findsOneWidget);

    // The upcoming appointment's doctor+location combination renders.
    expect(find.textContaining('Dra. Silva'), findsOneWidget);

    // Empty hint must NOT be on screen once there's a real upcoming row.
    expect(find.text('Adiciona a próxima consulta para a teres à mão.'), findsNothing);

    // The "Agendar" button is still reachable below the upcoming list.
    expect(find.widgetWithText(OutlinedButton, 'Agendar'), findsOneWidget);

    // The past appointment is in the Histórico section — scroll to it
    // because the report tiles + spacing can push it below the fold on a
    // short test window.
    await tester.scrollUntilVisible(
      find.textContaining('Dr. Costa'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('Dr. Costa'), findsOneWidget);

    await teardownTree(tester);
  });

  testWidgets('tapping the Web Access Code tile shows the "Em breve" SnackBar', (tester) async {
    await tester.pumpWidget(harness());
    await settle(tester);

    final webTile = find.text('Código de Acesso Web');
    expect(webTile, findsOneWidget);
    await tester.tap(webTile);
    await tester.pump(); // let the SnackBar fire
    await tester.pump(const Duration(milliseconds: 350)); // SnackBar slide in

    expect(
      find.textContaining('Em breve'),
      findsOneWidget,
      reason: 'Web Access Code is a placeholder until the web viewer ships',
    );

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
