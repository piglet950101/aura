import 'package:aura/app/app.dart';
import 'package:aura/core/theme/aura_colors.dart';
import 'package:aura/data/auth/auth_repository_provider.dart';
import 'package:aura/data/local/database_provider.dart';
import 'package:aura/data/notifications/reminder_service_provider.dart';
import 'package:aura/data/sync/outbox_worker_provider.dart';
import 'package:aura/domain/medication/medication_kind.dart';
import 'package:aura/features/settings/locale_provider.dart';
import 'package:aura/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Compile-time configuration read from `--dart-define-from-file=env.*.json`.
///
/// Top-level const so the values become real constants baked into the binary.
/// When the env file is absent, these fall back to '' and the matching
/// initialization step is skipped — useful for the theme-preview build that
/// runs before any backend exists.
const _kSupabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _kSupabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
const _kEnv = String.fromEnvironment('AURA_ENV', defaultValue: 'dev');

/// Single entry point used by `main`. Keeping bootstrap separate from `main()`
/// lets tests pump [AuraApp] directly without dragging Supabase along.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load date symbols for all locales so DateFormat works in pt_PT, pt_BR
  // and en (the app switches language at runtime).
  await initializeDateFormatting();

  // Status bar transparent, navigation bar matches our deep-aubergine bg.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AuraColors.bgBase,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Lock orientation. A phone in landscape during a migraine is not a UX we
  // need to support in v1.
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[DeviceOrientation.portraitUp]);

  // Build the Riverpod container manually so we can eagerly warm the
  // database during the splash (no first-screen jank) and reuse the same
  // container for runApp.
  final container = ProviderContainer();

  // Force-open the local Drift DB — runs migrations on a fresh install,
  // opens the SQLite file on subsequent launches. Throwing here is a hard
  // fail (the app cannot function without local persistence) so we
  // surface the error in logcat and rethrow.
  try {
    final db = container.read(auraDatabaseProvider);
    await db.pendingOutbox(limit: 1); // any noop query forces lazy open
    debugPrint('[AURA] Drift DB ready');
  } on Object catch (e, st) {
    debugPrint('[AURA] Drift open FAILED: $e\n$st');
    rethrow;
  }

  // Supabase init is conditional — we want the app to still launch (showing
  // the theme preview) even when no env file is wired up yet.
  if (_kSupabaseUrl.isNotEmpty && _kSupabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(
      url: _kSupabaseUrl,
      anonKey: _kSupabaseAnonKey,
      debug: _kEnv != 'prod',
    );

    final auth = Supabase.instance.client.auth;
    if (auth.currentSession == null) {
      // Anonymous sign-in on first launch — zero friction. The user can
      // upgrade to an email account later (Day 4 work) without losing data.
      await auth.signInAnonymously();
    }

    // Start the outbox sync worker. Eager read forces construction +
    // start() and schedules the periodic drain + connectivity listener.
    // Reading the provider here means the worker survives for the life
    // of the container (i.e. the app process).
    container.read(outboxWorkerProvider);
    debugPrint('[AURA] OutboxWorker started');

    // Seed the saved language (if any) before first paint.
    final user = container.read(authRepositoryProvider).currentUser;
    var activeLocale = container.read(localeProvider);
    if (user != null) {
      final profile = await container.read(auraDatabaseProvider).getProfile(user.id);
      if (profile != null) {
        activeLocale = localeFromCode(profile.locale);
        container.read(localeProvider.notifier).state = activeLocale;
      }
    }

    // Re-apply preventive-medication daily reminders so they survive reboots
    // and app upgrades. Init is idempotent, and rescheduleAll cancels stale
    // alarms before scheduling the current catalog — safe to run on every
    // launch. Skipped silently when no user is signed in.
    if (user != null) {
      try {
        final reminderService = container.read(reminderServiceProvider);
        final l = lookupAppL10n(activeLocale);
        final meds = await container.read(auraDatabaseProvider).allMedications(user.id);
        final actionable = meds
            .where(
              (m) =>
                  !m.archived &&
                  m.kind == MedicationKind.preventive.code &&
                  m.reminderMinutes != null,
            )
            .toList();
        final allExact = await reminderService.rescheduleAll(
          actionable,
          title: l.medsReminderTitle,
          bodyFor: (m) => l.medsReminderBody(m.name),
        );
        debugPrint(
          '[AURA] Reminders re-applied: ${actionable.length} (exact=$allExact)',
        );
      } on Object catch (e, st) {
        // Notifications are non-critical — never block app launch on them.
        debugPrint('[AURA] Reminder reschedule failed (non-fatal): $e\n$st');
      }
    }
  }

  runApp(UncontrolledProviderScope(container: container, child: const AuraApp()));
}
