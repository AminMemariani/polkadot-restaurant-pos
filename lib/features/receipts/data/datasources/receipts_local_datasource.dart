import 'package:shared_preferences/shared_preferences.dart';

import '../models/receipt_model.dart';

abstract class ReceiptsLocalDataSource {
  Future<List<ReceiptModel>> getReceipts();
  Future<ReceiptModel?> getReceiptById(String id);
  Future<ReceiptModel> createReceipt(ReceiptModel receipt);
  Future<ReceiptModel> updateReceipt(ReceiptModel receipt);
  Future<void> deleteReceipt(String id);
  Future<void> cacheReceipts(List<ReceiptModel> receipts);
}

class ReceiptsLocalDataSourceImpl implements ReceiptsLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _receiptsKey = 'cached_receipts';

  ReceiptsLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<List<ReceiptModel>> getReceipts() async {
    // Implementation placeholder
    return [];
  }

  @override
  Future<ReceiptModel?> getReceiptById(String id) async {
    // Implementation placeholder
    return null;
  }

  @override
  Future<ReceiptModel> createReceipt(ReceiptModel receipt) async {
    // Implementation placeholder
    return receipt;
  }

  @override
  Future<ReceiptModel> updateReceipt(ReceiptModel receipt) async {
    // Implementation placeholder
    return receipt;
  }

  @override
  Future<void> deleteReceipt(String id) async {
    // Implementation placeholder
  }

  @override
  Future<void> cacheReceipts(List<ReceiptModel> receipts) async {
    // Implementation placeholder
  }
}
