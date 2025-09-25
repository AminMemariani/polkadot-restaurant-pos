import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/receipt.dart';

/// Abstract repository for receipts
abstract class ReceiptsRepository {
  Future<Either<Failure, List<Receipt>>> getReceipts();
  Future<Either<Failure, Receipt>> getReceiptById(String id);
  Future<Either<Failure, Receipt>> createReceipt(Receipt receipt);
  Future<Either<Failure, Receipt>> updateReceipt(Receipt receipt);
  Future<Either<Failure, void>> deleteReceipt(String id);
}
