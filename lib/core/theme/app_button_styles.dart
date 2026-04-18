import 'package:app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum AppButtonVariant { primary, soft, active }

class AppButtonStyles {
  const AppButtonStyles._();

  static ButtonStyle resolve(
    BuildContext context, {
    AppButtonVariant variant = AppButtonVariant.primary,
    double height = 48,
    double radius = 14,
  }) {
    final base = Theme.of(context).elevatedButtonTheme.style;
    final colors = _colorsFor(variant);
    return ElevatedButton.styleFrom(
      elevation: 0,
      minimumSize: Size(0, height),
      backgroundColor: colors.$1,
      foregroundColor: colors.$2,
      disabledBackgroundColor: AppTheme.softDisabled,
      disabledForegroundColor: AppTheme.disabledForeground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    ).merge(base);
  }

  static (Color, Color) _colorsFor(AppButtonVariant variant) {
    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.active:
      case AppButtonVariant.soft:
        return (AppTheme.brand, Colors.white);
    }
  }
}
