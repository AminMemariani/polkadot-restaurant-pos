import 'payment_result.dart';

/// Streamed updates emitted by a [PaymentProcessor] during [process].
///
/// Sealed-style hierarchy — pattern-match on the runtime type to drive UI.
/// Terminal states (`Succeeded`, `Failed`, `Cancelled`) carry the final
/// [PaymentResult] when applicable so the consumer doesn't have to reconcile
/// separately.
sealed class PaymentProgress {
  const PaymentProgress();

  const factory PaymentProgress.creating() = PaymentCreating;
  const factory PaymentProgress.awaitingUser({String? hint}) =
      PaymentAwaitingUser;
  const factory PaymentProgress.processing({String? hint}) = PaymentProcessing;
  const factory PaymentProgress.succeeded(PaymentResult result) =
      PaymentSucceeded;
  const factory PaymentProgress.failed(String message, {String? code}) =
      PaymentFailed;
  const factory PaymentProgress.cancelled() = PaymentCancelled;
}

class PaymentCreating extends PaymentProgress {
  const PaymentCreating();
}

class PaymentAwaitingUser extends PaymentProgress {
  const PaymentAwaitingUser({this.hint});
  final String? hint;
}

class PaymentProcessing extends PaymentProgress {
  const PaymentProcessing({this.hint});
  final String? hint;
}

class PaymentSucceeded extends PaymentProgress {
  const PaymentSucceeded(this.result);
  final PaymentResult result;
}

class PaymentFailed extends PaymentProgress {
  const PaymentFailed(this.message, {this.code});
  final String message;
  final String? code;
}

class PaymentCancelled extends PaymentProgress {
  const PaymentCancelled();
}
