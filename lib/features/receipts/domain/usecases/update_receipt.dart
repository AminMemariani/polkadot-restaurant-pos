import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/receipt.dart';
import '../repositories/receipts_repository.dart';

class UpdateReceipt {
  final ReceiptsRepository repository;

  UpdateReceipt(this.repository);

  Future<Either<Failure, Receipt>> call(Receipt receipt) async {
    return await repository.updateReceipt(receipt);
  }
}
