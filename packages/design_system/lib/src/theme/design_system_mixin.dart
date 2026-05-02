import 'package:flutter/material.dart';

import '../layout/layout_breakpoints.dart';
import 'design_tokens.dart';
import 'design_typography.dart';
import 'theme.dart';

mixin DesignSystemMixin {
  DSTypographyTokens get typography => const DSTypographyTokens();
  DSColorTokens get colors => const DSColorTokens();
  DSSpacingTokens get spacing => const DSSpacingTokens();
  DSRadiusTokens get radius => const DSRadiusTokens();
  DSBreakpointTokens get breakpoints => const DSBreakpointTokens();
}

class DSColorTokens {
  const DSColorTokens();

  Color get surface => DSColors.surface;
  Color get surfaceContainerLowest => DSColors.surfaceContainerLowest;
  Color get surfaceContainer => DSColors.surfaceContainer;
  Color get surfaceContainerHigh => DSColors.surfaceContainerHigh;
  Color get surfaceContainerHighest => DSColors.surfaceContainerHighest;
  Color get onSurface => DSColors.onSurface;
  Color get onSurfaceVariant => DSColors.onSurfaceVariant;
  Color get outline => DSColors.outline;
  Color get outlineVariant => DSColors.outlineVariant;
  Color get primary => DSColors.primary;
  Color get onPrimary => DSColors.onPrimary;
  Color get secondary => DSColors.secondary;
  Color get onSecondary => DSColors.onSecondary;
  Color get tertiary => DSColors.tertiary;
  Color get onTertiary => DSColors.onTertiary;
  Color get error => DSColors.error;
  Color get onError => DSColors.onError;
  Color get background => DSColors.background;
}

class DSSpacingTokens {
  const DSSpacingTokens();

  double get xxs => DSSpacing.xxs;
  double get xs => DSSpacing.xs;
  double get sm => DSSpacing.sm;
  double get md => DSSpacing.md;
  double get lg => DSSpacing.lg;
  double get xl => DSSpacing.xl;
  double get xxl => DSSpacing.xxl;
}

class DSRadiusTokens {
  const DSRadiusTokens();

  BorderRadius get sm => DSRadius.sm;
  BorderRadius get md => DSRadius.md;
  BorderRadius get lg => DSRadius.lg;
}

class DSBreakpointTokens {
  const DSBreakpointTokens();

  double get mobile => DSBreakpoints.mobile;
  double get tablet => DSBreakpoints.tablet;
  double get desktop => DSBreakpoints.desktop;
  double get ultra => DSBreakpoints.ultra;
}
