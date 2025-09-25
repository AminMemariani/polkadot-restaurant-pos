import '../../domain/entities/payment.dart';

class PaymentModel extends Payment {
  const PaymentModel({
    required super.id,
    required super.receiptId,
    required super.amount,
    required super.method,
    required super.status,
    required super.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError();
  }

  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }

  factory PaymentModel.fromEntity(Payment payment) {
    return PaymentModel(
      id: payment.id,
      receiptId: payment.receiptId,
      amount: payment.amount,
      method: payment.method,
      status: payment.status,
      createdAt: payment.createdAt,
    );
  }

  Payment toEntity() {
    return Payment(
      id: id,
      receiptId: receiptId,
      amount: amount,
      method: method,
      status: status,
      createdAt: createdAt,
    );
  }
}
