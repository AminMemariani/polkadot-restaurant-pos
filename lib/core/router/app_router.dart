import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/products/presentation/pages/products_page.dart';
import '../../features/receipts/presentation/pages/active_receipt_page.dart';
import '../../features/payments/presentation/pages/payment_confirmation_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/analytics/presentation/pages/analytics_page.dart';
import '../../features/receipts/presentation/providers/receipts_provider.dart';
import '../../features/payments/presentation/providers/payments_provider.dart';

class AppRouter {
  static const String productsPath = '/';
  static const String receiptPath = '/receipt';
  static const String paymentPath = '/payment';
  static const String settingsPath = '/settings';
  static const String analyticsPath = '/analytics';

  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: productsPath,
      routes: [
        GoRoute(
          path: productsPath,
          name: 'products',
          builder: (context, state) => const ProductsPage(),
        ),
        GoRoute(
          path: receiptPath,
          name: 'receipt',
          builder: (context, state) => const ActiveReceiptPage(),
        ),
        GoRoute(
          path: paymentPath,
          name: 'payment',
          builder: (context, state) {
            final amount = state.uri.queryParameters['amount'];
            final network = state.uri.queryParameters['network'];
            final receipts = context.read<ReceiptsProvider>();
            context.read<PaymentsProvider>();

            final parsedAmount =
                double.tryParse(amount ?? '') ?? receipts.total;
            return PaymentConfirmationPage(
              amount: parsedAmount,
              network: network,
            );
          },
        ),
        GoRoute(
          path: settingsPath,
          name: 'settings',
          builder: (context, state) => const SettingsPage(),
        ),
        GoRoute(
          path: analyticsPath,
          name: 'analytics',
          builder: (context, state) => const AnalyticsPage(),
        ),
      ],
      debugLogDiagnostics: false,
    );
  }
}
