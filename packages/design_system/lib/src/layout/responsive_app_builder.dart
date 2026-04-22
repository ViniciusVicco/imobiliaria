import 'package:flutter/widgets.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'layout_breakpoints.dart';

abstract final class DSResponsiveAppBuilder {
  static Widget build(BuildContext context, Widget? child) {
    return ResponsiveBreakpoints.builder(
      child: child ?? const SizedBox.shrink(),
      breakpoints: DSBreakpoints.defaults,
    );
  }
}
