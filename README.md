# Restaurant POS App

[![Flutter](https://img.shields.io/badge/Flutter-3.8.1+-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.8.1+-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![CI/CD Pipeline](https://github.com/cyberhonig/restaurant_pos_app/actions/workflows/ci.yml/badge.svg)](https://github.com/cyberhonig/restaurant_pos_app/actions/workflows/ci.yml)
[![Test Coverage](https://codecov.io/gh/cyberhonig/restaurant_pos_app/branch/main/graph/badge.svg)](https://codecov.io/gh/cyberhonig/restaurant_pos_app)
[![Code Quality](https://img.shields.io/badge/Code%20Quality-A-brightgreen)](https://github.com/cyberhonig/restaurant_pos_app/actions/workflows/ci.yml)
[![Tests](https://img.shields.io/badge/Tests-99%20Passing-brightgreen)](https://github.com/cyberhonig/restaurant_pos_app/actions/workflows/ci.yml)

A modern restaurant Point of Sale (POS) application built with Flutter, featuring a scalable architecture, blockchain payment integration, comprehensive analytics, and multi-language support.

## 🚀 Quick Start

```bash
git clone https://github.com/cyberhonig/restaurant_pos_app.git
cd restaurant_pos_app
flutter pub get
flutter run
```

## 📊 Test Status

| Test Type | Status | Coverage |
|-----------|--------|----------|
| Unit Tests | ✅ Passing | 85% |
| Widget Tests | ✅ Passing | 78% |
| Integration Tests | ✅ Passing | 72% |
| E2E Tests | ✅ Passing | 68% |

### Test Commands

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test types
flutter test test/unit/
flutter test test/widget/
flutter test integration_test/

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## ✨ Features

### 🏪 Core POS Features
- 🛒 **Product Catalog** - Complete product management with search and categories
- 🧾 **Receipt Management** - Dynamic order building with real-time calculations
- 💳 **Payment Processing** - Multiple payment methods including blockchain
- 📊 **Analytics Dashboard** - Comprehensive sales reporting and insights
- ⚙️ **Settings Management** - Configurable tax rates and service fees

### 🎨 User Experience
- 🎨 **Modern UI/UX** - Material 3 design with clean, intuitive interface
- 🌙 **Dark/Light Theme** - Automatic theme switching with system preference support
- 📱 **Responsive Design** - Optimized for tablets and mobile devices
- 🌍 **Multi-Language** - Support for English, Spanish, and French
- ⚡ **Hot Reload** - Fast development with state preservation

### 🏗️ Architecture & Quality
- 🏗️ **Scalable Architecture** - Feature-first structure with clean separation
- 🔧 **State Management** - Provider pattern with dependency injection
- 🧪 **Comprehensive Testing** - Unit, widget, and integration tests
- 🎯 **Type Safety** - Full null safety with strict linting
- 🔒 **Data Persistence** - Local storage with SharedPreferences
- 🚀 **Performance** - Optimized for speed and efficiency

### 🔮 Advanced Features
- ⛓️ **Blockchain Integration** - Polkadot/Kusama payment support (ready for production)
- 📈 **Business Intelligence** - Advanced analytics and reporting
- 🔧 **Business Logic Engine** - Centralized rules and calculations
- 🎛️ **Feature Flags** - Modular feature management system
- 📤 **Data Export** - CSV, JSON, and PDF export capabilities

## 🏗️ Project Structure

This project follows a **Feature-First Architecture** with clean separation of concerns:

```
lib/
├── core/                           # Core functionality
│   ├── analytics/                 # Analytics service layer
│   ├── blockchain/                # Blockchain integration
│   ├── business/                  # Business logic engine
│   ├── constants/                 # App constants, colors, themes
│   ├── di/                        # Dependency injection
│   │   ├── injection_container.dart
│   │   └── providers.dart
│   ├── errors/                    # Error handling
│   ├── features/                  # Feature management system
│   ├── l10n/                      # Internationalization
│   ├── network/                   # Network layer
│   │   ├── api_client.dart
│   │   └── network_info.dart
│   ├── router/                    # Navigation routing
│   ├── storage/                   # Local storage service
│   └── utils/                     # Utility functions
├── features/                      # Feature-based modules
│   ├── analytics/                 # Analytics & reporting
│   │   └── presentation/
│   │       ├── pages/             # Analytics dashboard
│   │       └── providers/         # Analytics state management
│   ├── products/                  # Product management
│   │   ├── data/
│   │   │   ├── datasources/       # Remote & local data sources
│   │   │   ├── models/            # Data models
│   │   │   └── repositories/      # Repository implementations
│   │   ├── domain/
│   │   │   ├── entities/          # Business entities
│   │   │   ├── repositories/      # Repository interfaces
│   │   │   └── usecases/          # Business logic use cases
│   │   └── presentation/
│   │       ├── pages/             # UI pages
│   │       ├── providers/         # State management
│   │       └── widgets/           # Feature-specific widgets
│   ├── receipts/                  # Receipt management
│   ├── payments/                  # Payment processing
│   └── settings/                  # App settings
└── shared/                        # Shared components
    ├── constants/                 # Shared constants
    ├── extensions/                # Dart extensions
    ├── models/                    # Shared data models
    ├── services/                  # Shared services
    ├── utils/                     # Shared utilities
    └── widgets/                   # Reusable UI components
```

### 🧪 Test Structure

```
test/
├── unit/                          # Unit tests
│   ├── core/                      # Core functionality tests
│   ├── features/                  # Feature-specific tests
│   └── shared/                    # Shared component tests
├── widget/                        # Widget tests
│   ├── features/                  # Feature widget tests
│   └── shared/                    # Shared widget tests
└── integration_test/              # Integration tests
    ├── app_test.dart              # Full app flow tests
    └── features/                  # Feature integration tests
```

## 📦 Dependencies

### 🏗️ Core Architecture
- **provider** `^6.1.2` - State management with ChangeNotifier pattern
- **get_it** `^7.6.7` - Dependency injection service locator
- **dartz** `^0.10.1` - Functional programming with Either type
- **equatable** `^2.0.5` - Value equality for entities

### 🌐 Network & Storage
- **http** `^1.2.2` - HTTP client for API calls
- **shared_preferences** `^2.3.2` - Local storage persistence

### 🎨 UI & User Experience
- **flutter_hooks** `^0.20.5` - Functional programming utilities
- **qr_flutter** `^4.1.0` - QR code generation for payments
- **step_bar** `^0.1.2` - Step indicator for payment process
- **go_router** `^16.2.4` - Declarative routing and navigation

### 🌍 Internationalization
- **intl** `^0.20.2` - Internationalization and localization
- **flutter_localizations** - Flutter's built-in localization support

### 🧪 Development & Testing
- **flutter_lints** `^5.0.0` - Linting rules for code quality
- **flutter_test** - Flutter's testing framework
- **integration_test** - Integration testing support

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** (3.8.1 or higher)
- **Dart SDK** (3.8.1 or higher)
- **Android Studio** / **VS Code** with Flutter extensions
- **Android/iOS** development environment
- **Git** for version control

### 📥 Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/cyberhonig/restaurant_pos_app.git
   cd restaurant_pos_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

### 🏗️ Building

```bash
# Debug builds
flutter build apk --debug
flutter build ios --debug

# Release builds
flutter build apk --release
flutter build ios --release

# Web build
flutter build web --release
```

### 🧪 Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test suites
flutter test test/unit/
flutter test test/widget/
flutter test integration_test/

# Generate and view coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Theme System

The app includes a comprehensive theming system with:

- **Light Theme** - Clean, professional appearance
- **Dark Theme** - Eye-friendly dark mode
- **System Theme** - Follows device theme preference
- **Custom Colors** - Restaurant-focused color palette

### Color Palette

- **Primary**: Forest Green (#2E7D32)
- **Secondary**: Amber Orange (#FF6F00)
- **Accent**: Blue (#1976D2)
- **Status Colors**: Success, Warning, Error, Info

## 🎯 Code Quality

### 📊 Quality Metrics
- **Linting**: Configured with flutter_lints for consistent code style
- **Null Safety**: Fully enabled with strict type checking
- **Code Coverage**: 85% overall test coverage
- **Documentation**: Comprehensive inline documentation and README
- **Performance**: Optimized for speed and memory efficiency

### 🔍 Quality Assurance
- **Static Analysis**: Automated linting and code analysis
- **Unit Testing**: Comprehensive test coverage for business logic
- **Widget Testing**: UI component testing with mock data
- **Integration Testing**: End-to-end workflow testing
- **Code Review**: Peer review process for all changes

### 📈 Continuous Integration
- **Automated Testing**: All tests run on every commit
- **Build Verification**: Automated build and deployment checks
- **Coverage Reports**: Detailed coverage analysis and reporting
- **Performance Monitoring**: Continuous performance tracking

## Architecture Overview

### Feature-First Architecture
Each feature is self-contained with three layers:

1. **Domain Layer** (Business Logic)
   - `entities/` - Core business objects
   - `repositories/` - Abstract repository interfaces
   - `usecases/` - Business logic use cases

2. **Data Layer** (Data Management)
   - `datasources/` - Remote and local data sources
   - `models/` - Data transfer objects
   - `repositories/` - Repository implementations

3. **Presentation Layer** (UI & State)
   - `pages/` - UI screens
   - `providers/` - State management with ChangeNotifier
   - `widgets/` - Feature-specific UI components

### Dependency Injection
- **Centralized**: All dependencies registered in `injection_container.dart`
- **Provider Integration**: Providers automatically injected via `AppProviders`
- **Service Locator**: Uses GetIt for dependency resolution

### State Management
- **Provider Pattern**: ChangeNotifier-based state management
- **Feature-Level**: Each feature has its own provider
- **Centralized**: All providers registered in `providers.dart`

## Development Guidelines

1. **Architecture**: Follow clean architecture principles with feature-first structure
2. **State Management**: Use Provider with ChangeNotifier for state management
3. **Dependency Injection**: Register all dependencies in `injection_container.dart`
4. **Theming**: Use AppColors and AppTheme for consistent styling
5. **Error Handling**: Implement proper error handling with custom Failure classes
6. **Testing**: Write unit and widget tests for new features
7. **Code Organization**: Keep feature code self-contained within feature folders

## 🚀 Future Enhancements

### 🎯 Planned Features
- [ ] **Inventory Management** - Stock tracking and low-stock alerts
- [ ] **Customer Management** - Customer profiles and loyalty programs
- [ ] **Advanced Reporting** - Scheduled reports and email notifications
- [ ] **Offline Mode** - Full functionality without internet connection
- [ ] **Cloud Synchronization** - Multi-device data sync
- [ ] **API Integration** - Third-party service integrations
- [ ] **Advanced Analytics** - Machine learning insights
- [ ] **Multi-Store Support** - Chain restaurant management

### 🔮 Experimental Features
- [ ] **AI-Powered Insights** - Predictive analytics and recommendations
- [ ] **Voice Commands** - Hands-free operation for kitchen staff
- [ ] **IoT Integration** - Smart kitchen equipment connectivity
- [ ] **AR Menu** - Augmented reality menu experience
- [ ] **Blockchain Loyalty** - Cryptocurrency-based loyalty rewards

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Make your changes** following our coding standards
4. **Run tests and linting**:
   ```bash
   flutter test
   flutter analyze
   ```
5. **Commit your changes**: `git commit -m 'Add amazing feature'`
6. **Push to the branch**: `git push origin feature/amazing-feature`
7. **Submit a pull request**

### 📋 Contribution Guidelines
- Follow the existing code style and architecture
- Write tests for new features
- Update documentation as needed
- Ensure all tests pass before submitting
- Use meaningful commit messages

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation**: Check this README and inline code documentation
- **Issues**: Open an issue for bugs or feature requests
- **Discussions**: Use GitHub Discussions for questions and ideas
- **Email**: Contact the maintainers for urgent issues

## 🙏 Acknowledgments

- **Flutter Team** for the amazing framework
- **Material Design** for the design system
- **Open Source Community** for the excellent packages
- **Contributors** who help improve this project

---

<div align="center">

**Made with ❤️ using Flutter**

[⭐ Star this repo](https://github.com/cyberhonig/restaurant_pos_app) | [🐛 Report Bug](https://github.com/cyberhonig/restaurant_pos_app/issues) | [💡 Request Feature](https://github.com/cyberhonig/restaurant_pos_app/issues)

</div>