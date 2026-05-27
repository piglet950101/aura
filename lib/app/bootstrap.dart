import 'package:aura/app/app.dart';
import 'package:aura/core/theme/aura_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  }

  runApp(const ProviderScope(child: AuraApp()));
}
