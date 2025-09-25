import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/product.dart';
import '../repositories/products_repository.dart';

/// Use case for adding a new product
class AddProduct {
  final ProductsRepository repository;

  AddProduct(this.repository);

  Future<Either<Failure, Product>> call(Product product) async {
    return await repository.addProduct(product);
  }
}
