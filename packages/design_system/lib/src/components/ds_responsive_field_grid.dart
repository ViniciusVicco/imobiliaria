import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

class DSResponsiveFieldGrid extends StatelessWidget {
  const DSResponsiveFieldGrid({
    super.key,
    required this.columns,
    required this.children,
    this.mainAxisExtent = 68,
  });

  final int columns;
  final List<Widget> children;
  final double mainAxisExtent;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: children.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: DSSpacing.sm,
        crossAxisSpacing: DSSpacing.sm,
        mainAxisExtent: mainAxisExtent,
      ),
      itemBuilder: (context, index) => children[index],
    );
  }
}
