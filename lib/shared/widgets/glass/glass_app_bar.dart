import 'dart:ui';

import 'package:flutter/material.dart';

import '../../utils/platform_utils.dart';

/// An [AppBar] that renders with a Liquid Glass-inspired blur on Apple
/// platforms and a standard Material 3 app bar elsewhere.
///
/// Drop-in replacement for [AppBar]. On iOS/macOS it uses a transparent
/// surface with a backdrop filter, so content scrolling underneath shows
/// through with a frosted blur. On other platforms the behaviour is identical
/// to [AppBar]. Extra parameters like [backgroundColor] are respected on
/// non-Apple platforms and ignored on Apple platforms, where the glass tint
/// is derived from the theme.
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GlassAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.centerTitle,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.elevation,
    this.surfaceTintColor,
    this.blurSigma = 24,
  });

  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool? centerTitle;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final double? elevation;
  final Color? surfaceTintColor;
  final double blurSigma;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (!PlatformUtils.isApple) {
      return AppBar(
        title: title,
        leading: leading,
        actions: actions,
        centerTitle: centerTitle,
        automaticallyImplyLeading: automaticallyImplyLeading,
        backgroundColor: backgroundColor ?? colorScheme.surface,
        elevation: elevation ?? 0,
        surfaceTintColor: surfaceTintColor ?? Colors.transparent,
      );
    }

    final isDark = theme.brightness == Brightness.dark;
    final tint = isDark
        ? colorScheme.surface.withValues(alpha: 0.55)
        : Colors.white.withValues(alpha: 0.6);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: AppBar(
          title: title,
          leading: leading,
          actions: actions,
          centerTitle: centerTitle,
          automaticallyImplyLeading: automaticallyImplyLeading,
          backgroundColor: tint,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          shape: Border(
            bottom: BorderSide(
              color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.2),
              width: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
