import 'package:equatable/equatable.dart';

/// Receipt entity representing a sales transaction
class Receipt extends Equatable {
  final String id;
  final List<ReceiptItem> items;
  final double total;
  final double tax;
  final double serviceFee;
  final String? customerName;
  final double subtotal;
  final String? paymentMethod;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Receipt({
    required this.id,
    required this.items,
    required this.total,
    required this.tax,
    required this.serviceFee,
    this.customerName,
    required this.subtotal,
    this.paymentMethod,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a copy of this receipt with updated fields
  Receipt copyWith({
    String? id,
    List<ReceiptItem>? items,
    double? total,
    double? tax,
    double? serviceFee,
    String? customerName,
    double? subtotal,
    String? paymentMethod,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Receipt(
      id: id ?? this.id,
      items: items ?? this.items,
      total: total ?? this.total,
      tax: tax ?? this.tax,
      serviceFee: serviceFee ?? this.serviceFee,
      customerName: customerName ?? this.customerName,
      subtotal: subtotal ?? this.subtotal,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Create Receipt from JSON
  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      id: json['id'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => ReceiptItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      serviceFee: (json['serviceFee'] as num).toDouble(),
      customerName: json['customerName'] as String?,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] as String?,
      status: json['status'] as String? ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  /// Convert Receipt to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'tax': tax,
      'serviceFee': serviceFee,
      'customerName': customerName,
      'subtotal': subtotal,
      'paymentMethod': paymentMethod,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    items,
    total,
    tax,
    serviceFee,
    customerName,
    subtotal,
    paymentMethod,
    status,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'Receipt(id: $id, items: $items, total: $total, tax: $tax, serviceFee: $serviceFee, customerName: $customerName, subtotal: $subtotal, paymentMethod: $paymentMethod, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
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

  /// Create a copy of this receipt item with updated fields
  ReceiptItem copyWith({
    String? productId,
    String? productName,
    double? price,
    int? quantity,
    double? total,
  }) {
    return ReceiptItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      total: total ?? this.total,
    );
  }

  /// Create ReceiptItem from JSON
  factory ReceiptItem.fromJson(Map<String, dynamic> json) {
    return ReceiptItem(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      total: (json['total'] as num).toDouble(),
    );
  }

  /// Convert ReceiptItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'total': total,
    };
  }

  @override
  List<Object?> get props => [productId, productName, price, quantity, total];

  @override
  String toString() {
    return 'ReceiptItem(productId: $productId, productName: $productName, price: $price, quantity: $quantity, total: $total)';
  }
}
