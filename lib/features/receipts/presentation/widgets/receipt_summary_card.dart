import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../payments/presentation/widgets/payment_method_dialog.dart';

class ReceiptSummaryCard extends StatefulWidget {
  final double subtotal;
  final double tax;
  final double serviceFee;
  final double total;
  final double taxRate;
  final double serviceFeeRate;
  final VoidCallback? onCheckout;
  final VoidCallback? onClear;
  final bool isLoading;
  final bool hasItems;

  const ReceiptSummaryCard({
    super.key,
    required this.subtotal,
    required this.tax,
    required this.serviceFee,
    required this.total,
    required this.taxRate,
    required this.serviceFeeRate,
    this.onCheckout,
    this.onClear,
    this.isLoading = false,
    this.hasItems = false,
  });

  @override
  State<ReceiptSummaryCard> createState() => _ReceiptSummaryCardState();
}

class _ReceiptSummaryCardState extends State<ReceiptSummaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: isTablet ? 24 : 16,
                vertical: 8,
              ),
              child: Material(
                elevation: 12,
                shadowColor: colorScheme.shadow.withOpacity(0.2),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.surface,
                        colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(isTablet ? 28 : 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    colorScheme.primary,
                                    colorScheme.primary.withOpacity(0.8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.receipt_long_rounded,
                                color: colorScheme.onPrimary,
                                size: isTablet ? 28 : 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Order Summary',
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: colorScheme.onSurface,
                                          letterSpacing: -0.5,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Review your order details',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Divider
                        Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                colorScheme.outline.withOpacity(0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Summary Rows
                        _buildSummaryRow(
                          context,
                          'Subtotal',
                          widget.subtotal,
                          isTablet: isTablet,
                        ),
                        const SizedBox(height: 12),
                        _buildSummaryRow(
                          context,
                          'Tax (${(widget.taxRate * 100).toStringAsFixed(0)}%)',
                          widget.tax,
                          isTablet: isTablet,
                        ),
                        const SizedBox(height: 12),
                        _buildSummaryRow(
                          context,
                          'Service Fee (${(widget.serviceFeeRate * 100).toStringAsFixed(0)}%)',
                          widget.serviceFee,
                          isTablet: isTablet,
                        ),

                        const SizedBox(height: 20),

                        // Total Divider
                        Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                colorScheme.primary.withOpacity(0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Total Row
                        _buildTotalRow(context, widget.total, isTablet),

                        const SizedBox(height: 24),

                        // Action Buttons
                        if (widget.hasItems)
                          _buildActionButtons(context, isTablet)
                        else
                          _buildEmptyState(context, isTablet),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    double value, {
    required bool isTablet,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final NumberFormat currencyFormat = NumberFormat.currency(symbol: '\$');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.8),
            fontWeight: FontWeight.w500,
            fontSize: isTablet ? 16 : 14,
          ),
        ),
        Text(
          currencyFormat.format(value),
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
            fontSize: isTablet ? 16 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRow(BuildContext context, double total, bool isTablet) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final NumberFormat currencyFormat = NumberFormat.currency(symbol: '\$');

    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withOpacity(0.3),
            colorScheme.primaryContainer.withOpacity(0.1),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
              fontSize: isTablet ? 24 : 20,
            ),
          ),
          Text(
            currencyFormat.format(total),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: colorScheme.primary,
              fontSize: isTablet ? 28 : 24,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isTablet) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        // Clear Order Button
        Expanded(
          flex: 1,
          child: Container(
            height: isTablet ? 56 : 48,
            child: OutlinedButton.icon(
              onPressed: widget.isLoading ? null : widget.onClear,
              icon: Icon(
                Icons.clear_all_rounded,
                size: isTablet ? 20 : 18,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              label: Text(
                'Clear',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface.withOpacity(0.7),
                  fontSize: isTablet ? 16 : 14,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: colorScheme.outline.withOpacity(0.5),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Checkout Button
        Expanded(
          flex: 2,
          child: Container(
            height: isTablet ? 56 : 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: widget.isLoading
                  ? null
                  : () => _showPaymentDialog(context),
              icon: widget.isLoading
                  ? SizedBox(
                      width: isTablet ? 20 : 16,
                      height: isTablet ? 20 : 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.payment_rounded,
                      size: isTablet ? 20 : 18,
                      color: colorScheme.onPrimary,
                    ),
              label: Text(
                widget.isLoading ? 'Processing...' : 'Checkout',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onPrimary,
                  fontSize: isTablet ? 16 : 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
                elevation: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isTablet) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: isTablet ? 32 : 24),
      child: Column(
        children: [
          Container(
            width: isTablet ? 80 : 64,
            height: isTablet ? 80 : 64,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(isTablet ? 40 : 32),
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              color: colorScheme.onSurface.withOpacity(0.4),
              size: isTablet ? 40 : 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No items in order',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
              fontSize: isTablet ? 18 : 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add products to start a new order',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.5),
              fontSize: isTablet ? 14 : 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => PaymentMethodDialog(amount: widget.total),
    );
  }
}
