import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../utils/platform_utils.dart';
import 'glass_surface.dart';

/// A card-shaped container that uses [GlassSurface] on Apple platforms and
/// a Material 3 [Card] elsewhere.
///
/// On Apple platforms it renders the Liquid Glass blur defined by
/// [GlassSurface]. On other platforms it falls through to a Material [Card]
/// so it picks up the app's [CardTheme] (color, elevation, shape).
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.margin,
    this.borderRadius = AppRadius.lg,
    this.elevation = 4,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isApple) {
      return GlassSurface(
        padding: padding,
        margin: margin,
        borderRadius: borderRadius,
        elevation: elevation,
        child: child,
      );
    }

    final card = Card(
      elevation: elevation,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Padding(padding: padding, child: child),
    );

    if (margin == null) return card;
    return Padding(padding: margin!, child: card);
  }
}
