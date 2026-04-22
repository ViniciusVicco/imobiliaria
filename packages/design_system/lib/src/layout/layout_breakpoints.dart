import 'package:responsive_framework/responsive_framework.dart';

abstract final class DSBreakpoints {
  static const double mobile = 450;
  static const double tablet = 800;
  static const double desktop = 1200;
  static const double ultra = 1920;

  static const List<Breakpoint> defaults = <Breakpoint>[
    Breakpoint(start: 0, end: mobile, name: MOBILE),
    Breakpoint(start: mobile + 1, end: tablet, name: TABLET),
    Breakpoint(start: tablet + 1, end: desktop, name: DESKTOP),
    Breakpoint(start: desktop + 1, end: ultra, name: '4K'),
  ];
}
