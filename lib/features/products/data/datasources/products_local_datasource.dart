import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product_model.dart';

/// Abstract local data source for products
abstract class ProductsLocalDataSource {
  Future<List<ProductModel>> getProducts();
  Future<ProductModel?> getProductById(String id);
  Future<List<ProductModel>> getProductsByCategory(String category);
  Future<ProductModel> addProduct(ProductModel product);
  Future<ProductModel> updateProduct(ProductModel product);
  Future<void> deleteProduct(String id);
  Future<List<ProductModel>> searchProducts(String query);
  Future<void> cacheProducts(List<ProductModel> products);
}

/// Implementation of local data source for products
class ProductsLocalDataSourceImpl implements ProductsLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _productsKey = 'cached_products';

  ProductsLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<List<ProductModel>> getProducts() async {
    final productsJson = sharedPreferences.getStringList(_productsKey) ?? [];
    return productsJson
        .map(
          (json) =>
              ProductModel.fromJson(jsonDecode(json) as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<ProductModel?> getProductById(String id) async {
    final products = await getProducts();
    try {
      return products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    final products = await getProducts();
    return products.where((product) => product.category == category).toList();
  }

  @override
  Future<ProductModel> addProduct(ProductModel product) async {
    final products = await getProducts();
    products.add(product);
    await cacheProducts(products);
    return product;
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    final products = await getProducts();
    final index = products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      products[index] = product;
      await cacheProducts(products);
    }
    return product;
  }

  @override
  Future<void> deleteProduct(String id) async {
    final products = await getProducts();
    products.removeWhere((product) => product.id == id);
    await cacheProducts(products);
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    final products = await getProducts();
    return products
        .where(
          (product) =>
              product.name.toLowerCase().contains(query.toLowerCase()) ||
              product.description.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    final productsJson = products
        .map((product) => jsonEncode(product.toJson()))
        .toList();
    await sharedPreferences.setStringList(_productsKey, productsJson);
  }
}
