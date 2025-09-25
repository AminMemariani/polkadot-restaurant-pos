import 'package:flutter/foundation.dart';

import '../../../../core/analytics/analytics_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  final AnalyticsService analyticsService;

  AnalyticsProvider({required this.analyticsService});

  AnalyticsSummary? _summary;
  DailySalesReport? _dailyReport;
  SalesReport? _salesReport;
  bool _isLoading = false;
  String? _error;

  // Getters
  AnalyticsSummary? get summary => _summary;
  DailySalesReport? get dailyReport => _dailyReport;
  SalesReport? get salesReport => _salesReport;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load analytics summary
  Future<void> loadAnalytics() async {
    _setLoading(true);
    _clearError();

    try {
      _summary = await analyticsService.getAnalyticsSummary();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load analytics: $e');
    }

    _setLoading(false);
  }

  /// Load daily sales report
  Future<void> loadDailySalesReport(DateTime date) async {
    _setLoading(true);
    _clearError();

    try {
      _dailyReport = await analyticsService.getDailySalesReport(date);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load daily sales report: $e');
    }

    _setLoading(false);
  }

  /// Load sales report for date range
  Future<void> loadAnalyticsForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      _salesReport = await analyticsService.getSalesReport(startDate, endDate);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load sales report: $e');
    }

    _setLoading(false);
  }

  /// Track a sale event
  Future<void> trackSale(SaleEvent saleEvent) async {
    try {
      await analyticsService.trackSale(saleEvent);
      // Reload analytics after tracking
      await loadAnalytics();
    } catch (e) {
      _setError('Failed to track sale: $e');
    }
  }

  /// Track product performance
  Future<void> trackProductPerformance(ProductPerformanceEvent event) async {
    try {
      await analyticsService.trackProductPerformance(event);
    } catch (e) {
      _setError('Failed to track product performance: $e');
    }
  }

  /// Track payment method usage
  Future<void> trackPaymentMethod(PaymentMethodEvent event) async {
    try {
      await analyticsService.trackPaymentMethod(event);
    } catch (e) {
      _setError('Failed to track payment method: $e');
    }
  }

  /// Export analytics data
  Future<String> exportAnalytics(DateTime startDate, DateTime endDate) async {
    try {
      return await analyticsService.exportAnalyticsData(
        startDate,
        endDate,
        ExportFormat.csv,
      );
    } catch (e) {
      _setError('Failed to export analytics: $e');
      rethrow;
    }
  }

  /// Get product analytics
  Future<ProductAnalytics> getProductAnalytics(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await analyticsService.getProductAnalytics(startDate, endDate);
    } catch (e) {
      _setError('Failed to get product analytics: $e');
      rethrow;
    }
  }

  /// Get payment analytics
  Future<PaymentAnalytics> getPaymentAnalytics(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await analyticsService.getPaymentAnalytics(startDate, endDate);
    } catch (e) {
      _setError('Failed to get payment analytics: $e');
      rethrow;
    }
  }

  /// Get revenue trends
  Future<RevenueTrends> getRevenueTrends(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await analyticsService.getRevenueTrends(startDate, endDate);
    } catch (e) {
      _setError('Failed to get revenue trends: $e');
      rethrow;
    }
  }

  /// Clear analytics data
  Future<void> clearAnalyticsData() async {
    _setLoading(true);
    _clearError();

    try {
      await analyticsService.clearAnalyticsData();
      _summary = null;
      _dailyReport = null;
      _salesReport = null;
      notifyListeners();
    } catch (e) {
      _setError('Failed to clear analytics data: $e');
    }

    _setLoading(false);
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
