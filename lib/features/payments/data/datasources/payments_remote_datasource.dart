import '../../../../core/network/api_client.dart';
import '../models/payment_model.dart';

abstract class PaymentsRemoteDataSource {
  Future<PaymentModel> processPayment(PaymentModel payment);
  Future<List<String>> getPaymentMethods();
}

class PaymentsRemoteDataSourceImpl implements PaymentsRemoteDataSource {
  final ApiClient apiClient;

  PaymentsRemoteDataSourceImpl(this.apiClient);

  @override
  Future<PaymentModel> processPayment(PaymentModel payment) async {
    throw UnimplementedError();
  }

  @override
  Future<List<String>> getPaymentMethods() async {
    throw UnimplementedError();
  }
}
