import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'core/config/app_config.dart';
import 'core/constants/app_theme.dart';
import 'core/di/providers.dart';
import 'core/router/app_router.dart';
import 'core/l10n/app_localizations.dart';
import 'shared/services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Stripe SDK init. Skipped silently when no key is provisioned so the app
  // still boots — Stripe processors will report unavailable in that state.
  if (AppConfig.isStripeConfigured) {
    Stripe.publishableKey = AppConfig.stripePublishableKey;
    Stripe.merchantIdentifier = AppConfig.stripeMerchantIdentifier;
    try {
      await Stripe.instance.applySettings();
    } catch (e, st) {
      // Apple Pay / Google Pay setup can fail on platforms that don't
      // support them; swallow so the app still launches. Real errors will
      // surface on the first PaymentSheet call.
      if (kDebugMode) debugPrint('Stripe.applySettings failed: $e\n$st');
    }
  }

  // Initialize dependency injection
  await AppProviders.initialize();

  // Initialize theme service
  final themeService = ThemeService();
  await themeService.initialize();

  runApp(RestaurantPosApp(themeService: themeService));
}

class RestaurantPosApp extends StatelessWidget {
  final ThemeService? themeService;

  const RestaurantPosApp({super.key, this.themeService});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.createRouter();
    return MultiProvider(
      providers: AppProviders.providers,
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp.router(
            title: 'Restaurant POS',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeService.themeMode,
            routerConfig: router,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''), // English
              Locale('es', ''), // Spanish
              Locale('fr', ''), // French
            ],
          );
        },
      ),
    );
  }
}
