# Restaurant POS

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.8+-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![CI](https://github.com/AminMemariani/polkadot-restaurant-pos/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/AminMemariani/polkadot-restaurant-pos/actions/workflows/ci.yml)
[![Quality](https://github.com/AminMemariani/polkadot-restaurant-pos/actions/workflows/quality.yml/badge.svg?branch=main)](https://github.com/AminMemariani/polkadot-restaurant-pos/actions/workflows/quality.yml)
[![Coverage](https://codecov.io/gh/AminMemariani/polkadot-restaurant-pos/branch/main/graph/badge.svg)](https://codecov.io/gh/AminMemariani/polkadot-restaurant-pos)

A modern restaurant Point of Sale application built with Flutter. Feature-first architecture, blockchain payment support (Polkadot/Kusama), multi-language UI, and a comprehensive test suite.

---

## Table of Contents

- [Features](#features)
- [Quick Start](#quick-start)
- [Prerequisites](#prerequisites)
- [Configuration](#configuration)
- [Building for Release](#building-for-release)
- [Testing](#testing)
- [Project Structure](#project-structure)
- [Architecture](#architecture)
- [Dependencies](#dependencies)
- [Contributing](#contributing)
- [License](#license)

---

## Features

**Core POS**
- Product catalog with search and category filtering
- Dynamic order building with real-time subtotal, tax, and service-fee calculation
- Multi-method payment flow (card, cash, blockchain)
- Analytics dashboard with date-range filtering and CSV/JSON export
- Configurable tax rate, service fee, and blockchain RPC endpoints

**Blockchain Payments**
- Polkadot and Kusama integration with configurable public RPC endpoints
- QR-code-based payment handoff with transaction-status tracking

**Platform**
- Material 3 design, adaptive light/dark theme
- Responsive layout optimized for phones and tablets
- Localization for English, Spanish, and French

---

## Quick Start

```bash
git clone https://github.com/AminMemariani/polkadot-restaurant-pos.git
cd polkadot-restaurant-pos
flutter pub get
flutter run
```

---

## Prerequisites

- Flutter SDK 3.x (Dart 3.8+)
- Android Studio or VS Code with the Flutter extension
- Platform toolchains:
  - **Android:** Android SDK, JDK 11+
  - **iOS:** Xcode 15+, CocoaPods (macOS only)

Run `flutter doctor` to verify the toolchain.

---

## Configuration

### Environment-based configuration

Runtime configuration is injected at build time via `--dart-define`. See `lib/core/config/app_config.dart`.

```bash
flutter run \
  --dart-define=APP_ENV=staging \
  --dart-define=API_BASE_URL=https://staging.api.example.com
```

| Variable        | Default                          | Description                      |
| --------------- | -------------------------------- | -------------------------------- |
| `APP_ENV`       | `dev`                            | `dev`, `staging`, or `prod`      |
| `API_BASE_URL`  | `https://api.restaurant-pos.dev` | Base URL for REST API calls      |

### Android release signing

Signing is loaded from `android/key.properties` (gitignored). Create one from the provided template:

```bash
cp android/key.properties.example android/key.properties
# Edit key.properties with your keystore details
```

Generate an upload keystore if you don't already have one:

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

If `key.properties` is absent, release builds fall back to debug keys for local testing.

### Network security

- **Android:** Cleartext HTTP is blocked via `android/app/src/main/res/xml/network_security_config.xml`.
- **iOS:** App Transport Security is enforced with `NSAllowsArbitraryLoads=false` in `Info.plist`.

---

## Building for Release

```bash
# Android App Bundle (for Play Store)
flutter build appbundle --release \
  --dart-define=APP_ENV=prod \
  --dart-define=API_BASE_URL=https://api.example.com

# Android APK
flutter build apk --release --dart-define=APP_ENV=prod

# iOS
flutter build ipa --release --dart-define=APP_ENV=prod

# Web
flutter build web --release --dart-define=APP_ENV=prod
```

R8 minification and resource shrinking are enabled for Android release builds. ProGuard rules live in `android/app/proguard-rules.pro`.

---

## Testing

```bash
# Unit and widget tests
flutter test

# With coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Specific suites
flutter test test/unit/
flutter test test/widget/
flutter test test/models/

# Integration tests (requires running device/emulator)
flutter test integration_test/
```

Current test suite: 99 unit and widget tests. CI runs tests, formatting checks, and `flutter analyze --fatal-infos --fatal-warnings` on every push.

---

## Project Structure

```
lib/
├── core/                  Cross-cutting concerns
│   ├── analytics/         Analytics service layer
│   ├── blockchain/        Polkadot/Kusama integration
│   ├── business/          Business-rule engine
│   ├── config/            Environment-based configuration
│   ├── constants/         Colors, theme, app constants
│   ├── di/                GetIt service locator + provider registration
│   ├── errors/            Failure types and error mapping
│   ├── features/          Feature-flag system
│   ├── l10n/              Localization delegates and strings
│   ├── network/           API client and connectivity checks
│   ├── router/            GoRouter configuration
│   ├── storage/           SharedPreferences service
│   └── utils/             Utility helpers
├── features/              Feature modules (domain/data/presentation)
│   ├── analytics/
│   ├── payments/
│   ├── products/
│   ├── receipts/
│   └── settings/
└── shared/                Reusable widgets, extensions, services

test/
├── models/                Model equality and serialization tests
├── unit/core/             Core service and utility tests
└── widget/features/       Feature widget tests

integration_test/          End-to-end flow tests
```

---

## Architecture

Each feature is organized into three layers following clean-architecture principles:

- **Domain** — entities, repository interfaces, use cases (no Flutter dependencies)
- **Data** — data sources (remote, local), models, repository implementations
- **Presentation** — pages, widgets, and `ChangeNotifier`-based providers

**State management:** Provider with `ChangeNotifier`. Providers are registered centrally in `lib/core/di/providers.dart`.

**Dependency injection:** GetIt service locator, configured in `lib/core/di/injection_container.dart`.

**Routing:** `go_router` with declarative route definitions.

**Error handling:** `Either<Failure, T>` via `dartz`. Failures map to user-facing messages in each provider.

---

## Dependencies

| Category            | Package               | Version   |
| ------------------- | --------------------- | --------- |
| State management    | `provider`            | ^6.1.2    |
| DI service locator  | `get_it`              | ^7.6.7    |
| Functional types    | `dartz`               | ^0.10.1   |
| Value equality      | `equatable`           | ^2.0.5    |
| HTTP client         | `http`                | ^1.2.2    |
| Local storage       | `shared_preferences`  | ^2.3.2    |
| Routing             | `go_router`           | ^16.2.4   |
| Hooks               | `flutter_hooks`       | ^0.20.5   |
| QR codes            | `qr_flutter`          | ^4.1.0    |
| Payment step UI     | `step_bar`            | ^0.1.2    |
| i18n                | `intl`                | ^0.20.2   |
| Lints               | `flutter_lints` (dev) | ^5.0.0    |

Run `flutter pub outdated` to check for newer versions.

---

## Contributing

1. Fork the repository and create a feature branch: `git checkout -b feature/my-change`
2. Make your changes following the existing architecture and code style
3. Verify quality gates pass locally:
   ```bash
   dart format --set-exit-if-changed .
   flutter analyze --fatal-infos --fatal-warnings
   flutter test
   ```
4. Commit with a descriptive message and open a pull request

New features should include unit and/or widget tests. Public APIs should have dartdoc comments.

---

## License

Released under the [MIT License](LICENSE).
