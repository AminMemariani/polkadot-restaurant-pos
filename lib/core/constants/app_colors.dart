import 'package:flutter/material.dart';

/// App color constants for consistent theming
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary colors
  static const Color primary = Color(0xFF2E7D32); // Forest Green
  static const Color primaryLight = Color(0xFF4CAF50); // Light Green
  static const Color primaryDark = Color(0xFF1B5E20); // Dark Green

  // Secondary colors
  static const Color secondary = Color(0xFFFF6F00); // Amber Orange
  static const Color secondaryLight = Color(0xFFFFB74D); // Light Amber
  static const Color secondaryDark = Color(0xFFE65100); // Dark Amber

  // Accent colors
  static const Color accent = Color(0xFF1976D2); // Blue
  static const Color accentLight = Color(0xFF42A5F5); // Light Blue
  static const Color accentDark = Color(0xFF0D47A1); // Dark Blue

  // Neutral colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Dark theme colors
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkSurfaceVariant = Color(0xFF1E1E1E);
  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color darkOnSurface = Color(0xFFE1E1E1);
  static const Color darkOnBackground = Color(0xFFE1E1E1);

  // POS specific colors
  static const Color posCardBackground = Color(0xFFF8F9FA);
  static const Color posButtonPrimary = Color(0xFF2E7D32);
  static const Color posButtonSecondary = Color(0xFF6C757D);
  static const Color posTextPrimary = Color(0xFF212529);
  static const Color posTextSecondary = Color(0xFF6C757D);
  static const Color posBorder = Color(0xFFDEE2E6);
}
