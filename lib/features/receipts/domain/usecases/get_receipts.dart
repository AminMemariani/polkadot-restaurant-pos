import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/receipt.dart';
import '../repositories/receipts_repository.dart';

class GetReceipts {
  final ReceiptsRepository repository;

  GetReceipts(this.repository);

  Future<Either<Failure, List<Receipt>>> call() async {
    return await repository.getReceipts();
  }
}
