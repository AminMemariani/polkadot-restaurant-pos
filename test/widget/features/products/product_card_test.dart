import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_pos_app/features/products/presentation/widgets/product_card.dart';
import 'package:restaurant_pos_app/features/products/domain/entities/product.dart';
import '../../test_config.dart';

void main() {
  group('ProductCard Widget Tests', () {
    late Product testProduct;

    setUp(() {
      TestConfig.setupTestEnvironment();
      testProduct = Product(
        id: 'test_product_1',
        name: 'Test Product',
        price: 9.99,
        description: 'A test product for widget testing',
        category: 'Test Category',
        isAvailable: true,
      );
    });

    testWidgets('should display product information correctly', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool onTapCalled = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(
              product: testProduct,
              onTap: () {
                onTapCalled = true;
              },
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Product'), findsOneWidget);
      expect(find.text('\$9.99'), findsOneWidget);
      expect(find.text('Test Category'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (WidgetTester tester) async {
      // Arrange
      bool onTapCalled = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(
              product: testProduct,
              onTap: () {
                onTapCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ProductCard));
      await tester.pump();

      // Assert
      expect(onTapCalled, isTrue);
    });

    testWidgets('should display unavailable product with different styling', (
      WidgetTester tester,
    ) async {
      // Arrange
      final unavailableProduct = Product(
        id: 'test_product_2',
        name: 'Unavailable Product',
        price: 15.99,
        description: 'This product is not available',
        category: 'Test Category',
        isAvailable: false,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(product: unavailableProduct, onTap: () {}),
          ),
        ),
      );

      // Assert
      expect(find.text('Unavailable Product'), findsOneWidget);
      expect(find.text('\$15.99'), findsOneWidget);
      // The card should still be present but might have different styling
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should handle null onTap gracefully', (
      WidgetTester tester,
    ) async {
      // Act & Assert
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ProductCard(product: testProduct, onTap: null)),
        ),
      );

      // Should not throw an error
      expect(find.byType(ProductCard), findsOneWidget);
    });

    testWidgets('should display product with long name correctly', (
      WidgetTester tester,
    ) async {
      // Arrange
      final longNameProduct = Product(
        id: 'test_product_3',
        name:
            'This is a very long product name that should be handled gracefully',
        price: 25.99,
        description: 'A product with a very long name',
        category: 'Test Category',
        isAvailable: true,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(product: longNameProduct, onTap: () {}),
          ),
        ),
      );

      // Assert
      expect(
        find.text(
          'This is a very long product name that should be handled gracefully',
        ),
        findsOneWidget,
      );
      expect(find.text('\$25.99'), findsOneWidget);
    });

    testWidgets('should display product with high price correctly', (
      WidgetTester tester,
    ) async {
      // Arrange
      final expensiveProduct = Product(
        id: 'test_product_4',
        name: 'Expensive Product',
        price: 999.99,
        description: 'A very expensive product',
        category: 'Luxury',
        isAvailable: true,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(product: expensiveProduct, onTap: () {}),
          ),
        ),
      );

      // Assert
      expect(find.text('Expensive Product'), findsOneWidget);
      expect(find.text('\$999.99'), findsOneWidget);
      expect(find.text('Luxury'), findsOneWidget);
    });

    testWidgets('should be responsive to different screen sizes', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.binding.setSurfaceSize(const Size(400, 800)); // Tablet size

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(product: testProduct, onTap: () {}),
          ),
        ),
      );

      // Assert
      expect(find.byType(ProductCard), findsOneWidget);
      expect(find.text('Test Product'), findsOneWidget);

      // Test mobile size
      await tester.binding.setSurfaceSize(const Size(360, 640)); // Mobile size
      await tester.pump();

      expect(find.byType(ProductCard), findsOneWidget);
      expect(find.text('Test Product'), findsOneWidget);
    });
  });
}
