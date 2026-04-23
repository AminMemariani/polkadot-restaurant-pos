import 'dart:async';
import 'dart:convert';
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
/// "Polkadot (DOT)" and "Kusama (KSM)" as distinct options. The processor
/// emits a JSON-encoded payload as `qrData` containing the full transaction
/// context (amount, network, order id, table number, serve time) so a
/// scanning wallet has everything it needs.
///
/// TODO(real-onchain): replace the JSON payload with a Polkadot URI scheme
/// (`polkadot:<address>?amount=...&memo=...`) once a recipient wallet
/// address is configured per location, and replace the simulated delay with
/// a real RPC subscription via the Substrate client.
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
    final now = DateTime.now();

    final payload = <String, dynamic>{
      'v': 1,
      'type': _method.id, // 'polkadot' | 'kusama'
      'paymentId': paymentId,
      'orderId': request.orderId,
      'amount': request.amount.toMajor().toStringAsFixed(2),
      'currency': request.amount.currency,
      'network': _displayName,
      'tip': request.tip?.toMajor().toStringAsFixed(2),
      'tableNumber': request.metadata['table_number'],
      'serveAt': request.metadata['serve_at'],
      'createdAt': now.toIso8601String(),
    }..removeWhere((_, v) => v == null);

    yield PaymentProgress.awaitingUser(
      hint: 'Scan QR code to complete payment',
      qrData: jsonEncode(payload),
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
        raw: {'blockchain_tx_id': txId, 'network': _displayName, 'qr': payload},
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
