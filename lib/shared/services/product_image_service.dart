import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Handles picking and persisting product images to the app documents
/// directory.
///
/// Returned paths are absolute filesystem paths. On web the returned string
/// is an `XFile.path` which is a blob URL — consumers should handle both via
/// [Image.file] or [Image.network].
class ProductImageService {
  ProductImageService({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  static const String _subdir = 'product_images';

  /// Pick an image from the gallery. Returns the persisted absolute path or
  /// `null` if the user cancelled.
  Future<String?> pickFromGallery() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (file == null) return null;
    return _persist(file);
  }

  /// Take a photo with the camera. Returns the persisted absolute path or
  /// `null` if the user cancelled.
  Future<String?> takePhoto() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (file == null) return null;
    return _persist(file);
  }

  /// Delete a persisted product image. No-op if the file doesn't exist or
  /// is outside our managed directory (e.g. an http URL).
  Future<void> delete(String? path) async {
    if (path == null || path.isEmpty) return;
    if (kIsWeb) return;
    if (path.startsWith('http')) return;
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Copy the picked file into the app documents directory so it survives
  /// past the temporary cache.
  Future<String> _persist(XFile picked) async {
    if (kIsWeb) {
      // On web the XFile path is an opaque blob URL; return it directly.
      return picked.path;
    }
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, _subdir));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final ext = p.extension(picked.path).isEmpty
        ? '.jpg'
        : p.extension(picked.path);
    final filename = 'prod_${DateTime.now().microsecondsSinceEpoch}$ext';
    final target = File(p.join(dir.path, filename));
    await target.writeAsBytes(await picked.readAsBytes());
    return target.path;
  }
}
