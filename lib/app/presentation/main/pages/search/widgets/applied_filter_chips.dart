import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/property_search_filters_entity.dart';
import 'property_search_formatters.dart';

class AppliedFilterChips extends StatelessWidget {
  const AppliedFilterChips({super.key, required this.filters});

  final PropertySearchFiltersEntity filters;

  @override
  Widget build(BuildContext context) {
    final labels = <String>[
      if (filters.segment != PropertySegment.all) filters.segment.label,
      if (filters.propertyType != AnyPropertyType.any)
        filters.propertyType.label,
      if (filters.blockOrNeighborhood.trim().isNotEmpty)
        filters.blockOrNeighborhood.trim(),
      if (filters.tag.trim().isNotEmpty) tagLabel(filters.tag),
      if (filters.query.trim().isNotEmpty) '"${filters.query.trim()}"',
      if (filters.bedroomsMin != null) '${filters.bedroomsMin}+ quartos',
      if (filters.bathroomsMin != null) '${filters.bathroomsMin}+ banheiros',
      if (filters.garageSpacesMin != null) '${filters.garageSpacesMin}+ vagas',
      if (filters.priceMin != null)
        'A partir de ${formatPrice(filters.priceMin!)}',
      if (filters.priceMax != null) 'Ate ${formatPrice(filters.priceMax!)}',
    ];

    if (labels.isEmpty) {
      return const Text(
        'Exibindo todos os segmentos e tipos.',
        style: TextStyle(color: DSColors.onSurfaceVariant),
      );
    }

    return Wrap(
      spacing: DSSpacing.xs,
      runSpacing: DSSpacing.xs,
      children: labels.map((label) => Chip(label: Text(label))).toList(),
    );
  }
}
