import 'package:equatable/equatable.dart';

/// Payment entity representing a payment transaction
class Payment extends Equatable {
  final String id;
  final String status;
  final double amount;
  final String? blockchainTxId;

  const Payment({
    required this.id,
    required this.status,
    required this.amount,
    this.blockchainTxId,
  });

  /// Create a copy of this payment with updated fields
  Payment copyWith({
    String? id,
    String? status,
    double? amount,
    String? blockchainTxId,
    bool clearBlockchainTxId = false,
  }) {
    return Payment(
      id: id ?? this.id,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      blockchainTxId: clearBlockchainTxId ? null : (blockchainTxId ?? this.blockchainTxId),
    );
  }

  /// Create Payment from JSON
  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      status: json['status'] as String,
      amount: (json['amount'] as num).toDouble(),
      blockchainTxId: json['blockchainTxId'] as String?,
    );
  }

  /// Convert Payment to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'amount': amount,
      if (blockchainTxId != null) 'blockchainTxId': blockchainTxId,
    };
  }

  @override
  List<Object?> get props => [id, status, amount, blockchainTxId];

  @override
  String toString() {
    return 'Payment(id: $id, status: $status, amount: $amount, blockchainTxId: $blockchainTxId)';
  }
}
