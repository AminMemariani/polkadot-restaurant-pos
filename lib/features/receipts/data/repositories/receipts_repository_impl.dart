import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/repositories/receipts_repository.dart';
import '../datasources/receipts_local_datasource.dart';
import '../datasources/receipts_remote_datasource.dart';

class ReceiptsRepositoryImpl implements ReceiptsRepository {
  final ReceiptsRemoteDataSource remoteDataSource;
  final ReceiptsLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ReceiptsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Receipt>>> getReceipts() async {
    // Implementation placeholder
    return const Right([]);
  }

  @override
  Future<Either<Failure, Receipt>> getReceiptById(String id) async {
    // Implementation placeholder
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Receipt>> createReceipt(Receipt receipt) async {
    // Implementation placeholder
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Receipt>> updateReceipt(Receipt receipt) async {
    // Implementation placeholder
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> deleteReceipt(String id) async {
    // Implementation placeholder
    throw UnimplementedError();
  }
}
