import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../shared/utils/app_icons.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/payment_progress.dart';
import '../../domain/entities/payment_request.dart';
import '../../domain/entities/payment_result.dart';
import '../../domain/entities/refund_request.dart';
import '../../domain/services/payment_processor.dart';

/// Cash sales: no external system, the cashier just records the txn.
///
/// Resolves immediately so the UI can skip the confirmation page and return
/// to the order list. Refunds throw [UnsupportedError] — physical cash is
/// returned out-of-band.
class CashProcessor implements PaymentProcessor {
  @override
  PaymentMethod get method => PaymentMethod.cash;

  @override
  String get displayName => 'Cash';

  @override
  IconData get icon => AppIcons.payments;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Stream<PaymentProgress> process(PaymentRequest request) async* {
    yield PaymentProgress.succeeded(
      PaymentResult(
        providerPaymentId: _generatePaymentId(),
        status: PaymentResultStatus.succeeded,
        method: PaymentMethod.cash,
        amountCharged: request.amount,
        tipCaptured: request.tip,
        completedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<RefundResult> refund(RefundRequest request) {
    throw UnsupportedError('Cash refunds are handled out-of-band.');
  }

  String _generatePaymentId() {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final rand = Random().nextInt(9999).toString().padLeft(4, '0');
    return 'CASH_${ts}_$rand';
  }
}
