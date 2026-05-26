# AURA · Diário da Enxaqueca

Mobile app (iOS + Android) for tracking migraine crises, generating a
clinical PDF report for neurologist consultations. Built with Flutter,
Supabase EU, and RevenueCat.

> **Project status:** MVP build, week 1 of 3.
> Full plan: [`../implementation-plan.md`](../implementation-plan.md).

## Quick start

```powershell
# 1. Configure the dev environment
Copy-Item env.example.json env.dev.json
# Fill env.dev.json with the dev Supabase / RevenueCat / Sentry credentials.

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
flutter analyze --fatal-infos --fatal-warnings
flutter test
dart format --line-length=100 .
```

CI runs all three on every push to `main` — see [.github/workflows/ci.yml](.github/workflows/ci.yml).

## Stack

- **Flutter 3.44.0**, Dart 3.12 — single codebase iOS + Android.
- **Supabase** (eu-central-1, Frankfurt) — auth, Postgres, storage.
- **Drift** — local SQLite, offline-first source of truth.
- **Riverpod 2** with code generation — state management.
- **go_router** — declarative routing.
- **RevenueCat** — IAP / subscriptions.
- **pdf + printing** — clinical PDF generation, local on device.
- **Sentry** (EU region) — crash reporting with PII scrubbing.

## Project layout

```
lib/
├── main.dart                  entry, system chrome
├── app/
│   ├── app.dart               MaterialApp shell
│   ├── router.dart            go_router config           (added Day 2)
│   └── bootstrap.dart         Supabase + RevenueCat init (added Day 1 end)
├── core/
│   ├── theme/                 design tokens (AuraColors, AuraTheme, ...)
│   ├── l10n/                  generated localizations
│   ├── widgets/               reusable UI primitives
│   ├── analytics/             event sink
│   └── errors/                Failure types
├── data/
│   ├── local/                 Drift database
│   ├── remote/                Supabase data sources
│   ├── repositories/          domain-facing facades
│   └── sync/                  outbox worker
├── domain/
│   ├── entities/              Crisis, Medication, Symptom, ...
│   └── usecases/              RegisterCrisis, GenerateReport, ...
└── features/
    ├── home/                  dashboard
    ├── crisis/                register, detail, edit
    ├── calendar/              monthly history
    ├── medications/           CRUD
    ├── premium/               paywall, PDF preview
    ├── settings/              account, GDPR controls
    ├── onboarding/            minimal — language + permission notice
    └── dev/                   diagnostic screens (removed before release)
```

## Identifiers

- **App ID (iOS)**: `app.aura.diario` (prod) · `app.aura.diario.dev` (dev)
- **Application ID (Android)**: same

These cannot be changed once published; do not rename without coordinating
with the App Store / Play Store listings.

## License

Private project. All rights reserved by Marcelo Salgado Lima da Silva.
