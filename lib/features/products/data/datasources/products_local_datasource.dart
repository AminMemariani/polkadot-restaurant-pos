import '../../../../core/storage/storage_service.dart';
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
  final StorageService storageService;

  ProductsLocalDataSourceImpl(this.storageService);

  @override
  Future<List<ProductModel>> getProducts() async {
    final productsData = await storageService.loadProducts();
    return productsData.map((json) => ProductModel.fromJson(json)).toList();
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
    return products
        .where((product) => product.name.contains(category))
        .toList();
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
              product.id.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    final productsData = products.map((product) => product.toJson()).toList();
    await storageService.saveProducts(productsData);
  }
}
