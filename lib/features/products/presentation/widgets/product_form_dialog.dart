import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/product.dart';
import '../providers/products_provider.dart';

class ProductFormDialog extends StatefulWidget {
  final Product? product;

  const ProductFormDialog({super.key, this.product});

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _idController.text = widget.product!.id;
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price.toString();
    } else {
      // Generate a unique ID for new products
      _idController.text = DateTime.now().millisecondsSinceEpoch.toString();
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEditing = widget.product != null;

    return AlertDialog(
      title: Text(
        isEditing ? 'Edit Product' : 'Add Product',
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Product ID Field
              TextFormField(
                controller: _idController,
                decoration: InputDecoration(
                  labelText: 'Product ID',
                  hintText: 'Enter unique product ID',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(
                    Icons.tag,
                    color: colorScheme.primary,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product ID';
                  }
                  return null;
                },
                enabled: !isEditing, // Don't allow editing ID for existing products
              ),
              const SizedBox(height: 16),
              
              // Product Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  hintText: 'Enter product name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(
                    Icons.inventory_2_outlined,
                    color: colorScheme.primary,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Price Field
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  hintText: '0.00',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(
                    Icons.attach_money,
                    color: colorScheme.primary,
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price < 0) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(color: colorScheme.onSurface),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveProduct,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                  ),
                )
              : Text(isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final product = Product(
      id: _idController.text.trim(),
      name: _nameController.text.trim(),
      price: double.parse(_priceController.text),
    );

    final provider = context.read<ProductsProvider>();
    final success = widget.product == null
        ? await provider.addNewProduct(product)
        : await provider.updateExistingProduct(product);

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.product == null
                ? 'Product added successfully'
                : 'Product updated successfully',
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }
}
