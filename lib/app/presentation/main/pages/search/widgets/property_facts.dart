import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/search_property_entity.dart';

class PropertyFacts extends StatelessWidget {
  const PropertyFacts({super.key, required this.property});

  final SearchPropertyEntity property;

  @override
  Widget build(BuildContext context) {
    final facts = <String>[
      '${property.areaM2} m2',
      if (property.bedrooms != null) '${property.bedrooms} quartos',
      '${property.bathrooms} banheiros',
      '${property.garageSpaces} vagas',
    ];

    return Wrap(
      spacing: DSSpacing.sm,
      runSpacing: DSSpacing.xs,
      children: facts
          .map(
            (fact) => Text(
              fact,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          )
          .toList(),
    );
  }
}
