import 'package:flutter/material.dart';

import 'glass_surface.dart';

/// A Material [Card]-shaped container with Liquid Glass styling on Apple
/// platforms.
///
/// Thin wrapper over [GlassSurface] with card-appropriate defaults
/// (20px radius, elevation 4, inner padding).
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.borderRadius = 20,
    this.elevation = 4,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      elevation: elevation,
      child: child,
    );
  }
}
