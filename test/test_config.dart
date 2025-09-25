import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

/// Test configuration and utilities
class TestConfig {
  static GetIt get sl => GetIt.instance;

  /// Setup test environment
  static void setupTestEnvironment() {
    TestWidgetsFlutterBinding.ensureInitialized();
  }

  /// Reset service locator for tests
  static void resetServiceLocator() {
    if (sl.isRegistered<GetIt>()) {
      sl.reset();
    }
  }

  /// Mock data for testing
  static const Map<String, dynamic> mockProductData = {
    'id': 'test_product_1',
    'name': 'Test Product',
    'price': 9.99,
    'description': 'A test product for unit testing',
    'category': 'Test Category',
    'isAvailable': true,
  };

  static const Map<String, dynamic> mockReceiptData = {
    'id': 'test_receipt_1',
    'items': [
      {
        'productId': 'test_product_1',
        'productName': 'Test Product',
        'price': 9.99,
        'quantity': 2,
        'total': 19.98,
      },
    ],
    'subtotal': 19.98,
    'tax': 1.60,
    'serviceFee': 1.00,
    'total': 22.58,
    'createdAt': '2024-01-01T00:00:00.000Z',
  };

  static const Map<String, dynamic> mockPaymentData = {
    'id': 'test_payment_1',
    'amount': 22.58,
    'currency': 'USD',
    'status': 'confirmed',
    'method': 'blockchain',
    'transactionId': '0x1234567890abcdef',
    'createdAt': '2024-01-01T00:00:00.000Z',
  };
}

/// Test matchers for common assertions
class TestMatchers {
  static Matcher isSuccessResult() => isA<Object>().having(
    (result) => result.toString().contains('Success'),
    'result',
    isTrue,
  );

  static Matcher isFailureResult() => isA<Object>().having(
    (result) => result.toString().contains('Failure'),
    'result',
    isTrue,
  );

  static Matcher hasValidProductData() => isA<Map<String, dynamic>>().having(
    (data) =>
        data['id'] != null && data['name'] != null && data['price'] != null,
    'valid product data',
    isTrue,
  );

  static Matcher hasValidReceiptData() => isA<Map<String, dynamic>>().having(
    (data) =>
        data['id'] != null && data['items'] != null && data['total'] != null,
    'valid receipt data',
    isTrue,
  );
}

/// Test utilities for common operations
class TestUtils {
  /// Create a mock product for testing
  static Map<String, dynamic> createMockProduct({
    String id = 'test_product',
    String name = 'Test Product',
    double price = 9.99,
    String description = 'Test description',
    String category = 'Test Category',
    bool isAvailable = true,
  }) {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'category': category,
      'isAvailable': isAvailable,
    };
  }

  /// Create a mock receipt for testing
  static Map<String, dynamic> createMockReceipt({
    String id = 'test_receipt',
    List<Map<String, dynamic>>? items,
    double subtotal = 19.98,
    double tax = 1.60,
    double serviceFee = 1.00,
    double total = 22.58,
  }) {
    return {
      'id': id,
      'items':
          items ??
          [
            {
              'productId': 'test_product_1',
              'productName': 'Test Product',
              'price': 9.99,
              'quantity': 2,
              'total': 19.98,
            },
          ],
      'subtotal': subtotal,
      'tax': tax,
      'serviceFee': serviceFee,
      'total': total,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  /// Create a mock payment for testing
  static Map<String, dynamic> createMockPayment({
    String id = 'test_payment',
    double amount = 22.58,
    String currency = 'USD',
    String status = 'confirmed',
    String method = 'blockchain',
    String? transactionId,
  }) {
    return {
      'id': id,
      'amount': amount,
      'currency': currency,
      'status': status,
      'method': method,
      'transactionId':
          transactionId ??
          '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}',
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  /// Wait for async operations to complete
  static Future<void> waitForAsync() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Create a test widget with common setup
  static Widget createTestWidget({
    required Widget child,
    List<Provider>? providers,
  }) {
    return MaterialApp(home: Scaffold(body: child));
  }
}
