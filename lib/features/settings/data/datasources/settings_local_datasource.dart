import 'package:shared_preferences/shared_preferences.dart';

import '../models/settings_model.dart';

abstract class SettingsLocalDataSource {
  Future<SettingsModel> getSettings();
  Future<SettingsModel> updateSettings(SettingsModel settings);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _settingsKey = 'app_settings';

  SettingsLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<SettingsModel> getSettings() async {
    final settingsJson = sharedPreferences.getString(_settingsKey);
    if (settingsJson != null) {
      return SettingsModel.fromJson(settingsJson);
    }
    return SettingsModel.defaultSettings();
  }

  @override
  Future<SettingsModel> updateSettings(SettingsModel settings) async {
    await sharedPreferences.setString(_settingsKey, settings.toJson());
    return settings;
  }
}
