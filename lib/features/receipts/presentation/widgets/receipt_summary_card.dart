import 'package:flutter/material.dart';

class ReceiptSummaryCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Order Summary',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // Summary Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Subtotal
                _buildSummaryRow(
                  context,
                  'Subtotal',
                  subtotal,
                  isSubtotal: true,
                ),
                const SizedBox(height: 8),

                // Tax
                _buildSummaryRow(
                  context,
                  'Tax (${(taxRate * 100).toStringAsFixed(1)}%)',
                  tax,
                ),
                const SizedBox(height: 8),

                // Service Fee
                _buildSummaryRow(
                  context,
                  'Service Fee (${(serviceFeeRate * 100).toStringAsFixed(1)}%)',
                  serviceFee,
                ),
                const SizedBox(height: 12),

                // Divider
                Divider(
                  color: colorScheme.outline.withOpacity(0.3),
                  thickness: 1,
                ),
                const SizedBox(height: 12),

                // Total
                _buildSummaryRow(
                  context,
                  'Total',
                  total,
                  isTotal: true,
                ),
              ],
            ),
          ),

          // Action Buttons
          if (hasItems)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  // Clear Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isLoading ? null : onClear,
                      icon: Icon(
                        Icons.clear_all,
                        size: 18,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                      label: Text(
                        'Clear',
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: colorScheme.outline.withOpacity(0.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Checkout Button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : onCheckout,
                      icon: isLoading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  colorScheme.onPrimary,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.payment,
                              size: 18,
                              color: colorScheme.onPrimary,
                            ),
                      label: Text(
                        isLoading ? 'Processing...' : 'Checkout',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 32,
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No items in order',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add products to start an order',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.5),
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

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    double amount, {
    bool isSubtotal = false,
    bool isTotal = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
            color: isTotal
                ? colorScheme.onSurface
                : colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            color: isTotal ? colorScheme.primary : colorScheme.onSurface,
            fontSize: isTotal ? 16 : 14,
          ),
        ),
      ],
    );
  }
}
