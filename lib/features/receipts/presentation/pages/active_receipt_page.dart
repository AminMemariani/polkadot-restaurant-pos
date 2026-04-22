import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/receipts_provider.dart';
import '../widgets/swipe_to_delete_item.dart';
import '../widgets/receipt_summary_card.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/glass/glass.dart';
import '../../../../shared/widgets/states/app_states.dart';
import 'package:restaurant_pos_app/shared/utils/app_icons.dart';

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
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: Text(
          'Current Order',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () => context.go('/'),
            icon: Icon(AppIcons.homeRounded),
            tooltip: 'Home',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<ReceiptsProvider>(
        builder: (context, provider, child) {
          if (provider.error != null) {
            return _buildErrorState(context, provider);
          }

          return SingleChildScrollView(
            padding: EdgeInsets.only(top: AppSpacing.appBarOffset(context)),
            child: Column(
              children: [
                // Order Items List
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
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
                  onCheckout: () {
                    final amount = provider.total.toStringAsFixed(2);
                    context.go('/payment?amount=$amount');
                  },
                  onClear: () => _handleClearOrder(context, provider),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderItemsList(BuildContext context, ReceiptsProvider provider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: 8,
      ),
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
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              provider.updateProductQuantity(item.productId, item.quantity - 1);
            },
            icon: Icon(AppIcons.remove, size: 16, color: colorScheme.primary),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
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
              provider.updateProductQuantity(item.productId, item.quantity + 1);
            },
            icon: Icon(AppIcons.add, size: 16, color: colorScheme.primary),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return AppEmptyState(
      icon: AppIcons.receiptLongOutlined,
      title: 'No Items in Order',
      message: 'Start by adding products to create an order',
      action: FilledButton.icon(
        onPressed: () => context.go('/'),
        icon: Icon(AppIcons.addShoppingCart),
        label: const Text('Add Products'),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ReceiptsProvider provider) {
    return AppErrorState(
      title: 'Error Loading Order',
      message: provider.error,
      onRetry: () => provider.loadReceipts(),
    );
  }

  Future<void> _handleClearOrder(
    BuildContext context,
    ReceiptsProvider provider,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => GlassDialog(
        title: const Text('Clear Order'),
        content: const Text(
          'Are you sure you want to clear all items from the current order?',
        ),
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
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('Order cleared')));
    }
  }
}
