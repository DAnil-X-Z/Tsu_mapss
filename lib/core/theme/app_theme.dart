import 'package:flutter/material.dart';

class AppTheme {
  static const Color brand = Color(0xFF0172BB);
  static const Color brandDark = Color(0xFF0D4D73);
  static const Color softSurface = Color(0xFFE9F4FB);
  static const Color softDisabled = Color(0xFFD7DEE3);
  static const Color disabledForeground = Color(0xFF8A99A5);

  static ThemeData light() {
    final base = ThemeData(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(seedColor: brand),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: brandDark,
        centerTitle: false,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size(0, 48),
          backgroundColor: brand,
          foregroundColor: Colors.white,
          disabledBackgroundColor: softDisabled,
          disabledForegroundColor: disabledForeground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
