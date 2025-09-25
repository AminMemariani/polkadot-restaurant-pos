# Restaurant POS App

A modern restaurant Point of Sale (POS) application built with Flutter, featuring a clean architecture and comprehensive theming system.

## Features

- 🎨 **Modern UI/UX** - Clean, intuitive interface designed for restaurant operations
- 🌙 **Dark/Light Theme** - Automatic theme switching with system preference support
- 📱 **Responsive Design** - Optimized for various screen sizes
- 🏗️ **Clean Architecture** - Well-organized code structure with separation of concerns
- 🔧 **State Management** - Provider pattern for efficient state management
- 🎯 **Type Safety** - Full null safety support
- 📊 **Future-Ready** - Prepared for features like QR codes, payments, and reporting

## Project Structure

This project follows a **Feature-First Architecture** with clean separation of concerns:

```
lib/
├── core/                           # Core functionality
│   ├── constants/                 # App constants, colors, themes
│   ├── di/                        # Dependency injection
│   │   ├── injection_container.dart
│   │   └── providers.dart
│   ├── errors/                    # Error handling
│   ├── network/                   # Network layer
│   │   ├── api_client.dart
│   │   └── network_info.dart
│   └── utils/                     # Utility functions
├── features/                      # Feature-based modules
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

## Dependencies

### Core Dependencies
- **provider** - State management with ChangeNotifier pattern
- **get_it** - Dependency injection service locator
- **dartz** - Functional programming with Either type
- **equatable** - Value equality for entities

### Network & Storage
- **http** - HTTP client for API calls
- **shared_preferences** - Local storage

### UI & Utilities
- **flutter_hooks** - Functional programming utilities
- **qr_flutter** - QR code generation
- **intl** - Internationalization support

## Getting Started

### Prerequisites

- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Android/iOS development environment

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd restaurant_pos_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Building

- **Debug APK**: `flutter build apk --debug`
- **Release APK**: `flutter build apk --release`
- **iOS**: `flutter build ios --release`

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

## Code Quality

- **Linting**: Configured with flutter_lints
- **Null Safety**: Fully enabled
- **Code Style**: Consistent formatting and naming conventions
- **Documentation**: Comprehensive inline documentation

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

## Future Enhancements

- [ ] Menu management system
- [ ] Order processing workflow
- [ ] Payment integration
- [ ] QR code menu scanning
- [ ] Analytics and reporting
- [ ] Multi-language support
- [ ] Offline mode support
- [ ] Cloud synchronization

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and linting
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please open an issue in the repository.