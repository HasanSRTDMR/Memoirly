# Folder structure

```
lib/
├── main.dart                 # Bootstrap: Firebase vs local, ProviderScope overrides, router
├── firebase_options.dart     # Replace via flutterfire configure
├── app/
│   ├── app_router.dart       # go_router: shell + full-screen routes
│   └── memoirly_app.dart     # MaterialApp.router, theme/locale streams, lock overlay
├── core/
│   ├── config/               # e.g. AppBackend enum
│   ├── constants/            # Mood keys, shared literals
│   ├── di/
│   │   └── providers.dart    # Riverpod providers & overrides contract
│   ├── localization/       # Generated l10n + mood_label helper
│   ├── theme/                # Colors, ThemeData
│   └── widgets/              # ArchiveAppBar, FAB, etc.
├── domain/
│   ├── entities/             # JournalEntry, pure Dart
│   ├── repositories/         # Abstract AuthRepository, JournalRepository, …
│   └── usecases/             # CreateEntry, WatchEntries, ComputeInsights, …
├── data/
│   ├── models/               # JSON/Firestore DTOs + mappers
│   └── repositories/         # Firebase* / Local* / Settings / Security impls
└── features/
    ├── calendar/             # Calendar archive UI
    ├── home/                 # Dashboard
    ├── insights/             # Stats & charts
    ├── journal/              # Write + detail
    ├── onboarding/           # First-run flow
    ├── search/               # Real-time search & filters
    ├── security/             # PIN overlay
    ├── settings/             # Lock, theme, language, export, reset
    └── shell/                # Bottom navigation host
```

## Responsibility summary

| Path | Role |
|------|------|
| `domain/` | Business vocabulary and rules; no framework imports. |
| `data/` | Persistence and external services; knows Firestore field names. |
| `features/*/presentation/` | User-facing composition only. |
| `core/` | Cross-cutting building blocks. |
| `app/` | Composition root and navigation graph. |

Tests live in `test/`; design reference assets in `Memoirly ekranları/`.
