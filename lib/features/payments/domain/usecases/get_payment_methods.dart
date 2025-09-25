import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/payments_repository.dart';

class GetPaymentMethods {
  final PaymentsRepository repository;

  GetPaymentMethods(this.repository);

  Future<Either<Failure, List<String>>> call() async {
    return await repository.getPaymentMethods();
  }
}
