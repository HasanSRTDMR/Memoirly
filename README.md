# Memoirly (The Archive)

Private journaling app for iOS, Android, and more. UI is based on the Stitch HTML export in `Memoirly ekranları/`.

## Stack

- **Flutter** + **Riverpod** + **go_router**
- **Clean architecture** (domain / data / features)
- **Firebase** (anonymous auth + Firestore) with automatic **local fallback** if Firebase is not configured
- **English / Türkçe** via ARB + runtime language override in Settings

## Run

```bash
flutter pub get
flutter run
```

## Firebase (production)

1. Install [FlutterFire CLI](https://firebase.google.com/docs/flutter/setup).
2. Run `flutterfire configure` and replace `lib/firebase_options.dart`.
3. Deploy Firestore security rules (see `docs/DEVELOPER_GUIDE.md`).

Until then, the app stores the journal locally per device.

## Documentation

- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — layers, state management, data flow
- [`docs/DEVELOPER_GUIDE.md`](docs/DEVELOPER_GUIDE.md) — new features, new API, replacing Firebase
- [`docs/FOLDER_STRUCTURE.md`](docs/FOLDER_STRUCTURE.md) — what each folder is for

## Tests

```bash
flutter test
```
