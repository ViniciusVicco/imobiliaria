import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class PropertyTagChips extends StatelessWidget {
  const PropertyTagChips({super.key, required this.tags}) : isOverlay = false;

  const PropertyTagChips.overlay({super.key, required this.tags})
    : isOverlay = true;

  final bool isOverlay;
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final visibleTags = tags
        .where((tag) => tag.trim().isNotEmpty)
        .take(isOverlay ? 2 : 3)
        .toList(growable: false);

    if (visibleTags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      alignment: isOverlay ? WrapAlignment.end : WrapAlignment.start,
      spacing: DSSpacing.xs,
      runSpacing: DSSpacing.xs,
      children: visibleTags
          .map(
            (tag) => DecoratedBox(
              decoration: BoxDecoration(
                color: DSColors.primary,
                borderRadius: DSRadius.sm,
                border: isOverlay
                    ? Border.all(
                        color: DSColors.onPrimary.withValues(alpha: 0.28),
                      )
                    : null,
                boxShadow: isOverlay
                    ? const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x52000000),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.sm,
                  vertical: DSSpacing.xs,
                ),
                child: Text(
                  _propertyTagLabel(tag),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
