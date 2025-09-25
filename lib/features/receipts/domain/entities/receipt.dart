import 'package:equatable/equatable.dart';

/// Receipt entity representing a sales transaction
class Receipt extends Equatable {
  final String id;
  final String customerName;
  final List<ReceiptItem> items;
  final double subtotal;
  final double tax;
  final double total;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Receipt({
    required this.id,
    required this.customerName,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    customerName,
    items,
    subtotal,
    tax,
    total,
    paymentMethod,
    status,
    createdAt,
    updatedAt,
  ];
}

/// Receipt item entity
class ReceiptItem extends Equatable {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final double total;

  const ReceiptItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.total,
  });

  @override
  List<Object?> get props => [productId, productName, price, quantity, total];
}
