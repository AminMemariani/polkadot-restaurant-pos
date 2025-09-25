import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_pos_app/features/products/domain/entities/product.dart';

void main() {
  group('Product', () {
    const testProduct = Product(
      id: '1',
      name: 'Pizza Margherita',
      price: 12.99,
    );

    group('constructor', () {
      test('should create a Product with all required fields', () {
        expect(testProduct.id, '1');
        expect(testProduct.name, 'Pizza Margherita');
        expect(testProduct.price, 12.99);
      });

      test('should be immutable', () {
        expect(testProduct, isA<Product>());
        expect(testProduct.id, isA<String>());
        expect(testProduct.name, isA<String>());
        expect(testProduct.price, isA<double>());
      });
    });

    group('copyWith', () {
      test('should return a new Product with updated fields', () {
        final updatedProduct = testProduct.copyWith(
          name: 'Pizza Pepperoni',
          price: 14.99,
        );

        expect(updatedProduct.id, '1');
        expect(updatedProduct.name, 'Pizza Pepperoni');
        expect(updatedProduct.price, 14.99);
      });

      test('should return a new Product with only some fields updated', () {
        final updatedProduct = testProduct.copyWith(price: 15.99);

        expect(updatedProduct.id, '1');
        expect(updatedProduct.name, 'Pizza Margherita');
        expect(updatedProduct.price, 15.99);
      });

      test('should return the same Product when no fields are provided', () {
        final copiedProduct = testProduct.copyWith();

        expect(copiedProduct.id, testProduct.id);
        expect(copiedProduct.name, testProduct.name);
        expect(copiedProduct.price, testProduct.price);
      });

      test('should create a completely new instance', () {
        final copiedProduct = testProduct.copyWith();

        expect(copiedProduct, isNot(same(testProduct)));
        expect(copiedProduct, equals(testProduct));
      });
    });

    group('fromJson', () {
      test('should create a Product from valid JSON', () {
        final json = {
          'id': '2',
          'name': 'Burger Deluxe',
          'price': 9.99,
        };

        final product = Product.fromJson(json);

        expect(product.id, '2');
        expect(product.name, 'Burger Deluxe');
        expect(product.price, 9.99);
      });

      test('should handle integer price in JSON', () {
        final json = {
          'id': '3',
          'name': 'Coffee',
          'price': 3,
        };

        final product = Product.fromJson(json);

        expect(product.price, 3.0);
        expect(product.price, isA<double>());
      });

      test('should throw when required fields are missing', () {
        final json = {
          'id': '4',
          'name': 'Missing Price',
        };

        expect(() => Product.fromJson(json), throwsA(isA<TypeError>()));
      });
    });

    group('toJson', () {
      test('should convert Product to JSON', () {
        final json = testProduct.toJson();

        expect(json, {
          'id': '1',
          'name': 'Pizza Margherita',
          'price': 12.99,
        });
      });

      test('should produce valid JSON that can be converted back', () {
        final json = testProduct.toJson();
        final recreatedProduct = Product.fromJson(json);

        expect(recreatedProduct, equals(testProduct));
      });
    });

    group('equality', () {
      test('should be equal when all fields are the same', () {
        const product1 = Product(
          id: '1',
          name: 'Pizza',
          price: 10.0,
        );
        const product2 = Product(
          id: '1',
          name: 'Pizza',
          price: 10.0,
        );

        expect(product1, equals(product2));
        expect(product1.hashCode, equals(product2.hashCode));
      });

      test('should not be equal when fields are different', () {
        const product1 = Product(
          id: '1',
          name: 'Pizza',
          price: 10.0,
        );
        const product2 = Product(
          id: '2',
          name: 'Pizza',
          price: 10.0,
        );

        expect(product1, isNot(equals(product2)));
      });

      test('should not be equal to different types', () {
        expect(testProduct, isNot(equals('not a product')));
        expect(testProduct, isNot(equals(null)));
      });
    });

    group('toString', () {
      test('should return a string representation', () {
        final string = testProduct.toString();

        expect(string, contains('Product'));
        expect(string, contains('id: 1'));
        expect(string, contains('name: Pizza Margherita'));
        expect(string, contains('price: 12.99'));
      });
    });

    group('edge cases', () {
      test('should handle zero price', () {
        const product = Product(
          id: 'free',
          name: 'Free Item',
          price: 0.0,
        );

        expect(product.price, 0.0);
        expect(product.toJson()['price'], 0.0);
      });

      test('should handle very large prices', () {
        const product = Product(
          id: 'expensive',
          name: 'Expensive Item',
          price: 999999.99,
        );

        expect(product.price, 999999.99);
      });

      test('should handle empty strings', () {
        const product = Product(
          id: '',
          name: '',
          price: 0.0,
        );

        expect(product.id, '');
        expect(product.name, '');
        expect(product.price, 0.0);
      });

      test('should handle special characters in name', () {
        const product = Product(
          id: 'special',
          name: 'Café & Restaurant™',
          price: 15.50,
        );

        expect(product.name, 'Café & Restaurant™');
        expect(product.toJson()['name'], 'Café & Restaurant™');
      });
    });
  });
}
