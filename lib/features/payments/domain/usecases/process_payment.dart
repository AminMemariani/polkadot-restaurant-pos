import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/payment.dart';
import '../repositories/payments_repository.dart';

class ProcessPayment {
  final PaymentsRepository repository;

  ProcessPayment(this.repository);

  Future<Either<Failure, Payment>> call(Payment payment) async {
    return await repository.processPayment(payment);
  }
}
