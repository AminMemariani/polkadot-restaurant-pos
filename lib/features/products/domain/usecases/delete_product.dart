import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/products_repository.dart';

/// Use case for deleting a product
class DeleteProduct {
  final ProductsRepository repository;

  DeleteProduct(this.repository);

  Future<Either<Failure, void>> call(String productId) async {
    return await repository.deleteProduct(productId);
  }
}
