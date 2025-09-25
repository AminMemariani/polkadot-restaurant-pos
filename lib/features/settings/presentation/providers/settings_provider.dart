import 'package:flutter/foundation.dart';

import '../../../../core/storage/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService storageService;

  SettingsProvider({required this.storageService});

  double _taxRate = 0.08; // Default 8%
  double _serviceFeeRate = 0.05; // Default 5%
  bool _isLoading = false;
  String? _error;

  // Getters
  double get taxRate => _taxRate;
  double get serviceFeeRate => _serviceFeeRate;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load settings from storage
  Future<void> loadSettings() async {
    _setLoading(true);
    _clearError();

    try {
      _taxRate = await storageService.loadTaxRate();
      _serviceFeeRate = await storageService.loadServiceFeeRate();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load settings: $e');
    }

    _setLoading(false);
  }

  /// Update tax rate
  Future<void> updateTaxRate(double taxRate) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await storageService.saveTaxRate(taxRate);
      if (success) {
        _taxRate = taxRate;
        notifyListeners();
      } else {
        _setError('Failed to save tax rate');
      }
    } catch (e) {
      _setError('Failed to update tax rate: $e');
    }

    _setLoading(false);
  }

  /// Update service fee rate
  Future<void> updateServiceFeeRate(double serviceFeeRate) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await storageService.saveServiceFeeRate(serviceFeeRate);
      if (success) {
        _serviceFeeRate = serviceFeeRate;
        notifyListeners();
      } else {
        _setError('Failed to save service fee rate');
      }
    } catch (e) {
      _setError('Failed to update service fee rate: $e');
    }

    _setLoading(false);
  }

  /// Clear all products
  Future<void> clearProducts() async {
    _setLoading(true);
    _clearError();

    try {
      final success = await storageService.clearProducts();
      if (!success) {
        _setError('Failed to clear products');
      }
    } catch (e) {
      _setError('Failed to clear products: $e');
    }

    _setLoading(false);
  }

  /// Clear all receipts
  Future<void> clearReceipts() async {
    _setLoading(true);
    _clearError();

    try {
      final success = await storageService.clearReceipts();
      if (!success) {
        _setError('Failed to clear receipts');
      }
    } catch (e) {
      _setError('Failed to clear receipts: $e');
    }

    _setLoading(false);
  }

  /// Clear all data
  Future<void> clearAllData() async {
    _setLoading(true);
    _clearError();

    try {
      final success = await storageService.clearAllData();
      if (success) {
        // Reset to default values
        _taxRate = 0.08;
        _serviceFeeRate = 0.05;
        notifyListeners();
      } else {
        _setError('Failed to clear all data');
      }
    } catch (e) {
      _setError('Failed to clear all data: $e');
    }

    _setLoading(false);
  }

  /// Set tax rate (for UI updates)
  void setTaxRate(double taxRate) {
    _taxRate = taxRate;
    notifyListeners();
  }

  /// Set service fee rate (for UI updates)
  void setServiceFeeRate(double serviceFeeRate) {
    _serviceFeeRate = serviceFeeRate;
    notifyListeners();
  }

  // Private methods
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
}
