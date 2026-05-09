import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';
import '../theme/theme.dart';

class DSInfoCard extends StatelessWidget {
  const DSInfoCard({
    super.key,
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: DSColors.surfaceContainer,
        borderRadius: DSRadius.md,
        border: Border.all(color: DSColors.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: DSSpacing.sm),
            Text(
              body,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: DSColors.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
