import '../../../../core/network/api_client.dart';
import '../models/receipt_model.dart';

abstract class ReceiptsRemoteDataSource {
  Future<List<ReceiptModel>> getReceipts();
  Future<ReceiptModel> getReceiptById(String id);
  Future<ReceiptModel> createReceipt(ReceiptModel receipt);
  Future<ReceiptModel> updateReceipt(ReceiptModel receipt);
  Future<void> deleteReceipt(String id);
}

class ReceiptsRemoteDataSourceImpl implements ReceiptsRemoteDataSource {
  final ApiClient apiClient;

  ReceiptsRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<ReceiptModel>> getReceipts() async {
    // Implementation placeholder
    return [];
  }

  @override
  Future<ReceiptModel> getReceiptById(String id) async {
    // Implementation placeholder
    throw UnimplementedError();
  }

  @override
  Future<ReceiptModel> createReceipt(ReceiptModel receipt) async {
    // Implementation placeholder
    throw UnimplementedError();
  }

  @override
  Future<ReceiptModel> updateReceipt(ReceiptModel receipt) async {
    // Implementation placeholder
    throw UnimplementedError();
  }

  @override
  Future<void> deleteReceipt(String id) async {
    // Implementation placeholder
    throw UnimplementedError();
  }
}
