import 'package:flutter/foundation.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/usecases/create_receipt.dart';
import '../../domain/usecases/get_receipts.dart';
import '../../domain/usecases/update_receipt.dart';

class ReceiptsProvider extends ChangeNotifier {
  final GetReceipts getReceipts;
  final CreateReceipt createReceipt;
  final UpdateReceipt updateReceipt;

  ReceiptsProvider({
    required this.getReceipts,
    required this.createReceipt,
    required this.updateReceipt,
  });

  List<Receipt> _receipts = [];
  bool _isLoading = false;
  String? _error;

  List<Receipt> get receipts => _receipts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadReceipts() async {
    _setLoading(true);
    _clearError();

    final result = await getReceipts();
    result.fold(
      (failure) => _setError(_mapFailureToMessage(failure)),
      (receipts) => _setReceipts(receipts),
    );

    _setLoading(false);
  }

  Future<bool> addReceipt(Receipt receipt) async {
    _setLoading(true);
    _clearError();

    final result = await createReceipt(receipt);
    bool success = false;

    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (
      createdReceipt,
    ) {
      _receipts.add(createdReceipt);
      notifyListeners();
      success = true;
    });

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

  void _setReceipts(List<Receipt> receipts) {
    _receipts = receipts;
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
