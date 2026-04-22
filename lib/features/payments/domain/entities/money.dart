import 'package:equatable/equatable.dart';

/// Money represented in minor currency units (cents) plus an ISO-4217 code.
///
/// Always pass amounts as `Money` rather than `double` so we never accumulate
/// floating-point drift in payment math. Use [fromMajor] to construct from
/// the user-facing decimal representation; use [toMajor] only for display.
class Money extends Equatable {
  const Money({required this.amountMinor, required this.currency});

  factory Money.fromMajor(double amount, String currency) =>
      Money(amountMinor: (amount * 100).round(), currency: currency);

  factory Money.zero(String currency) =>
      Money(amountMinor: 0, currency: currency);

  final int amountMinor;
  final String currency;

  double toMajor() => amountMinor / 100;

  Money operator +(Money other) {
    assert(currency == other.currency, 'currency mismatch');
    return Money(
      amountMinor: amountMinor + other.amountMinor,
      currency: currency,
    );
  }

  bool get isZero => amountMinor == 0;

  @override
  List<Object?> get props => [amountMinor, currency];

  @override
  String toString() => '$currency ${toMajor().toStringAsFixed(2)}';
}
