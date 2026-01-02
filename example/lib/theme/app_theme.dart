import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Default to Talsec company colours
  static const _fallbackSeed = Color(0xFF8df6a2);
  static const _fallbackSurface = Color(0xFF191B24);

  static ColorScheme getScheme(
    ColorScheme? dynamicScheme,
    Brightness brightness,
  ) {
    if (dynamicScheme != null) {
      return ColorScheme.fromSeed(
        seedColor: dynamicScheme.primary,
        brightness: brightness,
      );
    }

    return ColorScheme.fromSeed(
      seedColor: _fallbackSeed,
      brightness: brightness,
      surface: _fallbackSurface,
    );
  }

  static ThemeData create(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,

      // Font setup
      textTheme: GoogleFonts.openSansTextTheme(),

      // Component Styles
      listTileTheme: ListTileThemeData(
        tileColor: scheme.surfaceContainerHigh,
        titleTextStyle: GoogleFonts.openSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerHigh,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
