/// Environment-specific configuration resolved at build time via --dart-define.
///
/// Pass values with:
///   flutter run --dart-define=API_BASE_URL=https://staging.api.example.com \
///               --dart-define=APP_ENV=staging \
///               --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_xxx \
///               --dart-define=PAYMENTS_BACKEND_URL=http://localhost:8080 \
///               --dart-define=SUPABASE_URL=https://xxx.supabase.co \
///               --dart-define=SUPABASE_ANON_KEY=sb_publishable_xxx
class AppConfig {
  AppConfig._();

  /// Current environment: `dev`, `staging`, or `prod`.
  static const String environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'dev',
  );

  /// Base URL for the legacy REST API.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.restaurant-pos.dev',
  );

  /// Base URL for the payments backend (`/payments/*`, `/webhooks/stripe`).
  /// Defaults to a local Express server for `flutter run` development.
  static const String paymentsBackendUrl = String.fromEnvironment(
    'PAYMENTS_BACKEND_URL',
    defaultValue: 'http://localhost:8080',
  );

  /// Stripe publishable key (`pk_test_...` or `pk_live_...`). Empty string
  /// disables Stripe initialisation — useful so the app still boots when no
  /// key has been provisioned yet.
  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  /// Apple Pay merchant identifier; required for Apple Pay button.
  static const String stripeMerchantIdentifier = String.fromEnvironment(
    'STRIPE_MERCHANT_IDENTIFIER',
    defaultValue: 'merchant.com.example.restaurantpos',
  );

  /// Supabase project URL.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  /// Supabase anon / publishable key. Safe to ship in the client; RLS is
  /// what protects data. Never put the service-role key here.
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static bool get isProduction => environment == 'prod';
  static bool get isStaging => environment == 'staging';
  static bool get isDevelopment => environment == 'dev';

  static bool get isStripeConfigured => stripePublishableKey.isNotEmpty;
  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}

