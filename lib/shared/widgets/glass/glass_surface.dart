import 'dart:ui';

import 'package:flutter/material.dart';

import '../../utils/platform_utils.dart';

/// A translucent, blurred surface inspired by Apple's Liquid Glass design.
///
/// On iOS and macOS, renders as a backdrop-blurred container with a subtle
/// translucent tint and hairline border. On every other platform, falls back
/// to an opaque Material surface so Android, web, and desktop keep their
/// native Material 3 look.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.blurSigma = 24,
    this.tintOpacity = 0.6,
    this.borderOpacity = 0.2,
    this.elevation,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blurSigma;
  final double tintOpacity;
  final double borderOpacity;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final radius = BorderRadius.circular(borderRadius);

    if (!PlatformUtils.isApple) {
      return Container(
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: radius,
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: elevation != null
              ? [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.1),
                    blurRadius: elevation! * 2,
                    offset: Offset(0, elevation!),
                  ),
                ]
              : null,
        ),
        child: child,
      );
    }

    final isDark = theme.brightness == Brightness.dark;
    final tint = isDark
        ? colorScheme.surface.withValues(alpha: tintOpacity)
        : Colors.white.withValues(alpha: tintOpacity);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: elevation != null
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                  blurRadius: elevation! * 2.5,
                  offset: Offset(0, elevation!),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: radius,
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: isDark ? borderOpacity * 0.5 : borderOpacity,
                ),
                width: 0.5,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: isDark ? 0.04 : 0.12),
                  Colors.white.withValues(alpha: 0),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
