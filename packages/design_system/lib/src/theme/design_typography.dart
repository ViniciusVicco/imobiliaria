import 'package:flutter/material.dart';

class DSTypographyTokens {
  const DSTypographyTokens();

  DSDisplayTypography get display => const DSDisplayTypography();
  DSHeadingTypography get heading => const DSHeadingTypography();
  DSBodyTypography get body => const DSBodyTypography();
  DSLabelTypography get label => const DSLabelTypography();

  TextTheme get textTheme => TextTheme(
    displayLarge: display.xl,
    displaySmall: heading.h1,
    headlineMedium: heading.h2,
    headlineSmall: heading.h3,
    titleLarge: heading.h3,
    titleMedium: label.strong,
    bodyLarge: body.lg,
    bodyMedium: body.md,
    bodySmall: body.sm,
    labelSmall: label.caps,
  );
}

class DSDisplayTypography {
  const DSDisplayTypography();

  TextStyle get xl => const TextStyle(
    fontFamily: 'Noto Serif',
    fontSize: 64,
    fontWeight: FontWeight.w700,
    height: 1.1,
  );

  TextStyle get sm => const TextStyle(
    fontFamily: 'Noto Serif',
    fontSize: 48,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
}

class DSHeadingTypography {
  const DSHeadingTypography();

  TextStyle get h1 => const TextStyle(
    fontFamily: 'Noto Serif',
    fontSize: 48,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  TextStyle get h2 => const TextStyle(
    fontFamily: 'Noto Serif',
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  TextStyle get h3 => const TextStyle(
    fontFamily: 'Noto Serif',
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );
}

class DSBodyTypography {
  const DSBodyTypography();

  TextStyle get lg => const TextStyle(
    fontFamily: 'Manrope',
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  TextStyle get md => const TextStyle(
    fontFamily: 'Manrope',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  TextStyle get sm => const TextStyle(
    fontFamily: 'Manrope',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
}

class DSLabelTypography {
  const DSLabelTypography();

  TextStyle get strong => const TextStyle(
    fontFamily: 'Manrope',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.4,
  );

  TextStyle get caps => const TextStyle(
    fontFamily: 'Manrope',
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1,
    letterSpacing: 1.2,
  );
}
