import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/app_config.dart';
import '../../domain/entities/money.dart';
import '../../domain/entities/payment_request.dart';

/// HTTP client for the payments backend (`/payments/*`).
///
/// Kept narrow on purpose — no business logic, no caching, no error mapping
/// beyond what dio does. Higher layers (the processor) decide how to react
/// to failures.
class StripeRemoteDataSource {
  StripeRemoteDataSource({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConfig.paymentsBackendUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 30),
                headers: {'Content-Type': 'application/json'},
              ),
            ) {
    // Attach the current Supabase session JWT (if any) to every request.
    // Token refresh happens inside supabase_flutter; we just read what's
    // current per request so refreshed tokens are picked up automatically.
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (AppConfig.isSupabaseConfigured) {
            final token = Supabase.instance.client.auth.currentSession?.accessToken;
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;

  /// Create a PaymentIntent on the backend. [idempotencyKey] must be a fresh
  /// UUID per checkout attempt — the backend forwards it to Stripe so retries
  /// can't double-charge.
  Future<StripeIntent> createIntent(
    PaymentRequest request, {
    required String idempotencyKey,
  }) async {
    // Note: cashierId / locationId / tenantId are NOT sent — the backend
    // derives them from the verified JWT to prevent client spoofing.
    final response = await _dio.post<Map<String, dynamic>>(
      '/payments/intent',
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
      data: {
        'orderId': request.orderId,
        'amountMinor': request.amount.amountMinor,
        'currency': request.amount.currency.toLowerCase(),
        'tipMinor': request.tip?.amountMinor ?? 0,
        if (request.customerId != null) 'customerId': request.customerId,
        'metadata': request.metadata,
      },
    );
    final data = response.data!;
    return StripeIntent(
      id: data['id'] as String,
      clientSecret: data['clientSecret'] as String,
      status: data['status'] as String,
    );
  }

  /// Fetch the latest server-side state of a PaymentIntent. Use this to
  /// reconcile after the SDK callback returns — webhook is the source of
  /// truth, not the SDK return value.
  Future<StripeIntentStatus> getStatus(String intentId) async {
    final response = await _dio.get<Map<String, dynamic>>('/payments/$intentId');
    final data = response.data!;
    return StripeIntentStatus(
      id: data['id'] as String,
      status: data['status'] as String,
      amountMinor: data['amountMinor'] as int,
      currency: data['currency'] as String,
      tipMinor: (data['tipMinor'] as int?) ?? 0,
      failureCode: data['failureCode'] as String?,
      failureReason: data['failureReason'] as String?,
    );
  }

  /// Poll [getStatus] until it reaches a terminal state, with backoff.
  /// Throws [TimeoutException] after [timeout].
  Future<StripeIntentStatus> pollUntilTerminal(
    String intentId, {
    Duration interval = const Duration(seconds: 1),
    Duration timeout = const Duration(seconds: 60),
  }) async {
    final start = DateTime.now();
    while (DateTime.now().difference(start) < timeout) {
      final s = await getStatus(intentId);
      if (s.isTerminal) return s;
      await Future.delayed(interval);
    }
    throw TimeoutException('Polling for $intentId exceeded $timeout');
  }

  Future<RefundResponse> refund({
    required String paymentIntentId,
    Money? amount,
    String? reason,
    required String idempotencyKey,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/payments/refund',
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
      data: {
        'paymentIntentId': paymentIntentId,
        if (amount != null) 'amountMinor': amount.amountMinor,
        if (reason != null) 'reason': reason,
      },
    );
    final data = response.data!;
    return RefundResponse(
      id: data['id'] as String,
      status: data['status'] as String,
    );
  }
}

class StripeIntent {
  StripeIntent({
    required this.id,
    required this.clientSecret,
    required this.status,
  });
  final String id;
  final String clientSecret;
  final String status;
}

class StripeIntentStatus {
  StripeIntentStatus({
    required this.id,
    required this.status,
    required this.amountMinor,
    required this.currency,
    required this.tipMinor,
    this.failureCode,
    this.failureReason,
  });

  final String id;
  final String status;
  final int amountMinor;
  final String currency;
  final int tipMinor;
  final String? failureCode;
  final String? failureReason;

  bool get isTerminal =>
      status == 'succeeded' ||
      status == 'failed' ||
      status == 'cancelled' ||
      status == 'refunded' ||
      status == 'partial_refund';

  bool get succeeded => status == 'succeeded';
}

class RefundResponse {
  RefundResponse({required this.id, required this.status});
  final String id;
  final String status;
}

class TimeoutException implements Exception {
  TimeoutException(this.message);
  final String message;
  @override
  String toString() => 'TimeoutException: $message';
}
