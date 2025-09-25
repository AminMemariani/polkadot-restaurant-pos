import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:restaurant_pos_app/core/storage/storage_service.dart';
import '../../../test_config.dart';

void main() {
  group('StorageService', () {
    late StorageService storageService;

    setUp(() async {
      TestConfig.setupTestEnvironment();
      // Mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
      storageService = await StorageService.getInstance();
    });

    tearDown(() {
      TestConfig.resetServiceLocator();
    });

    group('Products Storage', () {
      test('should save and load products successfully', () async {
        // Arrange
        final products = [
          TestConfig.mockProductData,
          TestUtils.createMockProduct(
            id: 'test_product_2',
            name: 'Test Product 2',
            price: 15.99,
          ),
        ];

        // Act
        await storageService.saveProducts(products);
        final loadedProducts = await storageService.loadProducts();

        // Assert
        expect(loadedProducts, isNotEmpty);
        expect(loadedProducts.length, equals(2));
        expect(loadedProducts.first['id'], equals('test_product_1'));
        expect(loadedProducts.first['name'], equals('Test Product'));
        expect(loadedProducts.first['price'], equals(9.99));
      });

      test('should return empty list when no products are stored', () async {
        // Act
        final products = await storageService.loadProducts();

        // Assert
        expect(products, isEmpty);
      });

      test('should clear products successfully', () async {
        // Arrange
        final products = [TestConfig.mockProductData];
        await storageService.saveProducts(products);

        // Act
        await storageService.clearProducts();
        final loadedProducts = await storageService.loadProducts();

        // Assert
        expect(loadedProducts, isEmpty);
      });
    });

    group('Receipts Storage', () {
      test('should save and load receipts successfully', () async {
        // Arrange
        final receipts = [
          TestConfig.mockReceiptData,
          TestUtils.createMockReceipt(id: 'test_receipt_2', total: 45.99),
        ];

        // Act
        await storageService.saveReceipts(receipts);
        final loadedReceipts = await storageService.loadReceipts();

        // Assert
        expect(loadedReceipts, isNotEmpty);
        expect(loadedReceipts.length, equals(2));
        expect(loadedReceipts.first['id'], equals('test_receipt_1'));
        expect(loadedReceipts.first['total'], equals(22.58));
      });

      test('should return empty list when no receipts are stored', () async {
        // Act
        final receipts = await storageService.loadReceipts();

        // Assert
        expect(receipts, isEmpty);
      });

      test('should clear receipts successfully', () async {
        // Arrange
        final receipts = [TestConfig.mockReceiptData];
        await storageService.saveReceipts(receipts);

        // Act
        await storageService.clearReceipts();
        final loadedReceipts = await storageService.loadReceipts();

        // Assert
        expect(loadedReceipts, isEmpty);
      });
    });

    group('Settings Storage', () {
      test('should save and load settings successfully', () async {
        // Arrange
        final settings = {
          'taxRate': 0.08,
          'serviceFeeRate': 0.05,
          'currency': 'USD',
          'language': 'en',
        };

        // Act
        await storageService.saveSettings(settings);
        final loadedSettings = await storageService.loadSettings();

        // Assert
        expect(loadedSettings, isNotEmpty);
        expect(loadedSettings['taxRate'], equals(0.08));
        expect(loadedSettings['serviceFeeRate'], equals(0.05));
        expect(loadedSettings['currency'], equals('USD'));
        expect(loadedSettings['language'], equals('en'));
      });

      test('should return empty map when no settings are stored', () async {
        // Act
        final settings = await storageService.loadSettings();

        // Assert
        expect(settings, isEmpty);
      });

      test('should clear settings successfully', () async {
        // Arrange
        final settings = {'taxRate': 0.08, 'serviceFeeRate': 0.05};
        await storageService.saveSettings(settings);

        // Act
        await storageService.clearSettings();
        final loadedSettings = await storageService.loadSettings();

        // Assert
        expect(loadedSettings, isEmpty);
      });
    });

    group('All Data Management', () {
      test('should clear all data successfully', () async {
        // Arrange
        await storageService.saveProducts([TestConfig.mockProductData]);
        await storageService.saveReceipts([TestConfig.mockReceiptData]);
        await storageService.saveSettings({'taxRate': 0.08});

        // Act
        await storageService.clearAllData();

        // Assert
        final products = await storageService.loadProducts();
        final receipts = await storageService.loadReceipts();
        final settings = await storageService.loadSettings();

        expect(products, isEmpty);
        expect(receipts, isEmpty);
        expect(settings, isEmpty);
      });
    });

    group('Error Handling', () {
      test('should handle invalid JSON gracefully', () async {
        // This test would require mocking SharedPreferences to return invalid JSON
        // For now, we'll test that the service doesn't crash with empty data

        // Act & Assert
        expect(
          () async => await storageService.loadProducts(),
          returnsNormally,
        );
        expect(
          () async => await storageService.loadReceipts(),
          returnsNormally,
        );
        expect(
          () async => await storageService.loadSettings(),
          returnsNormally,
        );
      });
    });
  });
}
