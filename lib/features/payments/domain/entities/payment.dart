import 'package:equatable/equatable.dart';

class Payment extends Equatable {
  final String id;
  final String receiptId;
  final double amount;
  final String method;
  final String status;
  final DateTime createdAt;

  const Payment({
    required this.id,
    required this.receiptId,
    required this.amount,
    required this.method,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, receiptId, amount, method, status, createdAt];
}
