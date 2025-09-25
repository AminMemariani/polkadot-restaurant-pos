import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/payment.dart';

abstract class PaymentsRepository {
  Future<Either<Failure, Payment>> processPayment(Payment payment);
  Future<Either<Failure, List<String>>> getPaymentMethods();
}
