import '../../domain/entities/receipt.dart';

class ReceiptModel extends Receipt {
  const ReceiptModel({
    required super.id,
    required super.items,
    required super.total,
    required super.tax,
    required super.serviceFee,
    super.customerName,
    required super.subtotal,
    super.paymentMethod,
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
      items: receipt.items,
      total: receipt.total,
      tax: receipt.tax,
      serviceFee: receipt.serviceFee,
      customerName: receipt.customerName,
      subtotal: receipt.subtotal,
      paymentMethod: receipt.paymentMethod,
      status: receipt.status,
      createdAt: receipt.createdAt,
      updatedAt: receipt.updatedAt,
    );
  }

  Receipt toEntity() {
    return Receipt(
      id: id,
      items: items,
      total: total,
      tax: tax,
      serviceFee: serviceFee,
      customerName: customerName,
      subtotal: subtotal,
      paymentMethod: paymentMethod,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
