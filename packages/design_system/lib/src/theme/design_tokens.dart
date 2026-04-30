import 'package:flutter/widgets.dart';

abstract final class DSSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 48;
  static const double xxl = 80;
}

abstract final class DSRadius {
  static const BorderRadius sm = BorderRadius.all(Radius.circular(8));
  static const BorderRadius md = BorderRadius.all(Radius.circular(12));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(20));
}
