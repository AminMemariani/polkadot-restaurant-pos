import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/custom_button.dart';
import '../providers/products_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/product_form_dialog.dart';
import '../widgets/product_search_bar.dart';

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

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Products',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          // View Toggle Button
          IconButton(
            icon: Icon(
              _isGridView ? Icons.view_list : Icons.grid_view,
              color: colorScheme.onSurface,
            ),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            tooltip: _isGridView ? 'List View' : 'Grid View',
          ),
          // Refresh Button
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: colorScheme.onSurface,
            ),
            onPressed: () => context.read<ProductsProvider>().loadProducts(),
            tooltip: 'Refresh',
          ),
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
                  suggestions: provider.getSearchSuggestions(provider.searchQuery),
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
                        CircularProgressIndicator(
                          color: colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading products...',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
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
                              Icons.error_outline,
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
                              color: colorScheme.onSurface.withOpacity(0.7),
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
                              Icons.inventory_2_outlined,
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
                              color: colorScheme.onSurface.withOpacity(0.7),
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
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductGridCard(
                        product: product,
                        onEdit: () => _showProductForm(context, product),
                        onDelete: () => _deleteProduct(context, product),
                      );
                    },
                  );
                } else {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ProductCard(
                          product: product,
                          onEdit: () => _showProductForm(context, product),
                          onDelete: () => _deleteProduct(context, product),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductForm(context, null),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
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
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await context
                  .read<ProductsProvider>()
                  .deleteExistingProduct(product.id);

              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
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
}
