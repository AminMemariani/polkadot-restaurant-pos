import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:uuid/uuid.dart';

import '../../../../core/config/app_config.dart';
import '../../../../shared/utils/app_icons.dart';
import '../../domain/entities/money.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/payment_progress.dart';
import '../../domain/entities/payment_request.dart';
import '../../domain/entities/payment_result.dart';
import '../../domain/entities/refund_request.dart';
import '../../domain/services/payment_processor.dart';
import '../datasources/stripe_remote_datasource.dart';

/// Card-not-present payments via Stripe PaymentSheet (cards, Apple Pay,
/// Google Pay). Card-present (tap/chip) goes through Stripe Terminal — see
/// [StripeTerminalProcessor] (added in a later phase).
class StripeCardProcessor implements PaymentProcessor {
  StripeCardProcessor({required this.api, Uuid? uuid})
      : _uuid = uuid ?? const Uuid();

  final StripeRemoteDataSource api;
  final Uuid _uuid;

  @override
  PaymentMethod get method => PaymentMethod.stripeCard;

  @override
  String get displayName => 'Card';

  @override
  IconData get icon => AppIcons.creditCard;

  @override
  Future<bool> isAvailable() async => AppConfig.isStripeConfigured;

  @override
  Stream<PaymentProgress> process(PaymentRequest request) async* {
    yield const PaymentProgress.creating();

    final idempotencyKey = _uuid.v4();
    final StripeIntent intent;
    try {
      intent = await api.createIntent(request, idempotencyKey: idempotencyKey);
    } catch (e) {
      yield PaymentProgress.failed('Could not create payment: $e');
      return;
    }

    yield const PaymentProgress.awaitingUser(
      hint: 'Confirm payment in the sheet',
    );

    try {
      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          paymentIntentClientSecret: intent.clientSecret,
          merchantDisplayName: 'Restaurant POS',
          // Apple/Google Pay only fire when the merchant + entitlement is
          // configured; the SDK silently no-ops otherwise.
          applePay: const stripe.PaymentSheetApplePay(
            merchantCountryCode: 'US',
          ),
          googlePay: const stripe.PaymentSheetGooglePay(
            merchantCountryCode: 'US',
            testEnv: true,
          ),
        ),
      );
      await stripe.Stripe.instance.presentPaymentSheet();
    } on stripe.StripeException catch (e) {
      if (e.error.code == stripe.FailureCode.Canceled) {
        yield const PaymentProgress.cancelled();
        return;
      }
      yield PaymentProgress.failed(
        e.error.localizedMessage ?? e.error.message ?? 'Payment failed',
        code: e.error.code.name,
      );
      return;
    } catch (e) {
      yield PaymentProgress.failed('Payment failed: $e');
      return;
    }

    yield const PaymentProgress.processing(
      hint: 'Confirming with the network…',
    );

    // The SDK callback is best-effort — the webhook is the truth. Poll the
    // backend until it reflects a terminal state.
    try {
      final terminal = await api.pollUntilTerminal(intent.id);
      if (terminal.succeeded) {
        yield PaymentProgress.succeeded(
          PaymentResult(
            providerPaymentId: terminal.id,
            status: PaymentResultStatus.succeeded,
            method: PaymentMethod.stripeCard,
            amountCharged: Money(
              amountMinor: terminal.amountMinor,
              currency: terminal.currency.toUpperCase(),
            ),
            tipCaptured: terminal.tipMinor > 0
                ? Money(
                    amountMinor: terminal.tipMinor,
                    currency: terminal.currency.toUpperCase(),
                  )
                : null,
            completedAt: DateTime.now(),
          ),
        );
      } else {
        yield PaymentProgress.failed(
          terminal.failureReason ?? 'Payment did not succeed',
          code: terminal.failureCode,
        );
      }
    } catch (e) {
      yield PaymentProgress.failed('Reconciliation failed: $e');
    }
  }

  @override
  Future<RefundResult> refund(RefundRequest request) async {
    final idempotencyKey = _uuid.v4();
    final response = await api.refund(
      paymentIntentId: request.providerPaymentId,
      amount: request.amount,
      reason: request.reason,
      idempotencyKey: idempotencyKey,
    );
    return RefundResult(
      refundId: response.id,
      providerPaymentId: request.providerPaymentId,
      amount: request.amount ??
          const Money(amountMinor: 0, currency: 'USD'),
      completedAt: DateTime.now(),
    );
  }
}
