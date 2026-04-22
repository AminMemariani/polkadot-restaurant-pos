/// Stable identifier for a payment rail.
///
/// Strings are kept short and snake-cased so they can be persisted in the
/// `provider` column of the future transactions table without translation.
enum PaymentMethod {
  polkadot('polkadot'),
  kusama('kusama'),
  cash('cash'),
  stripeCard('stripe_card'),
  stripeTerminal('stripe_terminal');

  const PaymentMethod(this.id);

  final String id;

  static PaymentMethod fromId(String id) =>
      PaymentMethod.values.firstWhere((m) => m.id == id);
}
