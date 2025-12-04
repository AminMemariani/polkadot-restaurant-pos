import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/analytics_provider.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().loadAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Analytics',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Container(
          margin: const EdgeInsets.only(left: 8),
          child: Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => context.go('/'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: colorScheme.onPrimaryContainer,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        actions: [
          // Date Range Picker
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: _selectDateRange,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.date_range_rounded,
                    color: colorScheme.onSecondaryContainer,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          // Export Button
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: _exportAnalytics,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.download_rounded,
                    color: colorScheme.onTertiaryContainer,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<AnalyticsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return _buildErrorState(context, provider);
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(isTablet ? 32 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                _buildSummaryCards(context, provider, isTablet),

                const SizedBox(height: 32),

                // Daily Sales Chart
                _buildDailySalesChart(context, provider, isTablet),

                const SizedBox(height: 32),

                // Top Products
                _buildTopProducts(context, provider, isTablet),

                const SizedBox(height: 32),

                // Payment Methods Breakdown
                _buildPaymentMethodsBreakdown(context, provider, isTablet),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(
    BuildContext context,
    AnalyticsProvider provider,
    bool isTablet,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isTablet ? 4 : 2,
      crossAxisSpacing: isTablet ? 20 : 16,
      mainAxisSpacing: isTablet ? 20 : 16,
      childAspectRatio: isTablet ? 1.1 : 0.95,
      children: [
        _buildSummaryCard(
          context,
          title: 'Total Revenue',
          value:
              '\$${provider.summary?.totalRevenue.toStringAsFixed(2) ?? '0.00'}',
          icon: Icons.attach_money_rounded,
          color: colorScheme.primary,
          isTablet: isTablet,
        ),
        _buildSummaryCard(
          context,
          title: 'Total Transactions',
          value: '${provider.summary?.totalTransactions ?? 0}',
          icon: Icons.receipt_long_rounded,
          color: colorScheme.secondary,
          isTablet: isTablet,
        ),
        _buildSummaryCard(
          context,
          title: 'Average Order',
          value:
              '\$${provider.summary?.averageTransactionValue.toStringAsFixed(2) ?? '0.00'}',
          icon: Icons.shopping_cart_rounded,
          color: colorScheme.tertiary,
          isTablet: isTablet,
        ),
        _buildSummaryCard(
          context,
          title: 'Active Products',
          value: '${provider.summary?.activeProducts ?? 0}',
          icon: Icons.inventory_2_rounded,
          color: colorScheme.error,
          isTablet: isTablet,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isTablet,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 10 : 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: isTablet ? 24 : 20),
              ),
              const Spacer(),
              Icon(
                Icons.trending_up_rounded,
                color: colorScheme.onSurfaceVariant,
                size: isTablet ? 18 : 14,
              ),
            ],
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Flexible(
            child: Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: isTablet ? 15 : 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: isTablet ? 6 : 4),
          Flexible(
            child: Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
                fontSize: isTablet ? 22 : 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailySalesChart(
    BuildContext context,
    AnalyticsProvider provider,
    bool isTablet,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bar_chart_rounded,
                color: colorScheme.primary,
                size: isTablet ? 24 : 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Daily Sales Trend',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Mock chart area
          Container(
            height: isTablet ? 200 : 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.show_chart_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: isTablet ? 48 : 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chart visualization would go here',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProducts(
    BuildContext context,
    AnalyticsProvider provider,
    bool isTablet,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star_rounded,
                color: colorScheme.primary,
                size: isTablet ? 24 : 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Top Products',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Mock top products list
          ...List.generate(5, (index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(isTablet ? 16 : 12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: isTablet ? 40 : 32,
                    height: isTablet ? 40 : 32,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Product ${index + 1}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          '\$${(100 - index * 10).toStringAsFixed(2)} revenue',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${(20 - index * 2)} sold',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsBreakdown(
    BuildContext context,
    AnalyticsProvider provider,
    bool isTablet,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.payment_rounded,
                color: colorScheme.primary,
                size: isTablet ? 24 : 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Payment Methods',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Mock payment methods breakdown
          ...['Cash', 'Card', 'Blockchain'].map((method) {
            final percentage = method == 'Cash'
                ? 45.0
                : method == 'Card'
                ? 35.0
                : 20.0;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        method,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.primary,
                    ),
                    minHeight: isTablet ? 8 : 6,
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, AnalyticsProvider provider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, color: colorScheme.error, size: 80),
          const SizedBox(height: 24),
          Text(
            'Error loading analytics',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            provider.error ?? 'An unknown error occurred.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => provider.loadAnalytics(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              textStyle: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange:
          _selectedDateRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 7)),
            end: DateTime.now(),
          ),
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
      // Load analytics for selected date range
      context.read<AnalyticsProvider>().loadAnalyticsForDateRange(
        picked.start,
        picked.end,
      );
    }
  }

  Future<void> _exportAnalytics() async {
    final provider = context.read<AnalyticsProvider>();
    final startDate =
        _selectedDateRange?.start ??
        DateTime.now().subtract(const Duration(days: 7));
    final endDate = _selectedDateRange?.end ?? DateTime.now();

    try {
      await provider.exportAnalytics(startDate, endDate);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Analytics exported successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
