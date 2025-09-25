// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:restaurant_pos_app/main.dart';
import 'package:restaurant_pos_app/shared/services/theme_service.dart';

void main() {
  testWidgets('Restaurant POS app smoke test', (WidgetTester tester) async {
    // Create a mock theme service
    final themeService = ThemeService();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider<ThemeService>(
        create: (_) => themeService,
        child: const RestaurantPosApp(themeService: null),
      ),
    );

    // Verify that the app title is displayed.
    expect(find.text('Restaurant POS System'), findsOneWidget);
    expect(find.text('Welcome to your modern POS application'), findsOneWidget);
  });
}
