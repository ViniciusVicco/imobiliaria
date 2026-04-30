import 'package:flutter/material.dart';

abstract final class DSColors {
  static const Color surface = Color(0xFF121414);
  static const Color surfaceContainerLowest = Color(0xFF0C0F0F);
  static const Color surfaceContainer = Color(0xFF1E2020);
  static const Color surfaceContainerHigh = Color(0xFF282A2B);
  static const Color onSurface = Color(0xFFE2E2E2);
  static const Color onSurfaceVariant = Color(0xFFD0C5AF);
  static const Color outline = Color(0xFF99907C);
  static const Color primary = Color(0xFFF2CA50);
  static const Color onPrimary = Color(0xFF3C2F00);
  static const Color secondary = Color(0xFFBBC6E2);
  static const Color onSecondary = Color(0xFF253046);
  static const Color tertiary = Color(0xFFC4CEEB);
  static const Color onTertiary = Color(0xFF263046);
  static const Color error = Color(0xFFFFB4AB);
  static const Color onError = Color(0xFF690005);
  static const Color background = Color(0xFF121414);
}

abstract final class DSTheme {
  static const ColorScheme colorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: DSColors.primary,
    onPrimary: DSColors.onPrimary,
    secondary: DSColors.secondary,
    onSecondary: DSColors.onSecondary,
    tertiary: DSColors.tertiary,
    onTertiary: DSColors.onTertiary,
    error: DSColors.error,
    onError: DSColors.onError,
    surface: DSColors.surface,
    onSurface: DSColors.onSurface,
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: DSColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: DSColors.onSurface,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
    ),
    textTheme: ThemeData.dark(useMaterial3: true).textTheme.apply(
          bodyColor: DSColors.onSurface,
          displayColor: DSColors.onSurface,
        ),
    dividerColor: DSColors.outline.withOpacity(0.25),
  );
}
