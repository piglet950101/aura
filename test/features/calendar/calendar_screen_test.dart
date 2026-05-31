// Widget test for the calendar screen.
//   - Renders the month header, stats strip and day grid from seeded data.
//   - Month nav (›) advances to the next month.
//   - Tapping a day with a crisis opens the detail sheet.
//
// The month is pinned via a calendarMonthProvider override so the test is
// deterministic regardless of the real clock.

import 'package:aura/data/auth/auth_repository.dart';
import 'package:aura/data/auth/auth_repository_provider.dart';
import 'package:aura/data/local/database.dart';
import 'package:aura/data/local/database_provider.dart';
import 'package:aura/features/calendar/calendar_providers.dart';
import 'package:aura/features/calendar/calendar_screen.dart';
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

  Future<void> seed(String id, DateTime when, int intensity) {
    return db.insertCrisis(
      CrisesCompanion.insert(id: id, userId: 'u-marta', occurredAt: when, intensity: intensity),
    );
  }

  Widget harness() => ProviderScope(
    overrides: [
      auraDatabaseProvider.overrideWithValue(db),
      authRepositoryProvider.overrideWithValue(
        _StubAuth(const AppUser(id: 'u-marta', isAnonymous: true)),
      ),
      calendarMonthProvider.overrideWith((ref) => DateTime(2026, 5)),
    ],
    child: const MaterialApp(
      locale: Locale('pt'),
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      home: CalendarScreen(),
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

  testWidgets('renders month header, stats and grid from seeded crises', (tester) async {
    await seed('a', DateTime(2026, 5, 15, 21), 8); // forte
    await tester.pumpWidget(harness());
    await settle(tester);

    expect(find.text('Maio 2026'), findsOneWidget);
    expect(find.text('Intensidade média'), findsOneWidget);
    expect(find.text('8,0'), findsOneWidget); // average formatted pt-PT
    expect(find.text('15'), findsOneWidget); // day cell present

    await teardownTree(tester);
  });

  testWidgets('next-month chevron advances the header', (tester) async {
    await tester.pumpWidget(harness());
    await settle(tester);

    expect(find.text('Maio 2026'), findsOneWidget);
    await tester.tap(find.byTooltip('Mês seguinte'));
    await settle(tester);

    expect(find.text('Junho 2026'), findsOneWidget);

    await teardownTree(tester);
  });

  testWidgets('tapping a day with a crisis opens the detail sheet', (tester) async {
    await seed('a', DateTime(2026, 5, 15, 21), 8);
    await tester.pumpWidget(harness());
    await settle(tester);

    await tester.tap(find.text('15'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350)); // sheet animation

    expect(find.textContaining('Intensidade 8'), findsOneWidget);
    expect(find.text('Registar para este dia'), findsOneWidget);

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
