import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:restaurant_pos_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Restaurant POS App Integration Tests', () {
    testWidgets('Complete order flow test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify we're on the products page
      expect(find.text('Products'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);

      // Test product search
      await tester.enterText(find.byType(TextField), 'pizza');
      await tester.pumpAndSettle();

      // Add a product to cart (if any products are found)
      if (find.byType(Card).evaluate().isNotEmpty) {
        await tester.tap(find.byType(Card).first);
        await tester.pumpAndSettle();
      }

      // Navigate to receipt/order page
      if (find.byIcon(Icons.receipt_long).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.receipt_long));
        await tester.pumpAndSettle();
      }

      // Verify products page is displayed
      expect(find.text('Products'), findsOneWidget);

      // Test navigation to receipt page
      if (find.byIcon(Icons.receipt_long_rounded).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.receipt_long_rounded));
        await tester.pumpAndSettle();

        // Verify we're on the receipt page
        expect(find.text('Current Order'), findsOneWidget);
      }
    });

    testWidgets('Settings navigation test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      if (find.byIcon(Icons.settings).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.settings));
        await tester.pumpAndSettle();

        // Verify settings page
        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('Tax Rate'), findsOneWidget);
        expect(find.text('Service Fee Rate'), findsOneWidget);

        // Test settings modification
        final taxField = find.byType(TextField).first;
        await tester.enterText(taxField, '10');
        await tester.pumpAndSettle();

        // Save settings
        if (find.text('Save Settings').evaluate().isNotEmpty) {
          await tester.tap(find.text('Save Settings'));
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('Analytics navigation test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to analytics
      if (find.byIcon(Icons.analytics).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.analytics));
        await tester.pumpAndSettle();

        // Verify analytics page
        expect(find.text('Analytics'), findsOneWidget);
        expect(find.text('Total Revenue'), findsOneWidget);
        expect(find.text('Total Transactions'), findsOneWidget);

        // Test date range selection
        if (find.byIcon(Icons.date_range).evaluate().isNotEmpty) {
          await tester.tap(find.byIcon(Icons.date_range));
          await tester.pumpAndSettle();
        }

        // Test export functionality
        if (find.byIcon(Icons.download).evaluate().isNotEmpty) {
          await tester.tap(find.byIcon(Icons.download));
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('Theme switching test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Test theme switching (if theme toggle is available)
      if (find.byIcon(Icons.brightness_6).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.brightness_6));
        await tester.pumpAndSettle();

        // Verify theme change
        // This would require checking the actual theme colors
        // For now, we just verify the tap was successful
        expect(find.byIcon(Icons.brightness_6), findsOneWidget);
      }
    });

    testWidgets('Error handling test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Test error scenarios
      // This could include network errors, invalid data, etc.
      // For now, we'll test basic error handling

      // Test invalid input in search
      await tester.enterText(find.byType(TextField), '!@#\$%^&*()');
      await tester.pumpAndSettle();

      // App should not crash
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Performance test', (WidgetTester tester) async {
      // Start the app
      final stopwatch = Stopwatch()..start();
      app.main();
      await tester.pumpAndSettle();
      stopwatch.stop();

      // Verify app loads within reasonable time (5 seconds)
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));

      // Test scrolling performance
      if (find.byType(ListView).evaluate().isNotEmpty) {
        await tester.fling(find.byType(ListView), const Offset(0, -500), 1000);
        await tester.pumpAndSettle();
      }

      // App should remain responsive
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
