# Environment configuration

AURA is configured via Dart compile-time defines loaded from a JSON file.
Real credentials are never committed; only [env.example.json](env.example.json) is.

## How it works

The Flutter run/build commands take `--dart-define-from-file=env.json`, which
makes every key in the file readable inside the app via
`String.fromEnvironment('KEY')`. No runtime file read, no secret in plaintext
on the device — the values are baked into the compiled binary.

## Setup (each developer / each environment)

1. Copy the template:

   ```powershell
   Copy-Item env.example.json env.dev.json
   ```

2. Fill it with the **dev** project credentials (these come from the dashboards
   of the dev Supabase / RevenueCat / Sentry projects).

3. Run with the dev environment:

   ```powershell
   flutter run --dart-define-from-file=env.dev.json
   ```

4. For production builds:

   ```powershell
   Copy-Item env.example.json env.prod.json   # fill with prod values
   flutter build appbundle --release --dart-define-from-file=env.prod.json
   flutter build ipa       --release --dart-define-from-file=env.prod.json
   ```

## Files

| File | Tracked | Purpose |
|---|---|---|
| `env.example.json` | yes | Template with placeholder values. |
| `env.dev.json`     | no  | Local dev credentials. Personal copy. |
| `env.prod.json`    | no  | Production credentials. Used only at release build. |

`env.dev.json`, `env.prod.json`, and `.env*` are git-ignored.

## Where the keys are consumed

| Key | Read from | Used by |
|---|---|---|
| `SUPABASE_URL` | `lib/app/bootstrap.dart` | `Supabase.initialize` |
| `SUPABASE_ANON_KEY` | `lib/app/bootstrap.dart` | `Supabase.initialize` |
| `REVENUECAT_API_KEY_IOS` | `lib/app/bootstrap.dart` (iOS branch) | `Purchases.configure` |
| `REVENUECAT_API_KEY_ANDROID` | `lib/app/bootstrap.dart` (Android branch) | `Purchases.configure` |
| `SENTRY_DSN` | `lib/main.dart` | `SentryFlutter.init` |
| `AURA_ENV` | wherever needed | feature flags, log labels |

## Rotating a key

Replace the value in your local `env.{dev,prod}.json`, rebuild the app, ship.
Old binaries on devices continue to use the old key until the user updates —
plan accordingly. RevenueCat and Supabase keys above are *public* keys (anon /
SDK keys) so rotation is low-risk; the secret service-role keys never live
in this file or in the client app at all.
