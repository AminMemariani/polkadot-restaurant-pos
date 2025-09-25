import 'package:flutter/material.dart';
import 'package:restaurant_pos_app/features/products/domain/entities/product.dart';

class ProductSearchBar extends StatefulWidget {
  final String initialQuery;
  final List<Product> suggestions;
  final Function(String) onSearchChanged;
  final Function(Product) onSuggestionSelected;
  final VoidCallback? onClear;

  const ProductSearchBar({
    super.key,
    this.initialQuery = '',
    required this.suggestions,
    required this.onSearchChanged,
    required this.onSuggestionSelected,
    this.onClear,
  });

  @override
  State<ProductSearchBar> createState() => _ProductSearchBarState();
}

class _ProductSearchBarState extends State<ProductSearchBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _focusNode = FocusNode();
    
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        // Delay hiding suggestions to allow for tap
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() {
              _showSuggestions = false;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _focusNode.hasFocus 
                  ? colorScheme.primary 
                  : colorScheme.outline.withOpacity(0.3),
              width: _focusNode.hasFocus ? 2 : 1,
            ),
            boxShadow: _focusNode.hasFocus
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: (value) {
              widget.onSearchChanged(value);
              setState(() {
                _showSuggestions = value.isNotEmpty && widget.suggestions.isNotEmpty;
              });
            },
            onTap: () {
              setState(() {
                _showSuggestions = _controller.text.isNotEmpty && widget.suggestions.isNotEmpty;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search products by name or ID...',
              hintStyle: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.6),
                fontSize: 16,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: _focusNode.hasFocus 
                    ? colorScheme.primary 
                    : colorScheme.onSurface.withOpacity(0.6),
                size: 24,
              ),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: colorScheme.onSurface.withOpacity(0.6),
                        size: 20,
                      ),
                      onPressed: () {
                        _controller.clear();
                        widget.onSearchChanged('');
                        widget.onClear?.call();
                        setState(() {
                          _showSuggestions = false;
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface,
            ),
          ),
        ),

        // Suggestions Dropdown
        if (_showSuggestions && widget.suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
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
              children: widget.suggestions.map((product) {
                return _SuggestionTile(
                  product: product,
                  onTap: () {
                    _controller.text = product.name;
                    widget.onSuggestionSelected(product);
                    setState(() {
                      _showSuggestions = false;
                    });
                    _focusNode.unfocus();
                  },
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _SuggestionTile({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Product Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: colorScheme.onPrimaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              
              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ID: ${product.id}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Price
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
