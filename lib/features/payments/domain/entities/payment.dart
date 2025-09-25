import 'package:equatable/equatable.dart';

/// Payment entity representing a payment transaction
class Payment extends Equatable {
  final String id;
  final String status;
  final double amount;
  final String? blockchainTxId;
  final String receiptId;
  final String method;
  final DateTime createdAt;

  const Payment({
    required this.id,
    required this.status,
    required this.amount,
    this.blockchainTxId,
    required this.receiptId,
    required this.method,
    required this.createdAt,
  });

  /// Create a copy of this payment with updated fields
  Payment copyWith({
    String? id,
    String? status,
    double? amount,
    String? blockchainTxId,
    String? receiptId,
    String? method,
    DateTime? createdAt,
    bool clearBlockchainTxId = false,
  }) {
    return Payment(
      id: id ?? this.id,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      blockchainTxId: clearBlockchainTxId
          ? null
          : (blockchainTxId ?? this.blockchainTxId),
      receiptId: receiptId ?? this.receiptId,
      method: method ?? this.method,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Create Payment from JSON
  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      status: json['status'] as String,
      amount: (json['amount'] as num).toDouble(),
      blockchainTxId: json['blockchainTxId'] as String?,
      receiptId: json['receiptId'] as String? ?? '',
      method: json['method'] as String? ?? 'blockchain',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  /// Convert Payment to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'amount': amount,
      'receiptId': receiptId,
      'method': method,
      'createdAt': createdAt.toIso8601String(),
      if (blockchainTxId != null) 'blockchainTxId': blockchainTxId,
    };
  }

  @override
  List<Object?> get props => [
    id,
    status,
    amount,
    blockchainTxId,
    receiptId,
    method,
    createdAt,
  ];

  @override
  String toString() {
    return 'Payment(id: $id, status: $status, amount: $amount, blockchainTxId: $blockchainTxId, receiptId: $receiptId, method: $method, createdAt: $createdAt)';
  }
}
