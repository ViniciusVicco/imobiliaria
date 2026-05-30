import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class PropertyTagChips extends StatelessWidget {
  const PropertyTagChips({super.key, required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final visibleTags = tags
        .where((tag) => tag.trim().isNotEmpty)
        .take(3)
        .toList(growable: false);

    if (visibleTags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: DSSpacing.xs,
      runSpacing: DSSpacing.xs,
      children: visibleTags
          .map(
            (tag) => DecoratedBox(
              decoration: BoxDecoration(
                color: DSColors.primary,
                borderRadius: DSRadius.sm,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.sm,
                  vertical: DSSpacing.xxs,
                ),
                child: Text(
                  _propertyTagLabel(tag),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: DSColors.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

String _propertyTagLabel(String tag) {
  return switch (tag) {
    'na-planta' => 'Na planta',
    'recem-entregue' => 'Recem entregue',
    'alta-rentabilidade' => 'Alta rentabilidade',
    'entrada-reduzida' => 'Entrada reduzida',
    'exclusivo' => 'Exclusivo',
    'pronto-para-morar' => 'Pronto para morar',
    _ => tag,
  };
}
