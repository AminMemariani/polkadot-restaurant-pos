import 'package:flutter/foundation.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/usecases/create_receipt.dart';
import '../../domain/usecases/get_receipts.dart';
import '../../domain/usecases/update_receipt.dart';
import '../../../products/domain/entities/product.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

/// Provider for managing receipts state and current order
class ReceiptsProvider extends ChangeNotifier {
  final GetReceipts getReceipts;
  final CreateReceipt createReceipt;
  final UpdateReceipt updateReceipt;
  final SettingsProvider? settingsProvider;

  ReceiptsProvider({
    required this.getReceipts,
    required this.createReceipt,
    required this.updateReceipt,
    this.settingsProvider,
  });

  List<Receipt> _receipts = [];
  List<ReceiptItem> _currentOrderItems = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Receipt> get receipts => _receipts;
  List<ReceiptItem> get currentOrderItems => _currentOrderItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get taxRate => settingsProvider?.taxRate ?? 0.08;
  double get serviceFeeRate => settingsProvider?.serviceFeeRate ?? 0.05;

  // Calculated values
  double get subtotal {
    return _currentOrderItems.fold(0.0, (sum, item) => sum + item.total);
  }

  double get tax {
    return subtotal * taxRate;
  }

  double get serviceFee {
    return subtotal * serviceFeeRate;
  }

  double get total {
    return subtotal + tax + serviceFee;
  }

  bool get hasItems => _currentOrderItems.isNotEmpty;

  /// Add a product to the current order
  void addProductToOrder(Product product, {int quantity = 1}) {
    final existingItemIndex = _currentOrderItems.indexWhere(
      (item) => item.productId == product.id,
    );

    if (existingItemIndex != -1) {
      // Update existing item quantity
      final existingItem = _currentOrderItems[existingItemIndex];
      final newQuantity = existingItem.quantity + quantity;
      final newTotal = product.price * newQuantity;

      _currentOrderItems[existingItemIndex] = existingItem.copyWith(
        quantity: newQuantity,
        total: newTotal,
      );
    } else {
      // Add new item
      final newItem = ReceiptItem(
        productId: product.id,
        productName: product.name,
        price: product.price,
        quantity: quantity,
        total: product.price * quantity,
      );
      _currentOrderItems.add(newItem);
    }

    notifyListeners();
  }

  /// Remove a product from the current order
  void removeProductFromOrder(String productId) {
    _currentOrderItems.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  /// Update quantity of a product in the current order
  void updateProductQuantity(String productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeProductFromOrder(productId);
      return;
    }

    final itemIndex = _currentOrderItems.indexWhere(
      (item) => item.productId == productId,
    );

    if (itemIndex != -1) {
      final item = _currentOrderItems[itemIndex];
      final newTotal = item.price * newQuantity;

      _currentOrderItems[itemIndex] = item.copyWith(
        quantity: newQuantity,
        total: newTotal,
      );
      notifyListeners();
    }
  }

  /// Clear the current order
  void clearCurrentOrder() {
    _currentOrderItems.clear();
    notifyListeners();
  }

  /// Create receipt from current order
  Future<bool> createReceiptFromCurrentOrder() async {
    if (_currentOrderItems.isEmpty) return false;

    _setLoading(true);
    _clearError();

    final receipt = Receipt(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: List.from(_currentOrderItems),
      total: total,
      tax: tax,
      serviceFee: serviceFee,
    );

    final result = await createReceipt(receipt);
    bool success = false;

    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (
      createdReceipt,
    ) {
      _receipts.add(createdReceipt);
      clearCurrentOrder(); // Clear order after successful creation
      notifyListeners();
      success = true;
    });

    _setLoading(false);
    return success;
  }

  /// Load all receipts
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

  /// Create a new receipt
  Future<bool> createNewReceipt(Receipt receipt) async {
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

  /// Update an existing receipt
  Future<bool> updateExistingReceipt(Receipt receipt) async {
    _setLoading(true);
    _clearError();

    final result = await updateReceipt(receipt);
    bool success = false;

    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (
      updatedReceipt,
    ) {
      final index = _receipts.indexWhere((r) => r.id == updatedReceipt.id);
      if (index != -1) {
        _receipts[index] = updatedReceipt;
        notifyListeners();
      }
      success = true;
    });

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
