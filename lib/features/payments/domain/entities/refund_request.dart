import 'package:equatable/equatable.dart';

import 'money.dart';

/// Refund request. [amount] null means refund the full original charge.
class RefundRequest extends Equatable {
  const RefundRequest({
    required this.providerPaymentId,
    this.amount,
    this.reason,
  });

  final String providerPaymentId;
  final Money? amount;
  final String? reason;

  bool get isPartial => amount != null;

  @override
  List<Object?> get props => [providerPaymentId, amount, reason];
}

class RefundResult extends Equatable {
  const RefundResult({
    required this.refundId,
    required this.providerPaymentId,
    required this.amount,
    required this.completedAt,
  });

  final String refundId;
  final String providerPaymentId;
  final Money amount;
  final DateTime completedAt;

  @override
  List<Object?> get props => [refundId, providerPaymentId, amount, completedAt];
}
