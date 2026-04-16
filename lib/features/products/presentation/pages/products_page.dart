import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/glass/glass.dart';
import '../providers/products_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/product_form_dialog.dart';
import '../widgets/product_search_bar.dart';
import '../../../receipts/presentation/providers/receipts_provider.dart';
import 'package:restaurant_pos_app/shared/utils/app_icons.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsProvider>().loadProducts();
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
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: Text(
          'Products',
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
            onPressed: () => context.go('/receipt'),
            icon: Icon(AppIcons.receiptLongRounded),
            tooltip: 'Current order',
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            icon: Icon(
              _isGridView ? AppIcons.viewListRounded : AppIcons.gridViewRounded,
            ),
            tooltip: _isGridView ? 'List view' : 'Grid view',
          ),
          IconButton(
            onPressed: () => context.read<ProductsProvider>().loadProducts(),
            icon: Icon(AppIcons.refreshRounded),
            tooltip: 'Refresh',
          ),
          IconButton(
            onPressed: () => context.go('/analytics'),
            icon: Icon(AppIcons.analyticsRounded),
            tooltip: 'Analytics',
          ),
          IconButton(
            onPressed: () => context.go('/settings'),
            icon: Icon(AppIcons.settingsRounded),
            tooltip: 'Settings',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Consumer<ProductsProvider>(
              builder: (context, provider, child) {
                return ProductSearchBar(
                  initialQuery: provider.searchQuery,
                  suggestions: provider.getSearchSuggestions(
                    provider.searchQuery,
                  ),
                  onSearchChanged: (query) => provider.searchProducts(query),
                  onSuggestionSelected: (product) {
                    provider.searchProducts(product.name);
                  },
                  onClear: () => provider.clearSearch(),
                );
              },
            ),
          ),

          // Products List/Grid
          Expanded(
            child: Consumer<ProductsProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: colorScheme.primary),
                        const SizedBox(height: 16),
                        Text(
                          'Loading products...',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.error != null) {
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
                              AppIcons.errorOutline,
                              size: 40,
                              color: colorScheme.onErrorContainer,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Error Loading Products',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.error!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          CustomButton(
                            text: 'Retry',
                            onPressed: () => provider.loadProducts(),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final products = provider.filteredProducts;

                if (products.isEmpty) {
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
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Icon(
                              AppIcons.inventory2Outlined,
                              size: 40,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            provider.searchQuery.isEmpty
                                ? 'No Products Found'
                                : 'No Products Match Your Search',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.searchQuery.isEmpty
                                ? 'Add your first product to get started'
                                : 'Try adjusting your search terms',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (provider.searchQuery.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => provider.clearSearch(),
                              child: Text(
                                'Clear Search',
                                style: TextStyle(color: colorScheme.primary),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }

                // Products List/Grid
                if (_isGridView) {
                  return GridView.builder(
                    padding: EdgeInsets.all(isTablet ? 24 : 16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isTablet ? 4 : 2,
                      childAspectRatio: isTablet ? 0.9 : 0.8,
                      crossAxisSpacing: isTablet ? 20 : 12,
                      mainAxisSpacing: isTablet ? 20 : 12,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductGridCard(
                        product: product,
                        onEdit: () => _showProductForm(context, product),
                        onDelete: () => _deleteProduct(context, product),
                        onAddToOrder: () =>
                            _addProductToOrder(context, product),
                      );
                    },
                  );
                } else {
                  return ListView.builder(
                    padding: EdgeInsets.all(isTablet ? 24 : 16),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ProductCard(
                          product: product,
                          onEdit: () => _showProductForm(context, product),
                          onDelete: () => _deleteProduct(context, product),
                          onAddToOrder: () =>
                              _addProductToOrder(context, product),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showProductForm(context, null),
          icon: Icon(AppIcons.addRounded),
          label: Text(
            'Add Product',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onPrimary,
            ),
          ),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  void _showProductForm(BuildContext context, product) {
    showDialog(
      context: context,
      builder: (context) => ProductFormDialog(product: product),
    );
  }

  void _deleteProduct(BuildContext context, product) {
    showDialog(
      context: context,
      builder: (context) => GlassDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final provider = context.read<ProductsProvider>();
              final messenger = ScaffoldMessenger.of(context);
              Navigator.of(context).pop();
              final success = await provider.deleteExistingProduct(product.id);

              if (success && mounted) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Product deleted successfully')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _addProductToOrder(BuildContext context, product) {
    try {
      context.read<ReceiptsProvider>().addProductToOrder(product);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} added to order'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'View',
              textColor: Theme.of(context).colorScheme.onPrimary,
              onPressed: () => context.go('/receipt'),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add product to order: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
