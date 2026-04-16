/// Environment-specific configuration resolved at build time via --dart-define.
///
/// Pass values with:
///   flutter run --dart-define=API_BASE_URL=https://staging.api.example.com \
///               --dart-define=APP_ENV=staging
class AppConfig {
  AppConfig._();

  /// Current environment: `dev`, `staging`, or `prod`.
  static const String environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'dev',
  );

  /// Base URL for the REST API.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.restaurant-pos.dev',
  );

  static bool get isProduction => environment == 'prod';
  static bool get isStaging => environment == 'staging';
  static bool get isDevelopment => environment == 'dev';
}
