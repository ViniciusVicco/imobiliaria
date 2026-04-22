import 'package:flutter/widgets.dart';
import 'package:responsive_framework/responsive_framework.dart';

extension DSLayoutContextExtension on BuildContext {
  bool get isMobileLayout => ResponsiveBreakpoints.of(this).smallerOrEqualTo(TABLET);

  bool get isTabletLayout => ResponsiveBreakpoints.of(this).between(TABLET, DESKTOP);

  bool get isDesktopLayout => ResponsiveBreakpoints.of(this).largerThan(TABLET);
}
