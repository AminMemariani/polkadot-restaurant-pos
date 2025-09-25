import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/product.dart';

/// Abstract repository for products
abstract class ProductsRepository {
  /// Get all products
  Future<Either<Failure, List<Product>>> getProducts();

  /// Get product by ID
  Future<Either<Failure, Product>> getProductById(String id);

  /// Get products by category
  Future<Either<Failure, List<Product>>> getProductsByCategory(String category);

  /// Add a new product
  Future<Either<Failure, Product>> addProduct(Product product);

  /// Update an existing product
  Future<Either<Failure, Product>> updateProduct(Product product);

  /// Delete a product
  Future<Either<Failure, void>> deleteProduct(String id);

  /// Search products by name
  Future<Either<Failure, List<Product>>> searchProducts(String query);
}
