import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/payment_progress.dart';
import '../../domain/entities/payment_request.dart';
import '../../domain/entities/payment_result.dart';
import '../../domain/services/payment_processor.dart';
import '../../domain/usecases/get_payment_methods.dart';
import '../../domain/usecases/process_payment.dart';

/// Thin orchestrator around a [PaymentProcessor].
///
/// Holds the currently-running payment's progress so the UI (typically
/// [PaymentConfirmationPage]) can rebuild on every event. All rail-specific
/// logic lives in the processor — this class knows nothing about blockchain
/// or Stripe.
class PaymentsProvider extends ChangeNotifier {
  PaymentsProvider({
    required this.processPayment,
    required this.getPaymentMethods,
  });

  // Use cases retained for the legacy traditional-payment code path (cash
  // records still flow through [recordPayment] below). When everything has
  // moved to the processor stream these can be removed.
  final ProcessPayment processPayment;
  final GetPaymentMethods getPaymentMethods;

  StreamSubscription<PaymentProgress>? _subscription;
  PaymentProcessor? _activeProcessor;
  PaymentRequest? _activeRequest;
  PaymentProgress? _progress;
  PaymentResult? _lastResult;
  String? _error;
  bool _isLoading = false;

  PaymentProgress? get progress => _progress;
  PaymentResult? get lastResult => _lastResult;
  PaymentRequest? get activeRequest => _activeRequest;
  PaymentProcessor? get activeProcessor => _activeProcessor;
  String? get error => _error;
  bool get isLoading => _isLoading;

  /// True once the current flow has emitted a terminal state
  /// (succeeded / failed / cancelled).
  bool get isTerminal {
    final p = _progress;
    return p is PaymentSucceeded || p is PaymentFailed || p is PaymentCancelled;
  }

  /// Kick off a payment via [processor]. Replaces any in-flight payment.
  ///
  /// Returns once the subscription is set up — the actual flow completes
  /// asynchronously, with updates arriving via [notifyListeners]. UI should
  /// watch [progress] and branch on its runtime type.
  Future<void> startProcessor(
    PaymentProcessor processor,
    PaymentRequest request,
  ) async {
    await _subscription?.cancel();
    _activeProcessor = processor;
    _activeRequest = request;
    _lastResult = null;
    _error = null;
    _progress = const PaymentProgress.creating();
    notifyListeners();

    _subscription = processor.process(request).listen(
      (event) {
        _progress = event;
        if (event is PaymentSucceeded) _lastResult = event.result;
        if (event is PaymentFailed) _error = event.message;
        notifyListeners();
      },
      onError: (Object e, StackTrace _) {
        _progress = PaymentFailed(e.toString());
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  /// Cancel the in-flight payment (if any). Emits [PaymentCancelled] so UI
  /// can react; does not reset [lastResult].
  void cancel() {
    _subscription?.cancel();
    _subscription = null;
    _progress = const PaymentProgress.cancelled();
    notifyListeners();
  }

  /// Clear all payment state. Call before starting a brand-new flow.
  void reset() {
    _subscription?.cancel();
    _subscription = null;
    _activeProcessor = null;
    _activeRequest = null;
    _progress = null;
    _lastResult = null;
    _error = null;
    notifyListeners();
  }

  /// Legacy: record a completed traditional payment (cash) through the
  /// repository so it lands in the payment history.
  Future<bool> recordPayment(Payment payment) async {
    _setLoading(true);
    _error = null;

    final result = await processPayment(payment);
    bool ok = false;
    result.fold(
      (failure) => _error = _mapFailureToMessage(failure),
      (_) => ok = true,
    );

    _setLoading(false);
    return ok;
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure) {
      case ServerFailure _:
        return 'Server error: ${failure.message}';
      case NetworkFailure _:
        return 'Network error: ${failure.message}';
      case CacheFailure _:
        return 'Cache error: ${failure.message}';
      case ValidationFailure _:
        return 'Validation error: ${failure.message}';
      default:
        return 'An unexpected error occurred: ${failure.message}';
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
