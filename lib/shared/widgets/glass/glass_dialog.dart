import 'dart:ui';

import 'package:flutter/material.dart';

import '../../utils/platform_utils.dart';

/// A dialog that uses a Liquid Glass-inspired surface on Apple platforms and
/// a standard Material 3 [AlertDialog] elsewhere.
///
/// Usage mirrors [AlertDialog]:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => GlassDialog(
///     title: const Text('Confirm'),
///     content: const Text('Proceed?'),
///     actions: [...],
///   ),
/// );
/// ```
class GlassDialog extends StatelessWidget {
  const GlassDialog({
    super.key,
    this.title,
    this.content,
    this.actions,
    this.blurSigma = 32,
  });

  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (!PlatformUtils.isApple) {
      return AlertDialog(title: title, content: content, actions: actions);
    }

    final isDark = theme.brightness == Brightness.dark;
    final tint = isDark
        ? colorScheme.surface.withValues(alpha: 0.7)
        : Colors.white.withValues(alpha: 0.75);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: isDark ? 0.1 : 0.3),
                width: 0.5,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (title != null)
                  DefaultTextStyle(
                    style: theme.textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    child: title!,
                  ),
                if (title != null && content != null)
                  const SizedBox(height: 12),
                if (content != null)
                  Flexible(
                    child: DefaultTextStyle(
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.85),
                      ),
                      child: content!,
                    ),
                  ),
                if (actions != null && actions!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  OverflowBar(
                    alignment: MainAxisAlignment.end,
                    spacing: 8,
                    children: actions!,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
