import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for handling local storage operations using SharedPreferences
class StorageService {
  static const String _productsKey = 'products';
  static const String _receiptsKey = 'receipts';
  static const String _settingsKey = 'settings';
  static const String _taxRateKey = 'tax_rate';
  static const String _serviceFeeRateKey = 'service_fee_rate';

  static StorageService? _instance;
  static SharedPreferences? _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  /// Save products to local storage
  Future<bool> saveProducts(List<Map<String, dynamic>> products) async {
    try {
      final jsonString = jsonEncode(products);
      return await _prefs!.setString(_productsKey, jsonString);
    } catch (e) {
      print('Error saving products: $e');
      return false;
    }
  }

  /// Load products from local storage
  Future<List<Map<String, dynamic>>> loadProducts() async {
    try {
      final jsonString = _prefs!.getString(_productsKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error loading products: $e');
      return [];
    }
  }

  /// Save receipts to local storage
  Future<bool> saveReceipts(List<Map<String, dynamic>> receipts) async {
    try {
      final jsonString = jsonEncode(receipts);
      return await _prefs!.setString(_receiptsKey, jsonString);
    } catch (e) {
      print('Error saving receipts: $e');
      return false;
    }
  }

  /// Load receipts from local storage
  Future<List<Map<String, dynamic>>> loadReceipts() async {
    try {
      final jsonString = _prefs!.getString(_receiptsKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error loading receipts: $e');
      return [];
    }
  }

  /// Save tax rate
  Future<bool> saveTaxRate(double taxRate) async {
    try {
      return await _prefs!.setDouble(_taxRateKey, taxRate);
    } catch (e) {
      print('Error saving tax rate: $e');
      return false;
    }
  }

  /// Load tax rate
  Future<double> loadTaxRate() async {
    try {
      return _prefs!.getDouble(_taxRateKey) ?? 0.08; // Default 8%
    } catch (e) {
      print('Error loading tax rate: $e');
      return 0.08;
    }
  }

  /// Save service fee rate
  Future<bool> saveServiceFeeRate(double serviceFeeRate) async {
    try {
      return await _prefs!.setDouble(_serviceFeeRateKey, serviceFeeRate);
    } catch (e) {
      print('Error saving service fee rate: $e');
      return false;
    }
  }

  /// Load service fee rate
  Future<double> loadServiceFeeRate() async {
    try {
      return _prefs!.getDouble(_serviceFeeRateKey) ?? 0.05; // Default 5%
    } catch (e) {
      print('Error loading service fee rate: $e');
      return 0.05;
    }
  }

  /// Save all settings
  Future<bool> saveSettings(Map<String, dynamic> settings) async {
    try {
      final jsonString = jsonEncode(settings);
      return await _prefs!.setString(_settingsKey, jsonString);
    } catch (e) {
      print('Error saving settings: $e');
      return false;
    }
  }

  /// Load all settings
  Future<Map<String, dynamic>> loadSettings() async {
    try {
      final jsonString = _prefs!.getString(_settingsKey);
      if (jsonString != null) {
        return jsonDecode(jsonString);
      }
      return {};
    } catch (e) {
      print('Error loading settings: $e');
      return {};
    }
  }

  /// Clear all data
  Future<bool> clearAllData() async {
    try {
      await _prefs!.remove(_productsKey);
      await _prefs!.remove(_receiptsKey);
      await _prefs!.remove(_settingsKey);
      await _prefs!.remove(_taxRateKey);
      await _prefs!.remove(_serviceFeeRateKey);
      return true;
    } catch (e) {
      print('Error clearing data: $e');
      return false;
    }
  }

  /// Clear only products
  Future<bool> clearProducts() async {
    try {
      return await _prefs!.remove(_productsKey);
    } catch (e) {
      print('Error clearing products: $e');
      return false;
    }
  }

  /// Clear only receipts
  Future<bool> clearReceipts() async {
    try {
      return await _prefs!.remove(_receiptsKey);
    } catch (e) {
      print('Error clearing receipts: $e');
      return false;
    }
  }
}
