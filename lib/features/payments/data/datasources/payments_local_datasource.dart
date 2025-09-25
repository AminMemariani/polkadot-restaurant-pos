import 'package:shared_preferences/shared_preferences.dart';

import '../models/payment_model.dart';

abstract class PaymentsLocalDataSource {
  Future<PaymentModel> processPayment(PaymentModel payment);
  Future<List<String>> getPaymentMethods();
}

class PaymentsLocalDataSourceImpl implements PaymentsLocalDataSource {
  final SharedPreferences sharedPreferences;

  PaymentsLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<PaymentModel> processPayment(PaymentModel payment) async {
    throw UnimplementedError();
  }

  @override
  Future<List<String>> getPaymentMethods() async {
    throw UnimplementedError();
  }
}
