import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_pos_app/features/payments/domain/entities/payment.dart';

void main() {
  group('Payment', () {
    const testPayment = Payment(
      id: 'payment-1',
      status: 'completed',
      amount: 30.00,
      blockchainTxId: '0x1234567890abcdef',
    );

    const testPaymentWithoutBlockchain = Payment(
      id: 'payment-2',
      status: 'pending',
      amount: 25.50,
    );

    group('constructor', () {
      test('should create a Payment with all required fields', () {
        expect(testPayment.id, 'payment-1');
        expect(testPayment.status, 'completed');
        expect(testPayment.amount, 30.00);
        expect(testPayment.blockchainTxId, '0x1234567890abcdef');
      });

      test('should create a Payment without blockchain transaction ID', () {
        expect(testPaymentWithoutBlockchain.id, 'payment-2');
        expect(testPaymentWithoutBlockchain.status, 'pending');
        expect(testPaymentWithoutBlockchain.amount, 25.50);
        expect(testPaymentWithoutBlockchain.blockchainTxId, isNull);
      });

      test('should be immutable', () {
        expect(testPayment, isA<Payment>());
        expect(testPayment.id, isA<String>());
        expect(testPayment.status, isA<String>());
        expect(testPayment.amount, isA<double>());
        expect(testPayment.blockchainTxId, isA<String?>());
      });
    });

    group('copyWith', () {
      test('should return a new Payment with updated fields', () {
        final updatedPayment = testPayment.copyWith(
          status: 'failed',
          amount: 35.00,
          blockchainTxId: '0xabcdef1234567890',
        );

        expect(updatedPayment.id, 'payment-1');
        expect(updatedPayment.status, 'failed');
        expect(updatedPayment.amount, 35.00);
        expect(updatedPayment.blockchainTxId, '0xabcdef1234567890');
      });

      test('should return a new Payment with only some fields updated', () {
        final updatedPayment = testPayment.copyWith(status: 'processing');

        expect(updatedPayment.id, 'payment-1');
        expect(updatedPayment.status, 'processing');
        expect(updatedPayment.amount, 30.00);
        expect(updatedPayment.blockchainTxId, '0x1234567890abcdef');
      });

      test('should return the same Payment when no fields are provided', () {
        final copiedPayment = testPayment.copyWith();

        expect(copiedPayment.id, testPayment.id);
        expect(copiedPayment.status, testPayment.status);
        expect(copiedPayment.amount, testPayment.amount);
        expect(copiedPayment.blockchainTxId, testPayment.blockchainTxId);
      });

      test('should create a completely new instance', () {
        final copiedPayment = testPayment.copyWith();

        expect(copiedPayment, isNot(same(testPayment)));
        expect(copiedPayment, equals(testPayment));
      });

      test('should handle null blockchainTxId in copyWith', () {
        final updatedPayment = testPayment.copyWith(clearBlockchainTxId: true);

        expect(updatedPayment.blockchainTxId, isNull);
      });

      test('should handle setting blockchainTxId from null', () {
        final updatedPayment = testPaymentWithoutBlockchain.copyWith(
          blockchainTxId: '0xnewtransaction',
        );

        expect(updatedPayment.blockchainTxId, '0xnewtransaction');
      });
    });

    group('fromJson', () {
      test('should create a Payment from valid JSON with blockchainTxId', () {
        final json = {
          'id': 'payment-3',
          'status': 'completed',
          'amount': 45.99,
          'blockchainTxId': '0xabcdef1234567890',
        };

        final payment = Payment.fromJson(json);

        expect(payment.id, 'payment-3');
        expect(payment.status, 'completed');
        expect(payment.amount, 45.99);
        expect(payment.blockchainTxId, '0xabcdef1234567890');
      });

      test('should create a Payment from valid JSON without blockchainTxId', () {
        final json = {
          'id': 'payment-4',
          'status': 'pending',
          'amount': 20.00,
        };

        final payment = Payment.fromJson(json);

        expect(payment.id, 'payment-4');
        expect(payment.status, 'pending');
        expect(payment.amount, 20.00);
        expect(payment.blockchainTxId, isNull);
      });

      test('should handle integer amount in JSON', () {
        final json = {
          'id': 'payment-5',
          'status': 'completed',
          'amount': 50,
        };

        final payment = Payment.fromJson(json);

        expect(payment.amount, 50.0);
        expect(payment.amount, isA<double>());
      });

      test('should throw when required fields are missing', () {
        final json = {
          'id': 'incomplete',
          'status': 'pending',
        };

        expect(() => Payment.fromJson(json), throwsA(isA<TypeError>()));
      });

      test('should handle null blockchainTxId in JSON', () {
        final json = {
          'id': 'payment-6',
          'status': 'pending',
          'amount': 15.00,
          'blockchainTxId': null,
        };

        final payment = Payment.fromJson(json);

        expect(payment.blockchainTxId, isNull);
      });
    });

    group('toJson', () {
      test('should convert Payment to JSON with blockchainTxId', () {
        final json = testPayment.toJson();

        expect(json, {
          'id': 'payment-1',
          'status': 'completed',
          'amount': 30.00,
          'blockchainTxId': '0x1234567890abcdef',
        });
      });

      test('should convert Payment to JSON without blockchainTxId', () {
        final json = testPaymentWithoutBlockchain.toJson();

        expect(json, {
          'id': 'payment-2',
          'status': 'pending',
          'amount': 25.50,
        });
        expect(json.containsKey('blockchainTxId'), isFalse);
      });

      test('should produce valid JSON that can be converted back', () {
        final json = testPayment.toJson();
        final recreatedPayment = Payment.fromJson(json);

        expect(recreatedPayment, equals(testPayment));
      });

      test('should produce valid JSON without blockchainTxId that can be converted back', () {
        final json = testPaymentWithoutBlockchain.toJson();
        final recreatedPayment = Payment.fromJson(json);

        expect(recreatedPayment, equals(testPaymentWithoutBlockchain));
      });
    });

    group('equality', () {
      test('should be equal when all fields are the same', () {
        const payment1 = Payment(
          id: 'same',
          status: 'completed',
          amount: 30.00,
          blockchainTxId: '0x123',
        );
        const payment2 = Payment(
          id: 'same',
          status: 'completed',
          amount: 30.00,
          blockchainTxId: '0x123',
        );

        expect(payment1, equals(payment2));
        expect(payment1.hashCode, equals(payment2.hashCode));
      });

      test('should be equal when both have null blockchainTxId', () {
        const payment1 = Payment(
          id: 'same',
          status: 'pending',
          amount: 25.00,
        );
        const payment2 = Payment(
          id: 'same',
          status: 'pending',
          amount: 25.00,
        );

        expect(payment1, equals(payment2));
        expect(payment1.hashCode, equals(payment2.hashCode));
      });

      test('should not be equal when blockchainTxId differs', () {
        const payment1 = Payment(
          id: 'same',
          status: 'completed',
          amount: 30.00,
          blockchainTxId: '0x123',
        );
        const payment2 = Payment(
          id: 'same',
          status: 'completed',
          amount: 30.00,
          blockchainTxId: '0x456',
        );

        expect(payment1, isNot(equals(payment2)));
      });

      test('should not be equal when one has blockchainTxId and other does not', () {
        const payment1 = Payment(
          id: 'same',
          status: 'completed',
          amount: 30.00,
          blockchainTxId: '0x123',
        );
        const payment2 = Payment(
          id: 'same',
          status: 'completed',
          amount: 30.00,
        );

        expect(payment1, isNot(equals(payment2)));
      });

      test('should not be equal when other fields are different', () {
        const payment1 = Payment(
          id: '1',
          status: 'completed',
          amount: 30.00,
        );
        const payment2 = Payment(
          id: '2',
          status: 'completed',
          amount: 30.00,
        );

        expect(payment1, isNot(equals(payment2)));
      });

      test('should not be equal to different types', () {
        expect(testPayment, isNot(equals('not a payment')));
        expect(testPayment, isNot(equals(null)));
      });
    });

    group('toString', () {
      test('should return a string representation with blockchainTxId', () {
        final string = testPayment.toString();

        expect(string, contains('Payment'));
        expect(string, contains('id: payment-1'));
        expect(string, contains('status: completed'));
        expect(string, contains('amount: 30.0'));
        expect(string, contains('blockchainTxId: 0x1234567890abcdef'));
      });

      test('should return a string representation without blockchainTxId', () {
        final string = testPaymentWithoutBlockchain.toString();

        expect(string, contains('Payment'));
        expect(string, contains('id: payment-2'));
        expect(string, contains('status: pending'));
        expect(string, contains('amount: 25.5'));
        expect(string, contains('blockchainTxId: null'));
      });
    });

    group('edge cases', () {
      test('should handle zero amount', () {
        const payment = Payment(
          id: 'free',
          status: 'completed',
          amount: 0.0,
        );

        expect(payment.amount, 0.0);
        expect(payment.toJson()['amount'], 0.0);
      });

      test('should handle very large amounts', () {
        const payment = Payment(
          id: 'expensive',
          status: 'completed',
          amount: 999999.99,
        );

        expect(payment.amount, 999999.99);
      });

      test('should handle empty strings', () {
        const payment = Payment(
          id: '',
          status: '',
          amount: 0.0,
        );

        expect(payment.id, '');
        expect(payment.status, '');
        expect(payment.amount, 0.0);
      });

      test('should handle various status values', () {
        const statuses = ['pending', 'processing', 'completed', 'failed', 'cancelled'];
        
        for (final status in statuses) {
          final payment = Payment(
            id: 'test',
            status: status,
            amount: 10.0,
          );
          
          expect(payment.status, status);
          expect(payment.toJson()['status'], status);
        }
      });

      test('should handle various blockchain transaction ID formats', () {
        const txIds = [
          '0x1234567890abcdef',
          '0xabcdef1234567890',
          '0x0000000000000000',
          '0xffffffffffffffff',
        ];
        
        for (final txId in txIds) {
          final payment = Payment(
            id: 'test',
            status: 'completed',
            amount: 10.0,
            blockchainTxId: txId,
          );
          
          expect(payment.blockchainTxId, txId);
          expect(payment.toJson()['blockchainTxId'], txId);
        }
      });
    });
  });
}
