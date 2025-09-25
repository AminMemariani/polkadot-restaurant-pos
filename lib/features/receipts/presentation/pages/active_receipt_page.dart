import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/receipts_provider.dart';
import '../widgets/swipe_to_delete_item.dart';
import '../widgets/receipt_summary_card.dart';

class ActiveReceiptPage extends StatefulWidget {
  const ActiveReceiptPage({super.key});

  @override
  State<ActiveReceiptPage> createState() => _ActiveReceiptPageState();
}

class _ActiveReceiptPageState extends State<ActiveReceiptPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Current Order',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          // Settings Button for Tax/Fee Rates
          IconButton(
            icon: Icon(
              Icons.settings,
              color: colorScheme.onSurface,
            ),
            onPressed: () => _showSettingsDialog(context),
            tooltip: 'Tax & Fee Settings',
          ),
        ],
      ),
      body: Consumer<ReceiptsProvider>(
        builder: (context, provider, child) {
          if (provider.error != null) {
            return _buildErrorState(context, provider);
          }

          return Column(
            children: [
              // Order Items List
              Expanded(
                child: provider.hasItems
                    ? _buildOrderItemsList(context, provider)
                    : _buildEmptyState(context),
              ),

              // Receipt Summary Card
              ReceiptSummaryCard(
                subtotal: provider.subtotal,
                tax: provider.tax,
                serviceFee: provider.serviceFee,
                total: provider.total,
                taxRate: provider.taxRate,
                serviceFeeRate: provider.serviceFeeRate,
                hasItems: provider.hasItems,
                isLoading: provider.isLoading,
                onCheckout: () => _handleCheckout(context, provider),
                onClear: () => _handleClearOrder(context, provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderItemsList(BuildContext context, ReceiptsProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: provider.currentOrderItems.length,
      itemBuilder: (context, index) {
        final item = provider.currentOrderItems[index];
        return SwipeToDeleteItem(
          item: item,
          onDelete: () => provider.removeProductFromOrder(item.productId),
          trailing: _buildQuantityControls(context, provider, item),
        );
      },
    );
  }

  Widget _buildQuantityControls(
    BuildContext context,
    ReceiptsProvider provider,
    item,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              provider.updateProductQuantity(
                item.productId,
                item.quantity - 1,
              );
            },
            icon: Icon(
              Icons.remove,
              size: 16,
              color: colorScheme.primary,
            ),
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            padding: EdgeInsets.zero,
          ),
          Text(
            '${item.quantity}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
          ),
          IconButton(
            onPressed: () {
              provider.updateProductQuantity(
                item.productId,
                item.quantity + 1,
              );
            },
            icon: Icon(
              Icons.add,
              size: 16,
              color: colorScheme.primary,
            ),
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 60,
                color: colorScheme.primary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Items in Order',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start by adding products to create an order',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to products page
                // This would be handled by the parent navigation
              },
              icon: Icon(
                Icons.add_shopping_cart,
                color: colorScheme.onPrimary,
              ),
              label: Text(
                'Add Products',
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ReceiptsProvider provider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Error Loading Order',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.error!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => provider.loadReceipts(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCheckout(BuildContext context, ReceiptsProvider provider) async {
    final success = await provider.createReceiptFromCurrentOrder();
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Order completed successfully!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to complete order'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _handleClearOrder(BuildContext context, ReceiptsProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Order'),
        content: const Text('Are you sure you want to clear all items from the current order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      provider.clearCurrentOrder();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order cleared')),
        );
      }
    }
  }

  Future<void> _showSettingsDialog(BuildContext context) async {
    final provider = context.read<ReceiptsProvider>();
    final taxController = TextEditingController(
      text: (provider.taxRate * 100).toStringAsFixed(1),
    );
    final serviceFeeController = TextEditingController(
      text: (provider.serviceFeeRate * 100).toStringAsFixed(1),
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tax & Fee Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: taxController,
              decoration: const InputDecoration(
                labelText: 'Tax Rate (%)',
                suffixText: '%',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: serviceFeeController,
              decoration: const InputDecoration(
                labelText: 'Service Fee Rate (%)',
                suffixText: '%',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final taxRate = double.tryParse(taxController.text) ?? 0.0;
              final serviceFeeRate = double.tryParse(serviceFeeController.text) ?? 0.0;
              
              provider.setTaxRate(taxRate / 100);
              provider.setServiceFeeRate(serviceFeeRate / 100);
              
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
