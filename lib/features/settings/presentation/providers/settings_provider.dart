import 'package:flutter/foundation.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/settings.dart';
import '../../domain/usecases/get_settings.dart';
import '../../domain/usecases/update_settings.dart';

class SettingsProvider extends ChangeNotifier {
  final GetSettings getSettings;
  final UpdateSettings updateSettings;

  SettingsProvider({required this.getSettings, required this.updateSettings});

  Settings? _settings;
  bool _isLoading = false;
  String? _error;

  Settings? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSettings() async {
    _setLoading(true);
    _clearError();

    final result = await getSettings();
    result.fold(
      (failure) => _setError(_mapFailureToMessage(failure)),
      (settings) => _setSettings(settings),
    );

    _setLoading(false);
  }

  Future<bool> updateAppSettings(Settings settings) async {
    _setLoading(true);
    _clearError();

    final result = await updateSettings(settings);
    bool success = false;

    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (
      updatedSettings,
    ) {
      _setSettings(updatedSettings);
      success = true;
    });

    _setLoading(false);
    return success;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void _setSettings(Settings settings) {
    _settings = settings;
    notifyListeners();
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error: ${failure.message}';
      case NetworkFailure:
        return 'Network error: ${failure.message}';
      case CacheFailure:
        return 'Cache error: ${failure.message}';
      case ValidationFailure:
        return 'Validation error: ${failure.message}';
      default:
        return 'An unexpected error occurred: ${failure.message}';
    }
  }
}
