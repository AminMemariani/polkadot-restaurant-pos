import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/product_image_service.dart';
import '../utils/platform_utils.dart';
import 'package:restaurant_pos_app/shared/utils/app_icons.dart';

/// A form field that previews a product image and lets the user pick one
/// from the gallery, capture a new photo, or clear the current selection.
///
/// [value] is the current image path/URL (may be `null`). [onChanged] fires
/// with the new path after a successful pick or with `null` after a clear.
class ImagePickerField extends StatefulWidget {
  const ImagePickerField({
    super.key,
    required this.value,
    required this.onChanged,
    this.height = 160,
  });

  final String? value;
  final ValueChanged<String?> onChanged;
  final double height;

  @override
  State<ImagePickerField> createState() => _ImagePickerFieldState();
}

class _ImagePickerFieldState extends State<ImagePickerField> {
  final _service = ProductImageService();
  bool _busy = false;

  bool get _hasImage => widget.value != null && widget.value!.isNotEmpty;

  Future<void> _pickGallery() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final path = await _service.pickFromGallery();
      if (path != null) widget.onChanged(path);
    } catch (e) {
      _showError('Could not pick image: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _takePhoto() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final path = await _service.takePhoto();
      if (path != null) widget.onChanged(path);
    } catch (e) {
      _showError('Could not capture photo: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _clear() {
    widget.onChanged(null);
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Camera capture is not supported on macOS/desktop or web.
    final canTakePhoto =
        PlatformUtils.isIOS ||
        (!kIsWeb && defaultTargetPlatform == TargetPlatform.android);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: _hasImage ? _buildPreview() : _buildPlaceholder(context),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _busy ? null : _pickGallery,
                icon: Icon(AppIcons.photoLibraryOutlined, size: 18),
                label: const Text('Gallery'),
              ),
            ),
            if (canTakePhoto) ...[
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _takePhoto,
                  icon: Icon(AppIcons.cameraAltOutlined, size: 18),
                  label: const Text('Camera'),
                ),
              ),
            ],
            if (_hasImage) ...[
              const SizedBox(width: 8),
              IconButton.outlined(
                tooltip: 'Remove image',
                onPressed: _busy ? null : _clear,
                icon: Icon(AppIcons.deleteOutline, color: colorScheme.error),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildPreview() {
    final value = widget.value!;
    if (kIsWeb || value.startsWith('http')) {
      return Image.network(
        value,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(context),
      );
    }
    return Image.file(
      File(value),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildPlaceholder(context),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppIcons.imageOutlined,
            size: 40,
            color: colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 8),
          Text(
            _busy ? 'Loading…' : 'No image selected',
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
