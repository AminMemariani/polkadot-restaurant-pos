import '../../../../core/storage/storage_service.dart';
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
  final StorageService storageService;

  ReceiptsLocalDataSourceImpl(this.storageService);

  @override
  Future<List<ReceiptModel>> getReceipts() async {
    final receiptsData = await storageService.loadReceipts();
    return receiptsData.map((json) => ReceiptModel.fromJson(json)).toList();
  }

  @override
  Future<ReceiptModel?> getReceiptById(String id) async {
    final receipts = await getReceipts();
    try {
      return receipts.firstWhere((receipt) => receipt.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<ReceiptModel> createReceipt(ReceiptModel receipt) async {
    final receipts = await getReceipts();
    receipts.add(receipt);
    await cacheReceipts(receipts);
    return receipt;
  }

  @override
  Future<ReceiptModel> updateReceipt(ReceiptModel receipt) async {
    final receipts = await getReceipts();
    final index = receipts.indexWhere((r) => r.id == receipt.id);
    if (index != -1) {
      receipts[index] = receipt;
      await cacheReceipts(receipts);
    }
    return receipt;
  }

  @override
  Future<void> deleteReceipt(String id) async {
    final receipts = await getReceipts();
    receipts.removeWhere((receipt) => receipt.id == id);
    await cacheReceipts(receipts);
  }

  @override
  Future<void> cacheReceipts(List<ReceiptModel> receipts) async {
    final receiptsData = receipts.map((receipt) => receipt.toJson()).toList();
    await storageService.saveReceipts(receiptsData);
  }
}
