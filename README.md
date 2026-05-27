# AURA · Diário da Enxaqueca

Mobile app (iOS + Android) for tracking migraine crises, generating a
clinical PDF report for neurologist consultations. Built with Flutter,
Supabase EU, and RevenueCat.

> **Project status:** MVP build · **Week 1 of 3 complete**. The core loop
> (register a crisis → see it on the dashboard → it syncs to Supabase)
> works end-to-end and is verified on a real device. See
> [implementation-plan.md](../implementation-plan.md) for the day-by-day
> roadmap.

## Quick start

```powershell
# 1. Configure the dev environment
Copy-Item env.example.json env.dev.json
# Fill env.dev.json with the dev Supabase credentials (anon key + URL).
# RevenueCat and Sentry keys arrive in week 3 — placeholders are fine.

# 2. Install dependencies
flutter pub get

# 3. Run on a connected device or emulator
flutter run --dart-define-from-file=env.dev.json
```

## Verify the toolchain

```powershell
flutter doctor
```

Required: Flutter 3.44+, JDK 17, Android SDK 35 + cmdline-tools.
Xcode is required for iOS builds (macOS only).

## Quality gates

```powershell
dart format --line-length=100 --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test
flutter build apk --debug --dart-define-from-file=env.dev.json
```

CI runs all of these on every push to `main` — see [.github/workflows/ci.yml](.github/workflows/ci.yml).

Current state: **33/33 tests pass**, **0 analyze issues**, debug APK builds clean.

## Week 1 — what's live

The end-to-end flow that's verified on a real device:

```
Cold boot
  → Drift DB opens
  → Supabase init + anonymous sign-in (uid stable across email upgrade)
  → OutboxWorker starts (drains pending writes on 30s timer / connectivity)
  → HomeScreen renders
      ├─ AURA wordmark + settings cog
      ├─ Olá + today's date (pt_PT)
      ├─ Últimos 30 dias breakdown (reactive — re-emits on any new crisis)
      ├─ 3+2 quick actions (Calendário · Partilhar · Medicação ·
      │                     Consulta Médica · Dados — placeholders for week 2)
      └─ "Registar crise" CTA
            → CrisisRegistrationScreen
                ├─ IntensityPicker (10 dots, 56dp tap targets)
                ├─ SymptomChips (multi-select)
                ├─ TriggerChips (single-select)
                ├─ MedicationCard (read-only)
                └─ Save → Drift transaction → outbox → worker → Supabase
                     (crisis + crisis_symptoms + crisis_triggers all sync)
```

## Stack

- **Flutter 3.44.0**, Dart 3.12 — single codebase iOS + Android.
- **Supabase** (eu-central-1, Frankfurt) — auth, Postgres, storage. Anonymous
  sign-ins enabled; email upgrade preserves `auth.uid()` so RLS-scoped data
  stays attached.
- **Drift 2.20** — local SQLite, offline-first source of truth.
- **Riverpod 2** — state management (manual providers; the codegen ecosystem
  has a transitive `analyzer_plugin` conflict tracked in `pubspec.yaml`).
- **uuid v4** — client-generated identifiers shared between Drift and Supabase.
- **RevenueCat** — IAP/subscriptions (wired in week 3).
- **pdf + printing** — clinical PDF generation (week 2 — Day 13).
- **fl_chart** — in-app charts (week 2).
- **Sentry** (EU region) — crash reporting (deferred to Day 18; current
  release has a Kotlin language-version conflict with AGP 9.x).

## Project layout (current — week 1)

```
lib/
├── main.dart                    entry → bootstrap()
├── app/
│   ├── app.dart                 MaterialApp + AuraTheme + HomeScreen as home
│   └── bootstrap.dart           Drift open, Supabase init, anon sign-in,
│                                OutboxWorker start, runApp
├── core/
│   └── theme/                   AuraColors, AuraTextStyles, AuraSpacing,
│                                AuraRadius, AuraTheme
├── data/
│   ├── auth/                    AuthRepository (abstract + Supabase impl)
│   ├── local/                   Drift database + provider
│   ├── remote/                  CrisisRemoteDataSource, MedicationRemoteDataSource
│   └── sync/                    OutboxWorker (drain + backoff + connectivity)
├── domain/
│   ├── crisis/                  Symptom, CrisisTrigger, CrisisDraft,
│   │                            RegisterCrisisUseCase
│   └── home/                    HomeStats
└── features/
    ├── crisis/                  CrisisRegistrationScreen + widgets
    ├── home/                    HomeScreen (week 1 home)
    └── dev/                     ThemePreviewScreen (design-token diagnostic)
```

## Identifiers

- **App ID (iOS) / Application ID (Android)**: `app.aura.diario`

These cannot be changed once published; do not rename without coordinating
with the App Store / Play Store listings.

## License

Private project. All rights reserved by Marcelo Salgado Lima da Silva.
