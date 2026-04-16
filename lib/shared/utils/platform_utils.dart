import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Platform detection helpers.
///
/// Use these to branch between Apple-flavored (Liquid Glass-inspired) UI and
/// Material 3 on other platforms.
class PlatformUtils {
  PlatformUtils._();

  /// True when running on iOS or macOS (native app, not web).
  static bool get isApple {
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isMacOS;
  }

  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;
}
