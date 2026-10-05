import 'package:flutter/material.dart';

import 'design_tokens.dart';
import 'design_typography.dart';

abstract final class DSColors {
  static const Color surface = Color(0xFF030E22);
  static const Color surfaceContainerLowest = Color(0xFF030E22);
  static const Color surfaceContainer = Color(0xFF111C31);
  static const Color surfaceContainerHigh = Color(0xFF17233A);
  static const Color surfaceContainerHighest = Color(0xFF1F2B43);
  static const Color brandLogoBackground = Color(0xFF031020);
  static const Color onSurface = Color(0xFFFFFFFF);
  static const Color onSurfaceVariant = Color(0xFFE2E2E2);
  static const Color outline = Color(0xFF2D3748);
  static const Color outlineVariant = Color(0xFF3B4658);
  static const Color primary = Color(0xFFD4AF37);
  static const Color onPrimary = Color(0xFF030E22);
  static const Color secondary = Color(0xFFBBC6E2);
  static const Color onSecondary = Color(0xFF253046);
  static const Color tertiary = Color(0xFFC4CEEB);
  static const Color onTertiary = Color(0xFF263046);
  static const Color error = Color(0xFFFFB4AB);
  static const Color onError = Color(0xFF690005);
  static const Color background = Color(0xFF030E22);
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
    textTheme: _textTheme,
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: DSColors.surfaceContainer,
      border: OutlineInputBorder(
        borderRadius: DSRadius.sm,
        borderSide: BorderSide(color: DSColors.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: DSRadius.sm,
        borderSide: BorderSide(color: DSColors.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: DSRadius.sm,
        borderSide: BorderSide(color: DSColors.primary),
      ),
      labelStyle: TextStyle(color: DSColors.onSurfaceVariant),
      hintStyle: TextStyle(color: DSColors.onSurfaceVariant),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: DSColors.primary,
        foregroundColor: DSColors.onPrimary,
        shape: const RoundedRectangleBorder(borderRadius: DSRadius.sm),
        textStyle: const TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: DSColors.primary,
        side: const BorderSide(color: DSColors.primary),
        shape: const RoundedRectangleBorder(borderRadius: DSRadius.sm),
        textStyle: const TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: DSColors.onSurface,
        shape: const RoundedRectangleBorder(borderRadius: DSRadius.sm),
        textStyle: const TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: DSColors.surfaceContainerHigh,
      labelStyle: TextStyle(
        color: DSColors.onSurface,
        fontFamily: 'Manrope',
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: DSRadius.sm,
        side: BorderSide(color: DSColors.outline),
      ),
    ),
    dividerColor: DSColors.outline.withValues(alpha: 0.25),
  );

  static final TextTheme _textTheme = const DSTypographyTokens().textTheme.apply(
    bodyColor: DSColors.onSurface,
    displayColor: DSColors.onSurface,
  );
}
