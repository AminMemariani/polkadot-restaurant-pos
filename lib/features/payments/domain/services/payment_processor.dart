import 'package:flutter/widgets.dart';

import '../entities/payment_method.dart';
import '../entities/payment_progress.dart';
import '../entities/payment_request.dart';
import '../entities/refund_request.dart';

/// Contract every payment rail implements.
///
/// One processor per rail (blockchain network, Stripe card, Stripe Terminal,
/// cash). The presentation layer never branches on the underlying provider —
/// it asks the [PaymentMethodRegistry] for the processor matching the
/// cashier's selection and consumes [process] as an event stream.
abstract class PaymentProcessor {
  /// Stable identifier of the rail.
  PaymentMethod get method;

  /// Cashier-facing name. Localised at the UI layer if needed.
  String get displayName;

  /// Icon shown in the method picker.
  IconData get icon;

  /// Whether this rail is selectable right now (online, hardware connected,
  /// network reachable, etc.). Cheap to call — UI may invoke on every rebuild.
  Future<bool> isAvailable();

  /// Run the payment. Emits at least one terminal event
  /// ([PaymentSucceeded] / [PaymentFailed] / [PaymentCancelled]).
  Stream<PaymentProgress> process(PaymentRequest request);

  /// Reverse a previously succeeded payment (full or partial). Throws
  /// [UnsupportedError] for rails that cannot refund (cash is reconciled
  /// out-of-band, blockchain is irreversible — both override and throw).
  Future<RefundResult> refund(RefundRequest request);
}
