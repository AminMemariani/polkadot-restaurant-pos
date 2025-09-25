/// Core constants for the restaurant POS app
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // App information
  static const String appName = 'Restaurant POS';
  static const String appVersion = '1.0.0';

  // API endpoints (to be configured later)
  static const String baseUrl = 'https://api.restaurant-pos.com';

  // Storage keys
  static const String themeKey = 'theme_mode';
  static const String userKey = 'user_data';
  static const String settingsKey = 'app_settings';

  // Default values
  static const int defaultTimeout = 30; // seconds
  static const int maxRetries = 3;
}
