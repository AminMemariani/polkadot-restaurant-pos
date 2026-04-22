import 'package:equatable/equatable.dart';

import 'money.dart';

/// All inputs a [PaymentProcessor] needs to attempt a payment.
///
/// Open-ended [metadata] lets callers attach `tableId`, `serverId`, etc.
/// without changing this contract — the same map flows through to the
/// transactions row, so it's how POS-specific context is carried.
class PaymentRequest extends Equatable {
  const PaymentRequest({
    required this.orderId,
    required this.amount,
    required this.cashierId,
    required this.locationId,
    this.tip,
    this.customerId,
    this.metadata = const {},
  });

  final String orderId;
  final Money amount;
  final Money? tip;
  final String cashierId;
  final String locationId;
  final String? customerId;
  final Map<String, String> metadata;

  Money get total => tip == null ? amount : amount + tip!;

  @override
  List<Object?> get props => [
    orderId,
    amount,
    tip,
    cashierId,
    locationId,
    customerId,
    metadata,
  ];
}
