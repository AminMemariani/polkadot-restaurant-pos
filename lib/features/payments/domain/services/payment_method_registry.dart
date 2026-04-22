import '../entities/payment_method.dart';
import 'payment_processor.dart';

/// Holds every [PaymentProcessor] the app knows about.
///
/// Wired up once in DI; the payment method dialog enumerates from here so
/// adding a new rail (Stripe, Apple Pay, gift card) is a single registration
/// — no UI changes required.
class PaymentMethodRegistry {
  final Map<PaymentMethod, PaymentProcessor> _processors = {};

  void register(PaymentProcessor processor) {
    _processors[processor.method] = processor;
  }

  /// All registered processors in insertion order.
  Iterable<PaymentProcessor> all() => _processors.values;

  /// Processors whose [PaymentProcessor.isAvailable] returns true. Use this
  /// to drive the cashier-facing picker so unavailable rails don't show.
  Future<List<PaymentProcessor>> available() async {
    final result = <PaymentProcessor>[];
    for (final p in _processors.values) {
      if (await p.isAvailable()) result.add(p);
    }
    return result;
  }

  PaymentProcessor get(PaymentMethod method) {
    final p = _processors[method];
    if (p == null) {
      throw StateError('No processor registered for $method');
    }
    return p;
  }
}
