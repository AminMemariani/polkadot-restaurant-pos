import 'package:equatable/equatable.dart';

import 'money.dart';
import 'payment_method.dart';

enum PaymentResultStatus {
  succeeded,
  failed,
  cancelled,
  pending,
}

/// Terminal outcome of a payment attempt.
///
/// [providerPaymentId] is the rail-specific identifier (Stripe `pi_xxx`,
/// blockchain tx hash, generated UUID for cash). [raw] retains the full
/// provider payload so downstream code can audit without re-fetching.
class PaymentResult extends Equatable {
  const PaymentResult({
    required this.providerPaymentId,
    required this.status,
    required this.method,
    required this.amountCharged,
    required this.completedAt,
    this.tipCaptured,
    this.failureCode,
    this.failureReason,
    this.raw = const {},
  });

  final String providerPaymentId;
  final PaymentResultStatus status;
  final PaymentMethod method;
  final Money amountCharged;
  final Money? tipCaptured;
  final String? failureCode;
  final String? failureReason;
  final DateTime completedAt;
  final Map<String, dynamic> raw;

  bool get isTerminal =>
      status != PaymentResultStatus.pending;

  @override
  List<Object?> get props => [
    providerPaymentId,
    status,
    method,
    amountCharged,
    tipCaptured,
    failureCode,
    failureReason,
    completedAt,
    raw,
  ];
}
