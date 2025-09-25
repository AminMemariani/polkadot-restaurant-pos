import 'package:flutter/foundation.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/payment.dart';
import '../../domain/usecases/get_payment_methods.dart';
import '../../domain/usecases/process_payment.dart';

class PaymentsProvider extends ChangeNotifier {
  final ProcessPayment processPayment;
  final GetPaymentMethods getPaymentMethods;

  PaymentsProvider({
    required this.processPayment,
    required this.getPaymentMethods,
  });

  List<String> _paymentMethods = [];
  bool _isLoading = false;
  String? _error;

  List<String> get paymentMethods => _paymentMethods;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPaymentMethods() async {
    _setLoading(true);
    _clearError();

    final result = await getPaymentMethods();
    result.fold(
      (failure) => _setError(_mapFailureToMessage(failure)),
      (methods) => _setPaymentMethods(methods),
    );

    _setLoading(false);
  }

  Future<bool> processPaymentTransaction(Payment payment) async {
    _setLoading(true);
    _clearError();

    final result = await processPayment(payment);
    bool success = false;

    result.fold(
      (failure) => _setError(_mapFailureToMessage(failure)),
      (_) => success = true,
    );

    _setLoading(false);
    return success;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void _setPaymentMethods(List<String> methods) {
    _paymentMethods = methods;
    notifyListeners();
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error: ${failure.message}';
      case NetworkFailure:
        return 'Network error: ${failure.message}';
      case CacheFailure:
        return 'Cache error: ${failure.message}';
      case ValidationFailure:
        return 'Validation error: ${failure.message}';
      default:
        return 'An unexpected error occurred: ${failure.message}';
    }
  }
}
