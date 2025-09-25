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
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  // Getters
  List<Product> get products => _products;
  List<Product> get filteredProducts => _filteredProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  /// Load all products
  Future<void> loadProducts() async {
    _setLoading(true);
    _clearError();

    final result = await getProducts();
    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (
      products,
    ) {
      _setProducts(products);
      _filteredProducts = products;
    });

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

  /// Search products by name or ID
  void searchProducts(String query) {
    _searchQuery = query.toLowerCase();

    if (_searchQuery.isEmpty) {
      _filteredProducts = _products;
    } else {
      _filteredProducts = _products.where((product) {
        return product.name.toLowerCase().contains(_searchQuery) ||
            product.id.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    notifyListeners();
  }

  /// Clear search and show all products
  void clearSearch() {
    _searchQuery = '';
    _filteredProducts = _products;
    notifyListeners();
  }

  /// Get search suggestions for autocomplete
  List<Product> getSearchSuggestions(String query) {
    if (query.isEmpty) return [];

    final lowercaseQuery = query.toLowerCase();
    return _products
        .where((product) {
          return product.name.toLowerCase().contains(lowercaseQuery) ||
              product.id.toLowerCase().contains(lowercaseQuery);
        })
        .take(5)
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
    _filteredProducts = products;
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
