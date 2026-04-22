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

/// Wraps the existing blockchain payment flow behind [PaymentProcessor].
///
/// Two instances are registered (one per network) so the cashier sees
/// "Polkadot (DOT)" and "Kusama (KSM)" as distinct options. Behaviour is
/// identical to the previous inline logic in `PaymentsProvider`: emit a
/// waiting state, simulate confirmation after a network-specific delay, then
/// resolve with a generated tx hash. Once a real RPC integration replaces
/// the simulation, only [process] needs to change.
class BlockchainPaymentProcessor implements PaymentProcessor {
  BlockchainPaymentProcessor({
    required PaymentMethod method,
    required String displayName,
    required Duration confirmationDelay,
  })  : _method = method,
        _displayName = displayName,
        _confirmationDelay = confirmationDelay;

  final PaymentMethod _method;
  final String _displayName;
  final Duration _confirmationDelay;

  @override
  PaymentMethod get method => _method;

  @override
  String get displayName => _displayName;

  @override
  IconData get icon => AppIcons.accountBalanceWallet;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Stream<PaymentProgress> process(PaymentRequest request) async* {
    yield const PaymentProgress.creating();

    final paymentId = _generatePaymentId();
    yield const PaymentProgress.awaitingUser(
      hint: 'Scan QR code to complete payment',
    );

    await Future.delayed(_confirmationDelay);

    final txId = _generateBlockchainTxId();
    yield PaymentProgress.succeeded(
      PaymentResult(
        providerPaymentId: paymentId,
        status: PaymentResultStatus.succeeded,
        method: _method,
        amountCharged: request.amount,
        tipCaptured: request.tip,
        completedAt: DateTime.now(),
        raw: {'blockchain_tx_id': txId, 'network': _displayName},
      ),
    );
  }

  @override
  Future<RefundResult> refund(RefundRequest request) {
    throw UnsupportedError(
      'Blockchain payments are irreversible — issue a manual transfer instead.',
    );
  }

  String _generatePaymentId() {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final rand = Random().nextInt(9999).toString().padLeft(4, '0');
    return 'PAY_${ts}_$rand';
  }

  String _generateBlockchainTxId() {
    final rand = Random();
    const hex = '0123456789abcdef';
    return '0x${List.generate(64, (_) => hex[rand.nextInt(hex.length)]).join()}';
  }
}
