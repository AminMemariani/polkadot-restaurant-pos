import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../features/products/presentation/providers/products_provider.dart';
import '../../features/receipts/presentation/providers/receipts_provider.dart';
import '../../features/payments/presentation/providers/payments_provider.dart';
import '../../features/settings/presentation/providers/settings_provider.dart';
import '../../shared/services/theme_service.dart';
import 'injection_container.dart';

/// List of all providers for the app
class AppProviders {
  static List<SingleChildWidget> get providers => [
    // Theme provider
    ChangeNotifierProvider<ThemeService>(create: (_) => ThemeService()),

    // Feature providers
    ChangeNotifierProvider<ProductsProvider>(
      create: (_) => sl<ProductsProvider>(),
    ),
    ChangeNotifierProvider<ReceiptsProvider>(
      create: (_) => sl<ReceiptsProvider>(),
    ),
    ChangeNotifierProvider<PaymentsProvider>(
      create: (_) => sl<PaymentsProvider>(),
    ),
    ChangeNotifierProvider<SettingsProvider>(
      create: (_) => sl<SettingsProvider>(),
    ),
  ];

  /// Initialize providers with dependency injection
  static Future<void> initialize() async {
    await init();
  }
}
