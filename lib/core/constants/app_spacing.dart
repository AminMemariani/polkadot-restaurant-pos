import 'package:flutter/material.dart';

/// Spacing and radius design tokens.
///
/// Use these instead of hardcoded numbers so padding, gaps, and corner radii
/// stay consistent as the app evolves. Values follow a 4px scale.
class AppSpacing {
  AppSpacing._();

  // Linear spacing scale (px).
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;

  // Common gaps as SizedBox helpers.
  static const SizedBox gapXs = SizedBox(width: xs, height: xs);
  static const SizedBox gapSm = SizedBox(width: sm, height: sm);
  static const SizedBox gapMd = SizedBox(width: md, height: md);
  static const SizedBox gapLg = SizedBox(width: lg, height: lg);
  static const SizedBox gapXl = SizedBox(width: xl, height: xl);
  static const SizedBox gapXxl = SizedBox(width: xxl, height: xxl);

  // Page-level padding presets.
  static const EdgeInsets pagePadding = EdgeInsets.all(lg);
  static const EdgeInsets pagePaddingTablet = EdgeInsets.all(xxl);
  static const EdgeInsets cardPadding = EdgeInsets.all(xl);
  static const EdgeInsets cardPaddingCompact = EdgeInsets.all(lg);

  /// Vertical offset that body content needs when the scaffold uses
  /// `extendBodyBehindAppBar: true` — equal to the status-bar inset plus the
  /// app-bar height. Use as `padding: EdgeInsets.only(top: appBarOffset(ctx))`.
  static double appBarOffset(BuildContext context) =>
      MediaQuery.of(context).padding.top + kToolbarHeight;
}

/// Corner radius tokens. Card-shaped surfaces in this app use [card];
/// dialogs and large surfaces use [xl].
class AppRadius {
  AppRadius._();

  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12;
  static const double card = 16;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;

  static BorderRadius all(double r) => BorderRadius.circular(r);
}
