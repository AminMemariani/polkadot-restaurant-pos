import '../../domain/entities/receipt.dart';

class ReceiptModel extends Receipt {
  const ReceiptModel({
    required super.id,
    required super.customerName,
    required super.items,
    required super.subtotal,
    required super.tax,
    required super.total,
    required super.paymentMethod,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ReceiptModel.fromJson(Map<String, dynamic> json) {
    // Implementation placeholder
    throw UnimplementedError();
  }

  Map<String, dynamic> toJson() {
    // Implementation placeholder
    throw UnimplementedError();
  }

  factory ReceiptModel.fromEntity(Receipt receipt) {
    return ReceiptModel(
      id: receipt.id,
      customerName: receipt.customerName,
      items: receipt.items,
      subtotal: receipt.subtotal,
      tax: receipt.tax,
      total: receipt.total,
      paymentMethod: receipt.paymentMethod,
      status: receipt.status,
      createdAt: receipt.createdAt,
      updatedAt: receipt.updatedAt,
    );
  }

  Receipt toEntity() {
    return Receipt(
      id: id,
      customerName: customerName,
      items: items,
      subtotal: subtotal,
      tax: tax,
      total: total,
      paymentMethod: paymentMethod,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
