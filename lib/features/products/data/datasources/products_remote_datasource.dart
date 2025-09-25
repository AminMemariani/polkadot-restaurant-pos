import '../../../../core/network/api_client.dart';
import '../models/product_model.dart';

/// Abstract remote data source for products
abstract class ProductsRemoteDataSource {
  Future<List<ProductModel>> getProducts();
  Future<ProductModel> getProductById(String id);
  Future<List<ProductModel>> getProductsByCategory(String category);
  Future<ProductModel> addProduct(ProductModel product);
  Future<ProductModel> updateProduct(ProductModel product);
  Future<void> deleteProduct(String id);
  Future<List<ProductModel>> searchProducts(String query);
}

/// Implementation of remote data source for products
class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  final ApiClient apiClient;

  ProductsRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<ProductModel>> getProducts() async {
    final response = await apiClient.get('/products');
    final List<dynamic> productsJson = response['data'] ?? [];
    return productsJson
        .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    final response = await apiClient.get('/products/$id');
    return ProductModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    final response = await apiClient.get('/products?category=$category');
    final List<dynamic> productsJson = response['data'] ?? [];
    return productsJson
        .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ProductModel> addProduct(ProductModel product) async {
    final response = await apiClient.post('/products', product.toJson());
    return ProductModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    final response = await apiClient.put(
      '/products/${product.id}',
      product.toJson(),
    );
    return ProductModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await apiClient.delete('/products/$id');
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    final response = await apiClient.get('/products/search?q=$query');
    final List<dynamic> productsJson = response['data'] ?? [];
    return productsJson
        .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
