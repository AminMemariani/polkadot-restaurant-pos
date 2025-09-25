import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_pos_app/features/receipts/domain/entities/receipt.dart';

void main() {
  group('Receipt', () {
    const testReceiptItem = ReceiptItem(
      productId: '1',
      productName: 'Pizza Margherita',
      price: 12.99,
      quantity: 2,
      total: 25.98,
    );

    const testReceipt = Receipt(
      id: 'receipt-1',
      items: [testReceiptItem],
      total: 30.00,
      tax: 2.40,
      serviceFee: 1.62,
    );

    group('constructor', () {
      test('should create a Receipt with all required fields', () {
        expect(testReceipt.id, 'receipt-1');
        expect(testReceipt.items, [testReceiptItem]);
        expect(testReceipt.total, 30.00);
        expect(testReceipt.tax, 2.40);
        expect(testReceipt.serviceFee, 1.62);
      });

      test('should be immutable', () {
        expect(testReceipt, isA<Receipt>());
        expect(testReceipt.id, isA<String>());
        expect(testReceipt.items, isA<List<ReceiptItem>>());
        expect(testReceipt.total, isA<double>());
        expect(testReceipt.tax, isA<double>());
        expect(testReceipt.serviceFee, isA<double>());
      });
    });

    group('copyWith', () {
      test('should return a new Receipt with updated fields', () {
        const newItem = ReceiptItem(
          productId: '2',
          productName: 'Burger',
          price: 8.99,
          quantity: 1,
          total: 8.99,
        );

        final updatedReceipt = testReceipt.copyWith(
          total: 40.00,
          tax: 3.20,
          items: [testReceiptItem, newItem],
        );

        expect(updatedReceipt.id, 'receipt-1');
        expect(updatedReceipt.items, [testReceiptItem, newItem]);
        expect(updatedReceipt.total, 40.00);
        expect(updatedReceipt.tax, 3.20);
        expect(updatedReceipt.serviceFee, 1.62);
      });

      test('should return a new Receipt with only some fields updated', () {
        final updatedReceipt = testReceipt.copyWith(total: 35.00);

        expect(updatedReceipt.id, 'receipt-1');
        expect(updatedReceipt.items, [testReceiptItem]);
        expect(updatedReceipt.total, 35.00);
        expect(updatedReceipt.tax, 2.40);
        expect(updatedReceipt.serviceFee, 1.62);
      });

      test('should return the same Receipt when no fields are provided', () {
        final copiedReceipt = testReceipt.copyWith();

        expect(copiedReceipt.id, testReceipt.id);
        expect(copiedReceipt.items, testReceipt.items);
        expect(copiedReceipt.total, testReceipt.total);
        expect(copiedReceipt.tax, testReceipt.tax);
        expect(copiedReceipt.serviceFee, testReceipt.serviceFee);
      });

      test('should create a completely new instance', () {
        final copiedReceipt = testReceipt.copyWith();

        expect(copiedReceipt, isNot(same(testReceipt)));
        expect(copiedReceipt, equals(testReceipt));
      });
    });

    group('fromJson', () {
      test('should create a Receipt from valid JSON', () {
        final json = {
          'id': 'receipt-2',
          'items': [
            {
              'productId': '1',
              'productName': 'Pizza',
              'price': 12.99,
              'quantity': 1,
              'total': 12.99,
            },
          ],
          'total': 15.00,
          'tax': 1.20,
          'serviceFee': 0.81,
        };

        final receipt = Receipt.fromJson(json);

        expect(receipt.id, 'receipt-2');
        expect(receipt.items.length, 1);
        expect(receipt.items.first.productId, '1');
        expect(receipt.total, 15.00);
        expect(receipt.tax, 1.20);
        expect(receipt.serviceFee, 0.81);
      });

      test('should handle empty items list', () {
        final json = {
          'id': 'empty-receipt',
          'items': [],
          'total': 0.0,
          'tax': 0.0,
          'serviceFee': 0.0,
        };

        final receipt = Receipt.fromJson(json);

        expect(receipt.items, isEmpty);
        expect(receipt.total, 0.0);
      });

      test('should throw when required fields are missing', () {
        final json = {'id': 'incomplete', 'items': []};

        expect(() => Receipt.fromJson(json), throwsA(isA<TypeError>()));
      });
    });

    group('toJson', () {
      test('should convert Receipt to JSON', () {
        final json = testReceipt.toJson();

        expect(json['id'], 'receipt-1');
        expect(json['total'], 30.00);
        expect(json['tax'], 2.40);
        expect(json['serviceFee'], 1.62);
        expect(json['items'], isA<List>());
        expect(json['items'].length, 1);
      });

      test('should produce valid JSON that can be converted back', () {
        final json = testReceipt.toJson();
        final recreatedReceipt = Receipt.fromJson(json);

        expect(recreatedReceipt, equals(testReceipt));
      });
    });

    group('equality', () {
      test('should be equal when all fields are the same', () {
        const receipt1 = Receipt(
          id: 'same',
          items: [testReceiptItem],
          total: 30.00,
          tax: 2.40,
          serviceFee: 1.62,
        );
        const receipt2 = Receipt(
          id: 'same',
          items: [testReceiptItem],
          total: 30.00,
          tax: 2.40,
          serviceFee: 1.62,
        );

        expect(receipt1, equals(receipt2));
        expect(receipt1.hashCode, equals(receipt2.hashCode));
      });

      test('should not be equal when fields are different', () {
        const receipt1 = Receipt(
          id: '1',
          items: [testReceiptItem],
          total: 30.00,
          tax: 2.40,
          serviceFee: 1.62,
        );
        const receipt2 = Receipt(
          id: '2',
          items: [testReceiptItem],
          total: 30.00,
          tax: 2.40,
          serviceFee: 1.62,
        );

        expect(receipt1, isNot(equals(receipt2)));
      });
    });

    group('toString', () {
      test('should return a string representation', () {
        final string = testReceipt.toString();

        expect(string, contains('Receipt'));
        expect(string, contains('id: receipt-1'));
        expect(string, contains('total: 30.0'));
        expect(string, contains('tax: 2.4'));
        expect(string, contains('serviceFee: 1.62'));
      });
    });

    group('edge cases', () {
      test('should handle zero values', () {
        const receipt = Receipt(
          id: 'zero',
          items: [],
          total: 0.0,
          tax: 0.0,
          serviceFee: 0.0,
        );

        expect(receipt.total, 0.0);
        expect(receipt.tax, 0.0);
        expect(receipt.serviceFee, 0.0);
      });

      test('should handle very large amounts', () {
        const receipt = Receipt(
          id: 'expensive',
          items: [],
          total: 999999.99,
          tax: 79999.99,
          serviceFee: 39999.99,
        );

        expect(receipt.total, 999999.99);
        expect(receipt.tax, 79999.99);
        expect(receipt.serviceFee, 39999.99);
      });
    });
  });

  group('ReceiptItem', () {
    const testItem = ReceiptItem(
      productId: '1',
      productName: 'Pizza Margherita',
      price: 12.99,
      quantity: 2,
      total: 25.98,
    );

    group('constructor', () {
      test('should create a ReceiptItem with all required fields', () {
        expect(testItem.productId, '1');
        expect(testItem.productName, 'Pizza Margherita');
        expect(testItem.price, 12.99);
        expect(testItem.quantity, 2);
        expect(testItem.total, 25.98);
      });

      test('should be immutable', () {
        expect(testItem, isA<ReceiptItem>());
        expect(testItem.productId, isA<String>());
        expect(testItem.productName, isA<String>());
        expect(testItem.price, isA<double>());
        expect(testItem.quantity, isA<int>());
        expect(testItem.total, isA<double>());
      });
    });

    group('copyWith', () {
      test('should return a new ReceiptItem with updated fields', () {
        final updatedItem = testItem.copyWith(quantity: 3, total: 38.97);

        expect(updatedItem.productId, '1');
        expect(updatedItem.productName, 'Pizza Margherita');
        expect(updatedItem.price, 12.99);
        expect(updatedItem.quantity, 3);
        expect(updatedItem.total, 38.97);
      });

      test(
        'should return the same ReceiptItem when no fields are provided',
        () {
          final copiedItem = testItem.copyWith();

          expect(copiedItem.productId, testItem.productId);
          expect(copiedItem.productName, testItem.productName);
          expect(copiedItem.price, testItem.price);
          expect(copiedItem.quantity, testItem.quantity);
          expect(copiedItem.total, testItem.total);
        },
      );

      test('should create a completely new instance', () {
        final copiedItem = testItem.copyWith();

        expect(copiedItem, isNot(same(testItem)));
        expect(copiedItem, equals(testItem));
      });
    });

    group('fromJson', () {
      test('should create a ReceiptItem from valid JSON', () {
        final json = {
          'productId': '2',
          'productName': 'Burger',
          'price': 8.99,
          'quantity': 1,
          'total': 8.99,
        };

        final item = ReceiptItem.fromJson(json);

        expect(item.productId, '2');
        expect(item.productName, 'Burger');
        expect(item.price, 8.99);
        expect(item.quantity, 1);
        expect(item.total, 8.99);
      });

      test('should handle integer values in JSON', () {
        final json = {
          'productId': '3',
          'productName': 'Coffee',
          'price': 3,
          'quantity': 2,
          'total': 6,
        };

        final item = ReceiptItem.fromJson(json);

        expect(item.price, 3.0);
        expect(item.total, 6.0);
        expect(item.quantity, 2);
      });
    });

    group('toJson', () {
      test('should convert ReceiptItem to JSON', () {
        final json = testItem.toJson();

        expect(json, {
          'productId': '1',
          'productName': 'Pizza Margherita',
          'price': 12.99,
          'quantity': 2,
          'total': 25.98,
        });
      });

      test('should produce valid JSON that can be converted back', () {
        final json = testItem.toJson();
        final recreatedItem = ReceiptItem.fromJson(json);

        expect(recreatedItem, equals(testItem));
      });
    });

    group('equality', () {
      test('should be equal when all fields are the same', () {
        const item1 = ReceiptItem(
          productId: '1',
          productName: 'Pizza',
          price: 12.99,
          quantity: 2,
          total: 25.98,
        );
        const item2 = ReceiptItem(
          productId: '1',
          productName: 'Pizza',
          price: 12.99,
          quantity: 2,
          total: 25.98,
        );

        expect(item1, equals(item2));
        expect(item1.hashCode, equals(item2.hashCode));
      });

      test('should not be equal when fields are different', () {
        const item1 = ReceiptItem(
          productId: '1',
          productName: 'Pizza',
          price: 12.99,
          quantity: 2,
          total: 25.98,
        );
        const item2 = ReceiptItem(
          productId: '2',
          productName: 'Pizza',
          price: 12.99,
          quantity: 2,
          total: 25.98,
        );

        expect(item1, isNot(equals(item2)));
      });
    });

    group('toString', () {
      test('should return a string representation', () {
        final string = testItem.toString();

        expect(string, contains('ReceiptItem'));
        expect(string, contains('productId: 1'));
        expect(string, contains('productName: Pizza Margherita'));
        expect(string, contains('price: 12.99'));
        expect(string, contains('quantity: 2'));
        expect(string, contains('total: 25.98'));
      });
    });

    group('edge cases', () {
      test('should handle zero quantity', () {
        const item = ReceiptItem(
          productId: 'free',
          productName: 'Free Item',
          price: 0.0,
          quantity: 0,
          total: 0.0,
        );

        expect(item.quantity, 0);
        expect(item.total, 0.0);
      });

      test('should handle large quantities', () {
        const item = ReceiptItem(
          productId: 'bulk',
          productName: 'Bulk Item',
          price: 1.0,
          quantity: 1000,
          total: 1000.0,
        );

        expect(item.quantity, 1000);
        expect(item.total, 1000.0);
      });
    });
  });
}
