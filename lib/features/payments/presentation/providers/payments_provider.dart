import 'dart:math';
import 'package:flutter/foundation.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/payment.dart';
import '../../domain/usecases/process_payment.dart';
import '../../domain/usecases/get_payment_methods.dart';

/// Provider for managing payments state and blockchain integration
class PaymentsProvider extends ChangeNotifier {
  final ProcessPayment processPayment;
  final GetPaymentMethods getPaymentMethods;

  PaymentsProvider({
    required this.processPayment,
    required this.getPaymentMethods,
  });

  List<Payment> _payments = [];
  List<String> _paymentMethods = [];
  bool _isLoading = false;
  String? _error;

  // Current payment state
  Payment? _currentPayment;
  PaymentStatus _paymentStatus = PaymentStatus.idle;
  String? _paymentId;
  String? _blockchainTxId;
  double _paymentAmount = 0.0;

  // Getters
  List<Payment> get payments => _payments;
  List<String> get paymentMethods => _paymentMethods;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Payment? get currentPayment => _currentPayment;
  PaymentStatus get paymentStatus => _paymentStatus;
  String? get paymentId => _paymentId;
  String? get blockchainTxId => _blockchainTxId;
  double get paymentAmount => _paymentAmount;

  /// Generate a unique payment ID
  String _generatePaymentId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999).toString().padLeft(4, '0');
    return 'PAY_${timestamp}_$random';
  }

  /// Generate a mock blockchain transaction ID
  String _generateBlockchainTxId() {
    final random = Random();
    final hexChars = '0123456789abcdef';
    final txId = List.generate(
      64,
      (index) => hexChars[random.nextInt(hexChars.length)],
    ).join();
    return '0x$txId';
  }

  /// Start a new payment process
  Future<String> startPayment(double amount) async {
    _setLoading(true);
    _clearError();

    _paymentId = _generatePaymentId();
    _paymentAmount = amount;
    _paymentStatus = PaymentStatus.waiting;
    _blockchainTxId = null;

    // Create payment entity
    _currentPayment = Payment(
      id: _paymentId!,
      status: 'pending',
      amount: amount,
    );

    notifyListeners();
    _setLoading(false);

    return _paymentId!;
  }

  /// Simulate blockchain payment confirmation
  Future<void> simulateBlockchainConfirmation() async {
    if (_paymentStatus != PaymentStatus.waiting) return;

    _setLoading(true);

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 3));

    // Generate blockchain transaction ID
    _blockchainTxId = _generateBlockchainTxId();

    // Update payment status
    _paymentStatus = PaymentStatus.confirmed;

    if (_currentPayment != null) {
      _currentPayment = _currentPayment!.copyWith(
        status: 'completed',
        blockchainTxId: _blockchainTxId,
      );

      // Add to payments list
      _payments.add(_currentPayment!);
    }

    notifyListeners();
    _setLoading(false);
  }

  /// Cancel current payment
  void cancelPayment() {
    _paymentStatus = PaymentStatus.cancelled;
    _currentPayment = null;
    _paymentId = null;
    _blockchainTxId = null;
    _paymentAmount = 0.0;
    notifyListeners();
  }

  /// Reset payment state
  void resetPayment() {
    _paymentStatus = PaymentStatus.idle;
    _currentPayment = null;
    _paymentId = null;
    _blockchainTxId = null;
    _paymentAmount = 0.0;
    _clearError();
    notifyListeners();
  }

  /// Get payment methods (mock implementation)
  Future<List<String>> getAvailablePaymentMethods() async {
    _setLoading(true);
    _clearError();

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    final methods = ['Polkadot (DOT)', 'Kusama (KSM)', 'Credit Card', 'Cash'];

    _setPaymentMethods(methods);
    _setLoading(false);
    return methods;
  }

  /// Process payment with blockchain integration
  Future<bool> processPaymentWithBlockchain({
    required double amount,
    required String network,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Start payment process
      await startPayment(amount);

      // Simulate blockchain processing
      await _simulateBlockchainProcessing(network);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Payment processing failed: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Simulate blockchain processing
  Future<void> _simulateBlockchainProcessing(String network) async {
    // Simulate network delay based on network
    final delay = network.toLowerCase().contains('polkadot')
        ? const Duration(seconds: 5)
        : const Duration(seconds: 3);

    await Future.delayed(delay);

    // Generate transaction ID
    _blockchainTxId = _generateBlockchainTxId();

    // Update status
    _paymentStatus = PaymentStatus.confirmed;

    if (_currentPayment != null) {
      _currentPayment = _currentPayment!.copyWith(
        status: 'completed',
        blockchainTxId: _blockchainTxId,
      );

      _payments.add(_currentPayment!);
    }

    notifyListeners();
  }

  /// Load payment methods
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

  /// Process a new payment
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

  // Private methods
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

/// Payment status enum
enum PaymentStatus { idle, waiting, confirmed, cancelled, failed }
