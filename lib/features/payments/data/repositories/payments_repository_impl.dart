import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/payments_repository.dart';
import '../datasources/payments_local_datasource.dart';
import '../datasources/payments_remote_datasource.dart';

class PaymentsRepositoryImpl implements PaymentsRepository {
  final PaymentsRemoteDataSource remoteDataSource;
  final PaymentsLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  PaymentsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Payment>> processPayment(Payment payment) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<String>>> getPaymentMethods() async {
    throw UnimplementedError();
  }
}
