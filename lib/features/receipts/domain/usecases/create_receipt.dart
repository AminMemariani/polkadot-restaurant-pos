import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/receipt.dart';
import '../repositories/receipts_repository.dart';

class CreateReceipt {
  final ReceiptsRepository repository;

  CreateReceipt(this.repository);

  Future<Either<Failure, Receipt>> call(Receipt receipt) async {
    return await repository.createReceipt(receipt);
  }
}
