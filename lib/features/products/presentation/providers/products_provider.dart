import 'package:flutter/foundation.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/add_product.dart';
import '../../domain/usecases/delete_product.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/update_product.dart';

/// Provider for managing products state
class ProductsProvider extends ChangeNotifier {
  final GetProducts getProducts;
  final AddProduct addProduct;
  final UpdateProduct updateProduct;
  final DeleteProduct deleteProduct;

  ProductsProvider({
    required this.getProducts,
    required this.addProduct,
    required this.updateProduct,
    required this.deleteProduct,
  });

  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'All';

  // Getters
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;

  List<Product> get filteredProducts {
    if (_selectedCategory == 'All') {
      return _products;
    }
    return _products
        .where((product) => product.category == _selectedCategory)
        .toList();
  }

  List<String> get categories {
    final categories = _products
        .map((product) => product.category)
        .toSet()
        .toList();
    categories.insert(0, 'All');
    return categories;
  }

  /// Load all products
  Future<void> loadProducts() async {
    _setLoading(true);
    _clearError();

    final result = await getProducts();
    result.fold(
      (failure) => _setError(_mapFailureToMessage(failure)),
      (products) => _setProducts(products),
    );

    _setLoading(false);
  }

  /// Add a new product
  Future<bool> addNewProduct(Product product) async {
    _setLoading(true);
    _clearError();

    final result = await addProduct(product);
    bool success = false;

    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (
      addedProduct,
    ) {
      _products.add(addedProduct);
      notifyListeners();
      success = true;
    });

    _setLoading(false);
    return success;
  }

  /// Update an existing product
  Future<bool> updateExistingProduct(Product product) async {
    _setLoading(true);
    _clearError();

    final result = await updateProduct(product);
    bool success = false;

    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (
      updatedProduct,
    ) {
      final index = _products.indexWhere((p) => p.id == updatedProduct.id);
      if (index != -1) {
        _products[index] = updatedProduct;
        notifyListeners();
      }
      success = true;
    });

    _setLoading(false);
    return success;
  }

  /// Delete a product
  Future<bool> deleteExistingProduct(String productId) async {
    _setLoading(true);
    _clearError();

    final result = await deleteProduct(productId);
    bool success = false;

    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (_) {
      _products.removeWhere((product) => product.id == productId);
      notifyListeners();
      success = true;
    });

    _setLoading(false);
    return success;
  }

  /// Set selected category
  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Search products by name
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return filteredProducts;

    return filteredProducts
        .where(
          (product) =>
              product.name.toLowerCase().contains(query.toLowerCase()) ||
              product.description.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  /// Get product by ID
  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
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

  void _setProducts(List<Product> products) {
    _products = products;
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
