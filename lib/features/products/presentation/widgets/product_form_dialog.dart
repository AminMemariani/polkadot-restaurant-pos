import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/services/product_image_service.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/glass/glass.dart';
import '../../../../shared/widgets/image_picker_field.dart';
import '../../domain/entities/product.dart';
import '../providers/products_provider.dart';
import 'package:restaurant_pos_app/shared/utils/app_icons.dart';

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
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();

  bool _isLoading = false;
  String? _imageUrl;
  String? _originalImageUrl;
  final _imageService = ProductImageService();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _idController.text = widget.product!.id;
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price.toString();
      _descriptionController.text = widget.product!.description;
      _categoryController.text = widget.product!.category;
      _imageUrl = widget.product!.imageUrl;
      _originalImageUrl = widget.product!.imageUrl;
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
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEditing = widget.product != null;

    return GlassDialog(
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ImagePickerField(
                  value: _imageUrl,
                  onChanged: (path) => setState(() => _imageUrl = path),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _idController,
                  label: 'Product ID',
                  hint: 'Enter unique product ID',
                  prefixIcon: Icon(AppIcons.tag, color: colorScheme.primary),
                  enabled: !isEditing,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a product ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _nameController,
                  label: 'Product Name',
                  hint: 'Enter product name',
                  prefixIcon: Icon(
                    AppIcons.inventory2Outlined,
                    color: colorScheme.primary,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a product name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _priceController,
                  label: 'Price',
                  hint: '0.00',
                  prefixIcon: Icon(
                    AppIcons.attachMoney,
                    color: colorScheme.primary,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
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
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text('Cancel', style: TextStyle(color: colorScheme.onSurface)),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _saveProduct,
          child: _isLoading
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
      description: _descriptionController.text.trim(),
      category: _categoryController.text.trim(),
      imageUrl: _imageUrl,
      isAvailable: true,
      createdAt: widget.product?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final provider = context.read<ProductsProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final errorColor = Theme.of(context).colorScheme.error;
    final success = widget.product == null
        ? await provider.addNewProduct(product)
        : await provider.updateExistingProduct(product);

    if (success) {
      // Edit replaced the image — delete the old file.
      if (_originalImageUrl != null && _originalImageUrl != _imageUrl) {
        await _imageService.delete(_originalImageUrl);
      }
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            widget.product == null
                ? 'Product added successfully'
                : 'Product updated successfully',
          ),
          backgroundColor: primaryColor,
        ),
      );
    } else {
      // Surface the failure so the dialog isn't dead.
      messenger.showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Could not save product'),
          backgroundColor: errorColor,
        ),
      );
    }
  }
}
