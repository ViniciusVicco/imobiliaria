import 'package:flutter/material.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/featured_property_entity.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/property_search_filters_entity.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/search_property_entity.dart';

import '../../widgets/search/property_search_panel.dart';

class StockFilterPanel extends StatelessWidget {
  const StockFilterPanel({
    super.key,
    required this.filters,
    required this.result,
    required this.queryController,
    required this.blockOrNeighborhoodController,
    required this.onFiltersChanged,
    required this.onSegmentChanged,
    required this.onSubmit,
    required this.onClear,
  });

  final PropertySearchFiltersEntity filters;
  final PropertySearchResultEntity? result;
  final TextEditingController queryController;
  final TextEditingController blockOrNeighborhoodController;
  final ValueChanged<PropertySearchFiltersEntity> onFiltersChanged;
  final ValueChanged<PropertySegment> onSegmentChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return PropertySearchPanel(
      filters: filters,
      properties: _asFeaturedProperties(result?.items),
      queryController: queryController,
      blockOrNeighborhoodController: blockOrNeighborhoodController,
      onFiltersChanged: onFiltersChanged,
      onSegmentChanged: onSegmentChanged,
      onSubmit: onSubmit,
      onClear: onClear,
      title: 'Filtrar imóveis a venda',
      submitLabel: 'Aplicar filtros',
      allowAll: true,
      vertical: true,
      autoSubmitShortcuts: false,
      priceRangeMin: result?.priceRange.min,
      priceRangeMax: result?.priceRange.max,
    );
  }
}

List<FeaturedPropertyEntity> _asFeaturedProperties(
  List<SearchPropertyEntity>? properties,
) {
  return (properties ?? const <SearchPropertyEntity>[])
      .map(
        (property) => FeaturedPropertyEntity(
          id: property.id,
          title: property.title,
          segment: property.segment,
          propertyType: property.propertyType,
          city: property.city,
          neighborhood: property.neighborhood,
          subNeighborhood: property.subNeighborhood,
          coverUrl: property.coverUrl,
          areaM2: property.areaM2,
          bedrooms: property.bedrooms,
          bathrooms: property.bathrooms,
          garageSpaces: property.garageSpaces,
          propertyAgeYears: property.propertyAgeYears,
          price: property.price,
          tags: property.tags,
        ),
      )
      .toList();
}
