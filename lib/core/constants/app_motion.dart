import 'package:flutter/animation.dart';

/// Animation duration and curve tokens.
///
/// Three speeds cover the common cases: [fast] for press feedback, [medium]
/// for state transitions, [slow] for entrance/exit. Curves are picked to feel
/// at home on both Material 3 and Apple platforms.
class AppMotion {
  AppMotion._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration pulse = Duration(milliseconds: 2000);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutQuint;
  static const Curve press = Curves.easeInOut;
  static const Curve pop = Curves.elasticOut;

  /// Scale factor used for press-down feedback on tappable surfaces.
  static const double pressScale = 0.96;
}
