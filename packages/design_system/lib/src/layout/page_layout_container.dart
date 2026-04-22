import 'package:flutter/material.dart';

class DSPageLayoutContainer extends StatelessWidget {
  const DSPageLayoutContainer({
    super.key,
    required this.child,
    this.maxWidth = 1200,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
