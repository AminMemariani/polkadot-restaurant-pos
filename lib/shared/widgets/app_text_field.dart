import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../utils/platform_utils.dart';

/// Text field that adopts a frosted-glass look on Apple platforms and the
/// app's Material 3 [InputDecorationTheme] elsewhere.
///
/// All [TextField] parameters that the rest of the app actually uses are
/// exposed; pass [validator] to wrap as a [TextFormField] for use inside a
/// [Form].
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffix,
    this.suffixIcon,
    this.suffixText,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.enabled = true,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final Widget? prefixIcon;
  final Widget? suffix;
  final Widget? suffixIcon;
  final String? suffixText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final decoration = _decoration(context);

    Widget field;
    if (validator != null) {
      field = TextFormField(
        controller: controller,
        focusNode: focusNode,
        decoration: decoration,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onChanged: onChanged,
        onFieldSubmitted: onSubmitted,
        onTap: onTap,
        validator: validator,
        enabled: enabled,
        obscureText: obscureText,
        maxLines: obscureText ? 1 : maxLines,
        minLines: minLines,
        autofocus: autofocus,
      );
    } else {
      field = TextField(
        controller: controller,
        focusNode: focusNode,
        decoration: decoration,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onTap: onTap,
        enabled: enabled,
        obscureText: obscureText,
        maxLines: obscureText ? 1 : maxLines,
        minLines: minLines,
        autofocus: autofocus,
      );
    }

    if (!PlatformUtils.isApple) return field;
    return _GlassFieldWrapper(child: field);
  }

  InputDecoration _decoration(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (PlatformUtils.isApple) {
      // Inside a glass wrapper the field paints its own background, so we
      // turn off the Material fill and borders.
      return InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffix: suffix,
        suffixIcon: suffixIcon,
        suffixText: suffixText,
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      );
    }

    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon,
      suffix: suffix,
      suffixIcon: suffixIcon,
      suffixText: suffixText,
    );
  }
}

class _GlassFieldWrapper extends StatelessWidget {
  const _GlassFieldWrapper({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final radius = BorderRadius.circular(AppRadius.md);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.surface.withValues(alpha: 0.45)
                : Colors.white.withValues(alpha: 0.55),
            borderRadius: radius,
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.4),
              width: 0.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
