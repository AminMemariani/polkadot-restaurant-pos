import 'dart:async';
import 'dart:math';

/// Abstract analytics service for tracking sales and business metrics
abstract class AnalyticsService {
  /// Initialize analytics service
  Future<void> initialize();

  /// Track a sale transaction
  Future<void> trackSale(SaleEvent saleEvent);

  /// Track product performance
  Future<void> trackProductPerformance(ProductPerformanceEvent event);

  /// Track payment method usage
  Future<void> trackPaymentMethod(PaymentMethodEvent event);

  /// Get daily sales report
  Future<DailySalesReport> getDailySalesReport(DateTime date);

  /// Get sales report for date range
  Future<SalesReport> getSalesReport(DateTime startDate, DateTime endDate);

  /// Get product performance analytics
  Future<ProductAnalytics> getProductAnalytics(
    DateTime startDate,
    DateTime endDate,
  );

  /// Get payment method analytics
  Future<PaymentAnalytics> getPaymentAnalytics(
    DateTime startDate,
    DateTime endDate,
  );

  /// Get revenue trends
  Future<RevenueTrends> getRevenueTrends(DateTime startDate, DateTime endDate);

  /// Export analytics data
  Future<String> exportAnalyticsData(
    DateTime startDate,
    DateTime endDate,
    ExportFormat format,
  );

  /// Clear analytics data
  Future<void> clearAnalyticsData();

  /// Get analytics summary
  Future<AnalyticsSummary> getAnalyticsSummary();
}

/// Sale event data
class SaleEvent {
  final String id;
  final DateTime timestamp;
  final double amount;
  final String currency;
  final String paymentMethod;
  final List<SaleItem> items;
  final double tax;
  final double serviceFee;
  final String? customerId;
  final String? receiptId;

  const SaleEvent({
    required this.id,
    required this.timestamp,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.items,
    required this.tax,
    required this.serviceFee,
    this.customerId,
    this.receiptId,
  });
}

/// Sale item data
class SaleItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final double total;

  const SaleItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.total,
  });
}

/// Product performance event
class ProductPerformanceEvent {
  final String productId;
  final String productName;
  final DateTime timestamp;
  final int quantitySold;
  final double revenue;
  final String action; // 'sold', 'viewed', 'added_to_cart'

  const ProductPerformanceEvent({
    required this.productId,
    required this.productName,
    required this.timestamp,
    required this.quantitySold,
    required this.revenue,
    required this.action,
  });
}

/// Payment method event
class PaymentMethodEvent {
  final String paymentMethod;
  final DateTime timestamp;
  final double amount;
  final bool success;
  final String? errorMessage;

  const PaymentMethodEvent({
    required this.paymentMethod,
    required this.timestamp,
    required this.amount,
    required this.success,
    this.errorMessage,
  });
}

/// Daily sales report
class DailySalesReport {
  final DateTime date;
  final double totalRevenue;
  final int totalTransactions;
  final double averageTransactionValue;
  final Map<String, double> revenueByHour;
  final Map<String, int> transactionsByHour;
  final List<TopProduct> topProducts;
  final PaymentMethodBreakdown paymentMethods;

  const DailySalesReport({
    required this.date,
    required this.totalRevenue,
    required this.totalTransactions,
    required this.averageTransactionValue,
    required this.revenueByHour,
    required this.transactionsByHour,
    required this.topProducts,
    required this.paymentMethods,
  });
}

/// Sales report for date range
class SalesReport {
  final DateTime startDate;
  final DateTime endDate;
  final double totalRevenue;
  final int totalTransactions;
  final double averageTransactionValue;
  final List<DailySalesReport> dailyReports;
  final RevenueTrends trends;
  final ProductAnalytics productAnalytics;
  final PaymentAnalytics paymentAnalytics;

  const SalesReport({
    required this.startDate,
    required this.endDate,
    required this.totalRevenue,
    required this.totalTransactions,
    required this.averageTransactionValue,
    required this.dailyReports,
    required this.trends,
    required this.productAnalytics,
    required this.paymentAnalytics,
  });
}

/// Product analytics
class ProductAnalytics {
  final List<TopProduct> topProducts;
  final List<LowPerformingProduct> lowPerformingProducts;
  final Map<String, double> revenueByProduct;
  final Map<String, int> quantitySoldByProduct;
  final double totalProductRevenue;

  const ProductAnalytics({
    required this.topProducts,
    required this.lowPerformingProducts,
    required this.revenueByProduct,
    required this.quantitySoldByProduct,
    required this.totalProductRevenue,
  });
}

/// Payment analytics
class PaymentAnalytics {
  final PaymentMethodBreakdown paymentMethods;
  final Map<String, double> successRateByMethod;
  final Map<String, double> averageAmountByMethod;
  final int totalFailedPayments;

  const PaymentAnalytics({
    required this.paymentMethods,
    required this.successRateByMethod,
    required this.averageAmountByMethod,
    required this.totalFailedPayments,
  });
}

/// Revenue trends
class RevenueTrends {
  final List<RevenueDataPoint> dailyRevenue;
  final List<RevenueDataPoint> hourlyRevenue;
  final double growthRate;
  final String trendDirection; // 'up', 'down', 'stable'

  const RevenueTrends({
    required this.dailyRevenue,
    required this.hourlyRevenue,
    required this.growthRate,
    required this.trendDirection,
  });
}

/// Revenue data point
class RevenueDataPoint {
  final DateTime timestamp;
  final double revenue;
  final int transactions;

  const RevenueDataPoint({
    required this.timestamp,
    required this.revenue,
    required this.transactions,
  });
}

/// Top product
class TopProduct {
  final String productId;
  final String productName;
  final double revenue;
  final int quantitySold;
  final double averagePrice;

  const TopProduct({
    required this.productId,
    required this.productName,
    required this.revenue,
    required this.quantitySold,
    required this.averagePrice,
  });
}

/// Low performing product
class LowPerformingProduct {
  final String productId;
  final String productName;
  final double revenue;
  final int quantitySold;
  final int daysSinceLastSale;

  const LowPerformingProduct({
    required this.productId,
    required this.productName,
    required this.revenue,
    required this.quantitySold,
    required this.daysSinceLastSale,
  });
}

/// Payment method breakdown
class PaymentMethodBreakdown {
  final Map<String, double> revenueByMethod;
  final Map<String, int> transactionsByMethod;
  final Map<String, double> percentageByMethod;

  const PaymentMethodBreakdown({
    required this.revenueByMethod,
    required this.transactionsByMethod,
    required this.percentageByMethod,
  });
}

/// Analytics summary
class AnalyticsSummary {
  final double totalRevenue;
  final int totalTransactions;
  final double averageTransactionValue;
  final int totalProducts;
  final int activeProducts;
  final String topPaymentMethod;
  final String topProduct;
  final DateTime lastUpdated;

  const AnalyticsSummary({
    required this.totalRevenue,
    required this.totalTransactions,
    required this.averageTransactionValue,
    required this.totalProducts,
    required this.activeProducts,
    required this.topPaymentMethod,
    required this.topProduct,
    required this.lastUpdated,
  });
}

/// Export format enum
enum ExportFormat { csv, json, pdf }

/// Mock implementation for development/testing
class MockAnalyticsService implements AnalyticsService {
  final List<SaleEvent> _sales = [];
  final List<ProductPerformanceEvent> _productEvents = [];
  final List<PaymentMethodEvent> _paymentEvents = [];

  @override
  Future<void> initialize() async {
    // Simulate initialization
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> trackSale(SaleEvent saleEvent) async {
    _sales.add(saleEvent);

    // Track product performance for each item
    for (final item in saleEvent.items) {
      await trackProductPerformance(
        ProductPerformanceEvent(
          productId: item.productId,
          productName: item.productName,
          timestamp: saleEvent.timestamp,
          quantitySold: item.quantity,
          revenue: item.total,
          action: 'sold',
        ),
      );
    }

    // Track payment method
    await trackPaymentMethod(
      PaymentMethodEvent(
        paymentMethod: saleEvent.paymentMethod,
        timestamp: saleEvent.timestamp,
        amount: saleEvent.amount,
        success: true,
      ),
    );
  }

  @override
  Future<void> trackProductPerformance(ProductPerformanceEvent event) async {
    _productEvents.add(event);
  }

  @override
  Future<void> trackPaymentMethod(PaymentMethodEvent event) async {
    _paymentEvents.add(event);
  }

  @override
  Future<DailySalesReport> getDailySalesReport(DateTime date) async {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final daySales = _sales
        .where(
          (sale) =>
              sale.timestamp.isAfter(dayStart) &&
              sale.timestamp.isBefore(dayEnd),
        )
        .toList();

    final totalRevenue = daySales.fold(0.0, (sum, sale) => sum + sale.amount);
    final totalTransactions = daySales.length;
    final averageTransactionValue = totalTransactions > 0
        ? totalRevenue / totalTransactions
        : 0.0;

    // Generate hourly breakdown
    final revenueByHour = <String, double>{};
    final transactionsByHour = <String, int>{};

    for (int hour = 0; hour < 24; hour++) {
      final hourKey = '${hour.toString().padLeft(2, '0')}:00';
      final hourStart = dayStart.add(Duration(hours: hour));
      final hourEnd = hourStart.add(const Duration(hours: 1));

      final hourSales = daySales
          .where(
            (sale) =>
                sale.timestamp.isAfter(hourStart) &&
                sale.timestamp.isBefore(hourEnd),
          )
          .toList();

      revenueByHour[hourKey] = hourSales.fold(
        0.0,
        (sum, sale) => sum + sale.amount,
      );
      transactionsByHour[hourKey] = hourSales.length;
    }

    // Generate top products
    final productRevenue = <String, double>{};
    final productQuantity = <String, int>{};

    for (final sale in daySales) {
      for (final item in sale.items) {
        productRevenue[item.productId] =
            (productRevenue[item.productId] ?? 0) + item.total;
        productQuantity[item.productId] =
            (productQuantity[item.productId] ?? 0) + item.quantity;
      }
    }

    final topProducts =
        productRevenue.entries
            .map(
              (entry) => TopProduct(
                productId: entry.key,
                productName: 'Product ${entry.key}',
                revenue: entry.value,
                quantitySold: productQuantity[entry.key] ?? 0,
                averagePrice: entry.value / (productQuantity[entry.key] ?? 1),
              ),
            )
            .toList()
          ..sort((a, b) => b.revenue.compareTo(a.revenue));

    // Generate payment method breakdown
    final paymentRevenue = <String, double>{};
    final paymentTransactions = <String, int>{};

    for (final sale in daySales) {
      paymentRevenue[sale.paymentMethod] =
          (paymentRevenue[sale.paymentMethod] ?? 0) + sale.amount;
      paymentTransactions[sale.paymentMethod] =
          (paymentTransactions[sale.paymentMethod] ?? 0) + 1;
    }

    final paymentMethods = PaymentMethodBreakdown(
      revenueByMethod: paymentRevenue,
      transactionsByMethod: paymentTransactions,
      percentageByMethod: paymentRevenue.map(
        (key, value) => MapEntry(
          key,
          totalRevenue > 0 ? (value / totalRevenue) * 100 : 0.0,
        ),
      ),
    );

    return DailySalesReport(
      date: date,
      totalRevenue: totalRevenue,
      totalTransactions: totalTransactions,
      averageTransactionValue: averageTransactionValue,
      revenueByHour: revenueByHour,
      transactionsByHour: transactionsByHour,
      topProducts: topProducts.take(5).toList(),
      paymentMethods: paymentMethods,
    );
  }

  @override
  Future<SalesReport> getSalesReport(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final rangeSales = _sales
        .where(
          (sale) =>
              sale.timestamp.isAfter(startDate) &&
              sale.timestamp.isBefore(endDate),
        )
        .toList();

    final totalRevenue = rangeSales.fold(0.0, (sum, sale) => sum + sale.amount);
    final totalTransactions = rangeSales.length;
    final averageTransactionValue = totalTransactions > 0
        ? totalRevenue / totalTransactions
        : 0.0;

    // Generate daily reports
    final dailyReports = <DailySalesReport>[];
    final currentDate = startDate;
    while (currentDate.isBefore(endDate)) {
      dailyReports.add(await getDailySalesReport(currentDate));
      currentDate.add(const Duration(days: 1));
    }

    // Generate trends
    final trends = await getRevenueTrends(startDate, endDate);

    // Generate analytics
    final productAnalytics = await getProductAnalytics(startDate, endDate);
    final paymentAnalytics = await getPaymentAnalytics(startDate, endDate);

    return SalesReport(
      startDate: startDate,
      endDate: endDate,
      totalRevenue: totalRevenue,
      totalTransactions: totalTransactions,
      averageTransactionValue: averageTransactionValue,
      dailyReports: dailyReports,
      trends: trends,
      productAnalytics: productAnalytics,
      paymentAnalytics: paymentAnalytics,
    );
  }

  @override
  Future<ProductAnalytics> getProductAnalytics(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final rangeEvents = _productEvents
        .where(
          (event) =>
              event.timestamp.isAfter(startDate) &&
              event.timestamp.isBefore(endDate),
        )
        .toList();

    final productRevenue = <String, double>{};
    final productQuantity = <String, int>{};

    for (final event in rangeEvents) {
      if (event.action == 'sold') {
        productRevenue[event.productId] =
            (productRevenue[event.productId] ?? 0) + event.revenue;
        productQuantity[event.productId] =
            (productQuantity[event.productId] ?? 0) + event.quantitySold;
      }
    }

    final topProducts =
        productRevenue.entries
            .map(
              (entry) => TopProduct(
                productId: entry.key,
                productName: entry.key,
                revenue: entry.value,
                quantitySold: productQuantity[entry.key] ?? 0,
                averagePrice: entry.value / (productQuantity[entry.key] ?? 1),
              ),
            )
            .toList()
          ..sort((a, b) => b.revenue.compareTo(a.revenue));

    final lowPerformingProducts = productRevenue.entries
        .where((entry) => entry.value < 100) // Less than $100 revenue
        .map(
          (entry) => LowPerformingProduct(
            productId: entry.key,
            productName: entry.key,
            revenue: entry.value,
            quantitySold: productQuantity[entry.key] ?? 0,
            daysSinceLastSale: Random().nextInt(30),
          ),
        )
        .toList();

    return ProductAnalytics(
      topProducts: topProducts,
      lowPerformingProducts: lowPerformingProducts,
      revenueByProduct: productRevenue,
      quantitySoldByProduct: productQuantity,
      totalProductRevenue: productRevenue.values.fold(
        0.0,
        (sum, revenue) => sum + revenue,
      ),
    );
  }

  @override
  Future<PaymentAnalytics> getPaymentAnalytics(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final rangeEvents = _paymentEvents
        .where(
          (event) =>
              event.timestamp.isAfter(startDate) &&
              event.timestamp.isBefore(endDate),
        )
        .toList();

    final paymentRevenue = <String, double>{};
    final paymentTransactions = <String, int>{};
    final paymentSuccess = <String, int>{};
    final paymentTotal = <String, int>{};

    for (final event in rangeEvents) {
      paymentRevenue[event.paymentMethod] =
          (paymentRevenue[event.paymentMethod] ?? 0) + event.amount;
      paymentTransactions[event.paymentMethod] =
          (paymentTransactions[event.paymentMethod] ?? 0) + 1;
      paymentTotal[event.paymentMethod] =
          (paymentTotal[event.paymentMethod] ?? 0) + 1;

      if (event.success) {
        paymentSuccess[event.paymentMethod] =
            (paymentSuccess[event.paymentMethod] ?? 0) + 1;
      }
    }

    final successRateByMethod = paymentTotal.map(
      (method, total) => MapEntry(
        method,
        total > 0 ? (paymentSuccess[method] ?? 0) / total * 100 : 0.0,
      ),
    );

    final averageAmountByMethod = paymentTransactions.map(
      (method, count) =>
          MapEntry(method, count > 0 ? paymentRevenue[method]! / count : 0.0),
    );

    final paymentMethods = PaymentMethodBreakdown(
      revenueByMethod: paymentRevenue,
      transactionsByMethod: paymentTransactions,
      percentageByMethod: paymentRevenue.map(
        (key, value) => MapEntry(
          key,
          paymentRevenue.values.fold(0.0, (sum, v) => sum + v) > 0
              ? (value / paymentRevenue.values.fold(0.0, (sum, v) => sum + v)) *
                    100
              : 0.0,
        ),
      ),
    );

    return PaymentAnalytics(
      paymentMethods: paymentMethods,
      successRateByMethod: successRateByMethod,
      averageAmountByMethod: averageAmountByMethod,
      totalFailedPayments: rangeEvents.where((e) => !e.success).length,
    );
  }

  @override
  Future<RevenueTrends> getRevenueTrends(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final rangeSales = _sales
        .where(
          (sale) =>
              sale.timestamp.isAfter(startDate) &&
              sale.timestamp.isBefore(endDate),
        )
        .toList();

    // Generate daily revenue data
    final dailyRevenue = <RevenueDataPoint>[];
    final currentDate = startDate;
    while (currentDate.isBefore(endDate)) {
      final dayEnd = currentDate.add(const Duration(days: 1));
      final daySales = rangeSales
          .where(
            (sale) =>
                sale.timestamp.isAfter(currentDate) &&
                sale.timestamp.isBefore(dayEnd),
          )
          .toList();

      dailyRevenue.add(
        RevenueDataPoint(
          timestamp: currentDate,
          revenue: daySales.fold(0.0, (sum, sale) => sum + sale.amount),
          transactions: daySales.length,
        ),
      );

      currentDate.add(const Duration(days: 1));
    }

    // Generate hourly revenue data for the last day
    final lastDay = endDate.subtract(const Duration(days: 1));
    final hourlyRevenue = <RevenueDataPoint>[];
    for (int hour = 0; hour < 24; hour++) {
      final hourStart = DateTime(
        lastDay.year,
        lastDay.month,
        lastDay.day,
        hour,
      );
      final hourEnd = hourStart.add(const Duration(hours: 1));

      final hourSales = rangeSales
          .where(
            (sale) =>
                sale.timestamp.isAfter(hourStart) &&
                sale.timestamp.isBefore(hourEnd),
          )
          .toList();

      hourlyRevenue.add(
        RevenueDataPoint(
          timestamp: hourStart,
          revenue: hourSales.fold(0.0, (sum, sale) => sum + sale.amount),
          transactions: hourSales.length,
        ),
      );
    }

    // Calculate growth rate
    final firstWeekRevenue = dailyRevenue
        .take(7)
        .fold(0.0, (sum, point) => sum + point.revenue);
    final lastWeekRevenue = dailyRevenue
        .skip(dailyRevenue.length - 7)
        .fold(0.0, (sum, point) => sum + point.revenue);
    final growthRate = firstWeekRevenue > 0
        ? ((lastWeekRevenue - firstWeekRevenue) / firstWeekRevenue) * 100
        : 0.0;

    return RevenueTrends(
      dailyRevenue: dailyRevenue,
      hourlyRevenue: hourlyRevenue,
      growthRate: growthRate,
      trendDirection: growthRate > 5
          ? 'up'
          : growthRate < -5
          ? 'down'
          : 'stable',
    );
  }

  @override
  Future<String> exportAnalyticsData(
    DateTime startDate,
    DateTime endDate,
    ExportFormat format,
  ) async {
    // Simulate export delay
    await Future.delayed(const Duration(seconds: 2));

    final report = await getSalesReport(startDate, endDate);

    switch (format) {
      case ExportFormat.csv:
        return _exportToCSV(report);
      case ExportFormat.json:
        return _exportToJSON(report);
      case ExportFormat.pdf:
        return _exportToPDF(report);
    }
  }

  @override
  Future<void> clearAnalyticsData() async {
    _sales.clear();
    _productEvents.clear();
    _paymentEvents.clear();
  }

  @override
  Future<AnalyticsSummary> getAnalyticsSummary() async {
    final totalRevenue = _sales.fold(0.0, (sum, sale) => sum + sale.amount);
    final totalTransactions = _sales.length;
    final averageTransactionValue = totalTransactions > 0
        ? totalRevenue / totalTransactions
        : 0.0;

    // Get unique products
    final productIds = _sales
        .expand((sale) => sale.items.map((item) => item.productId))
        .toSet();
    final activeProducts = _sales
        .where(
          (sale) => sale.timestamp.isAfter(
            DateTime.now().subtract(const Duration(days: 30)),
          ),
        )
        .expand((sale) => sale.items.map((item) => item.productId))
        .toSet();

    // Get top payment method
    final paymentCounts = <String, int>{};
    for (final sale in _sales) {
      paymentCounts[sale.paymentMethod] =
          (paymentCounts[sale.paymentMethod] ?? 0) + 1;
    }
    final topPaymentMethod = paymentCounts.isNotEmpty
        ? paymentCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : 'N/A';

    // Get top product
    final productRevenue = <String, double>{};
    for (final sale in _sales) {
      for (final item in sale.items) {
        productRevenue[item.productId] =
            (productRevenue[item.productId] ?? 0) + item.total;
      }
    }
    final topProduct = productRevenue.isNotEmpty
        ? productRevenue.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : 'N/A';

    return AnalyticsSummary(
      totalRevenue: totalRevenue,
      totalTransactions: totalTransactions,
      averageTransactionValue: averageTransactionValue,
      totalProducts: productIds.length,
      activeProducts: activeProducts.length,
      topPaymentMethod: topPaymentMethod,
      topProduct: topProduct,
      lastUpdated: DateTime.now(),
    );
  }

  String _exportToCSV(SalesReport report) {
    final buffer = StringBuffer();
    buffer.writeln('Date,Revenue,Transactions,Average Transaction Value');

    for (final dailyReport in report.dailyReports) {
      buffer.writeln(
        '${dailyReport.date.toIso8601String().split('T')[0]},'
        '${dailyReport.totalRevenue.toStringAsFixed(2)},'
        '${dailyReport.totalTransactions},'
        '${dailyReport.averageTransactionValue.toStringAsFixed(2)}',
      );
    }

    return buffer.toString();
  }

  String _exportToJSON(SalesReport report) {
    // Simple JSON export (in real implementation, use proper JSON serialization)
    return '''
    {
      "startDate": "${report.startDate.toIso8601String()}",
      "endDate": "${report.endDate.toIso8601String()}",
      "totalRevenue": ${report.totalRevenue},
      "totalTransactions": ${report.totalTransactions},
      "averageTransactionValue": ${report.averageTransactionValue}
    }
    ''';
  }

  String _exportToPDF(SalesReport report) {
    // Mock PDF export (in real implementation, use PDF generation library)
    return 'PDF export not implemented in mock service';
  }
}
