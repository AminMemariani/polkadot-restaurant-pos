import 'dart:convert';

import '../../domain/entities/settings.dart';

class SettingsModel extends Settings {
  const SettingsModel({
    required super.restaurantName,
    required super.currency,
    required super.taxRate,
    required super.darkMode,
    required super.language,
    required super.notificationsEnabled,
  });

  factory SettingsModel.fromJson(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return SettingsModel(
      restaurantName: json['restaurantName'] as String,
      currency: json['currency'] as String,
      taxRate: (json['taxRate'] as num).toDouble(),
      darkMode: json['darkMode'] as bool,
      language: json['language'] as String,
      notificationsEnabled: json['notificationsEnabled'] as bool,
    );
  }

  String toJson() {
    return jsonEncode({
      'restaurantName': restaurantName,
      'currency': currency,
      'taxRate': taxRate,
      'darkMode': darkMode,
      'language': language,
      'notificationsEnabled': notificationsEnabled,
    });
  }

  factory SettingsModel.defaultSettings() {
    return const SettingsModel(
      restaurantName: 'Restaurant POS',
      currency: 'USD',
      taxRate: 0.08,
      darkMode: false,
      language: 'en',
      notificationsEnabled: true,
    );
  }

  factory SettingsModel.fromEntity(Settings settings) {
    return SettingsModel(
      restaurantName: settings.restaurantName,
      currency: settings.currency,
      taxRate: settings.taxRate,
      darkMode: settings.darkMode,
      language: settings.language,
      notificationsEnabled: settings.notificationsEnabled,
    );
  }

  Settings toEntity() {
    return Settings(
      restaurantName: restaurantName,
      currency: currency,
      taxRate: taxRate,
      darkMode: darkMode,
      language: language,
      notificationsEnabled: notificationsEnabled,
    );
  }
}
