import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_theme.dart';
import 'core/di/providers.dart';
import 'shared/services/theme_service.dart';
import 'features/products/presentation/pages/products_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    return MultiProvider(
      providers: AppProviders.providers,
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            title: 'Restaurant POS',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeService.themeMode,
            home: const ProductsPage(),
          );
        },
      ),
    );
  }
}
