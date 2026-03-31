# Architecture

## Overview

Memoirly (“The Archive”) is structured as **Clean Architecture** with a **feature-oriented presentation layer** and **replaceable data sources**. The UI never talks to Firebase or platform APIs directly; it depends on abstractions (repository interfaces) wired through Riverpod at the application entry point.

## Layers

| Layer | Responsibility |
|--------|----------------|
| **Domain** | Entities, repository contracts, use cases. No Flutter or Firebase imports. |
| **Data** | Models (DTOs / Firestore mapping), repository implementations, local/remote persistence. |
| **Features** | Screens, reusable widgets, navigation arguments. Calls use cases or reads streams via Riverpod—not repositories directly from widgets in complex flows (repositories are still accessed through providers that expose use cases / streams). |
| **Core** | Theme, localization helpers, shared widgets, DI providers. |
| **App** | `GoRouter` graph, root `MaterialApp`, bootstrap. |

## State management: Riverpod

**Choice: `flutter_riverpod` (2.x)**

- **Testability:** Repositories and use cases are plain Dart; providers are overridden in tests (see `test/widget_test.dart`).
- **Explicit wiring:** `main.dart` resolves `AppBackend` (Firebase vs local) once and injects implementations with `ProviderScope(overrides: ...)`.
- **Scalability:** New features add providers + consumers without a global service locator.
- **Compared to Bloc:** Less boilerplate for stream-backed lists (journal entries); use cases remain synchronous/async functions where appropriate.
- **Compared to Provider:** Riverpod adds compile-time safety and simpler overrides for multi-repository apps.

## Navigation: go_router

**Choice: `go_router` with `StatefulShellRoute.indexedStack`**

- Bottom tabs (Home, Search, Calendar, Insights, Settings) keep each branch’s state.
- Full-screen flows (`/write`, `/entry/:id`, `/onboarding`) sit **outside** the shell and use the root navigator so the bottom bar is hidden, matching the Stitch “focus” screens.

## Data flow (mandatory path)

```
Widget (UI)
  → Riverpod provider / use case provider
    → Use case (domain)
      → Repository interface (domain)
        → Repository implementation (data)
          → Firestore / SharedPreferences / Secure storage
```

Example: saving an entry uses `CreateEntryUseCase` → `JournalRepository` → `FirebaseJournalRepository` or `LocalJournalRepository`.

## Backend strategy

1. **Primary:** Firebase Auth (anonymous) + Cloud Firestore (`users/{uid}/journalEntries/{id}`).
2. **Fallback:** If `Firebase.initializeApp` or sign-in fails, the app uses `LocalAuthRepository` + `LocalJournalRepository` (JSON in `SharedPreferences`) so `flutter run` works before Firebase is configured.

Replace placeholder `lib/firebase_options.dart` with output from `flutterfire configure` for production.

## Security

- **PIN:** Hash (SHA-256) stored in `FlutterSecureStorage`; enable/disable in `SettingsRepository` / `SecurityRepository`.
- **Session:** `SecurityRepository.setSessionUnlocked` is in-memory; app lifecycle pauses clear the session when lock is enabled (`PinUnlockOverlay`).
- **Biometrics:** `local_auth` for unlock; optional toggle in settings. iOS requires `NSFaceIDUsageDescription` (already added).

## Localization

- ARB files: `lib/l10n/app_en.arb`, `app_tr.arb`.
- Generated: `lib/core/localization/app_localizations*.dart`.
- User override via `SettingsRepository.setLocaleOverride`; `null` follows the OS locale.
