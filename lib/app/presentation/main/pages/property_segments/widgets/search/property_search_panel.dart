import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/featured_property_entity.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/property_search_filters_entity.dart';

class PropertySearchPanel extends StatefulWidget {
  const PropertySearchPanel({
    super.key,
    required this.filters,
    required this.properties,
    required this.queryController,
    required this.blockOrNeighborhoodController,
    required this.onFiltersChanged,
    required this.onSegmentChanged,
    required this.onSubmit,
  });

  final PropertySearchFiltersEntity filters;
  final List<FeaturedPropertyEntity> properties;
  final TextEditingController queryController;
  final TextEditingController blockOrNeighborhoodController;
  final ValueChanged<PropertySearchFiltersEntity> onFiltersChanged;
  final ValueChanged<PropertySegment> onSegmentChanged;
  final VoidCallback onSubmit;

  @override
  State<PropertySearchPanel> createState() => _PropertySearchPanelState();
}

class _PropertySearchPanelState extends State<PropertySearchPanel> {
  bool _showAdvancedFilters = false;

  bool get isWide => MediaQuery.of(context).size.width >= 920;

  Widget buildVerticalPadding({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final neighborhoodOptions = _buildNeighborhoodOptions(widget.properties);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: DSColors.surfaceContainer,
        borderRadius: DSRadius.lg,
        border: Border.all(color: DSColors.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.lg),
        child: Column(
          spacing: 2,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Busca em Palmas',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: DSSpacing.md),
            LayoutBuilder(
              builder: (context, constraints) {
                final mainFields = <DSWeightedField>[
                  DSWeightedField(
                    flex: 3,
                    builder: (context) => buildVerticalPadding(
                      child: _NeighborhoodDropdown(
                        controller: widget.blockOrNeighborhoodController,
                        value: widget.filters.blockOrNeighborhood,
                        options: neighborhoodOptions,
                        onChanged: _updateNeighborhood,
                      ),
                    ),
                  ),
                  DSWeightedField(
                    flex: 2,
                    builder: (context) => buildVerticalPadding(
                      child: _SegmentDropdown(
                        value: widget.filters.segment,
                        onChanged: widget.onSegmentChanged,
                      ),
                    ),
                  ),
                  DSWeightedField(
                    flex: 2,
                    builder: (context) => buildVerticalPadding(
                      child: _PropertyTypeDropdown(
                        value: widget.filters.propertyType,
                        options: widget.filters.segment.propertyTypes,
                        onChanged: (value) => widget.onFiltersChanged(
                          widget.filters.copyWith(propertyType: value),
                        ),
                      ),
                    ),
                  ),
                  DSWeightedField(
                    flex: 0,
                    builder: (context) => SizedBox(
                      height: 56,
                      child: FilledButton.icon(
                        onPressed: widget.onSubmit,
                        icon: const Icon(Icons.search),
                        label: const Text('Buscar'),
                      ),
                    ),
                  ),
                ];

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: mainFields
                        .map(
                          (field) => field.flex == 0
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                    left: DSSpacing.sm,
                                  ),
                                  child: field,
                                )
                              : Expanded(
                                  flex: field.flex,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      right: DSSpacing.sm,
                                    ),
                                    child: field,
                                  ),
                                ),
                        )
                        .toList(),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: mainFields
                      .map(
                        (field) => Padding(
                          padding: const EdgeInsets.only(bottom: DSSpacing.sm),
                          child: field,
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(height: DSSpacing.sm),
            _QuickFilterChips(
              neighborhoodOptions: neighborhoodOptions,
              onLocationSelected: _selectLocation,
              onFiltersSelected: _selectQuickFilters,
            ),
            const SizedBox(height: DSSpacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  setState(() => _showAdvancedFilters = !_showAdvancedFilters);
                },
                icon: Icon(
                  _showAdvancedFilters ? Icons.expand_less : Icons.tune,
                ),
                label: Text(
                  _showAdvancedFilters ? 'Ocultar filtros' : 'Mais filtros',
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: DSSpacing.sm),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 980
                        ? 4
                        : constraints.maxWidth >= 680
                        ? 2
                        : 1;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        DSResponsiveFieldGrid(
                          columns: columns,
                          children: <Widget>[
                            TextField(
                              controller: widget.queryController,
                              decoration: const InputDecoration(
                                labelText: 'Palavra-chave',
                                hintText: 'Ex: varanda gourmet',
                                border: OutlineInputBorder(
                                  borderRadius: DSRadius.sm,
                                ),
                              ),
                              onChanged: (value) => widget.onFiltersChanged(
                                widget.filters.copyWith(query: value),
                              ),
                            ),
                            _MinCountDropdown(
                              label: 'Quartos',
                              value: widget.filters.bedroomsMin,
                              onChanged: (value) => widget.onFiltersChanged(
                                widget.filters.copyWith(
                                  bedroomsMin: value,
                                  clearBedrooms: value == null,
                                ),
                              ),
                            ),
                            _MinCountDropdown(
                              label: 'Banheiros',
                              value: widget.filters.bathroomsMin,
                              onChanged: (value) => widget.onFiltersChanged(
                                widget.filters.copyWith(
                                  bathroomsMin: value,
                                  clearBathrooms: value == null,
                                ),
                              ),
                            ),
                            _MinCountDropdown(
                              label: 'Vagas',
                              value: widget.filters.garageSpacesMin,
                              onChanged: (value) => widget.onFiltersChanged(
                                widget.filters.copyWith(
                                  garageSpacesMin: value,
                                  clearGarageSpaces: value == null,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: DSSpacing.md),
                        _PriceRangeSlider(
                          properties: widget.properties,
                          filters: widget.filters,
                          onChanged: widget.onFiltersChanged,
                        ),
                      ],
                    );
                  },
                ),
              ),
              crossFadeState: _showAdvancedFilters
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 220),
              firstCurve: Curves.easeOutCubic,
              secondCurve: Curves.easeOutCubic,
            ),
          ],
        ),
      ),
    );
  }

  void _selectLocation(String value) {
    _updateNeighborhood(value);
    widget.onSubmit();
  }

  void _updateNeighborhood(String value) {
    widget.blockOrNeighborhoodController.text = value;
    widget.onFiltersChanged(
      widget.filters.copyWith(blockOrNeighborhood: value),
    );
  }

  void _selectQuickFilters(PropertySearchFiltersEntity filters) {
    widget.onFiltersChanged(filters);
    widget.onSubmit();
  }
}

List<String> _buildNeighborhoodOptions(List<FeaturedPropertyEntity> properties) {
  final neighborhoods = properties
      .map((property) => property.subNeighborhood.trim())
      .where((neighborhood) => neighborhood.isNotEmpty)
      .toSet()
      .toList();
  neighborhoods.sort();
  return neighborhoods;
}

class _NeighborhoodDropdown extends StatelessWidget {
  const _NeighborhoodDropdown({
    required this.controller,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final normalizedValue = value.trim();
    final selectedValue = options.contains(normalizedValue)
        ? normalizedValue
        : null;

    return DropdownButtonFormField<String>(
      initialValue: selectedValue,
      decoration: const InputDecoration(
        labelText: 'Bairro, quadra ou condominio',
        hintText: 'Selecione um bairro disponivel',
        border: OutlineInputBorder(borderRadius: DSRadius.sm),
      ),
      items: options
          .map(
            (neighborhood) => DropdownMenuItem<String>(
              value: neighborhood,
              child: Text(neighborhood),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) return;
        controller.text = value;
        onChanged(value);
      },
    );
  }
}

class _QuickFilterChips extends StatelessWidget {
  const _QuickFilterChips({
    required this.neighborhoodOptions,
    required this.onLocationSelected,
    required this.onFiltersSelected,
  });

  final List<String> neighborhoodOptions;
  final ValueChanged<String> onLocationSelected;
  final ValueChanged<PropertySearchFiltersEntity> onFiltersSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: DSSpacing.xs,
      runSpacing: DSSpacing.xs,
      children: <Widget>[
        for (final neighborhood in neighborhoodOptions)
          _QuickFilterChip(
            label: neighborhood,
            onPressed: () => onLocationSelected(neighborhood),
          ),
        _QuickFilterChip(
          label: 'Casas em condominio',
          onPressed: () => onFiltersSelected(
            const PropertySearchFiltersEntity(
              segment: PropertySegment.residential,
              propertyType: ResidentialPropertyType.condominiumHouse,
            ),
          ),
        ),
        _QuickFilterChip(
          label: 'Na planta',
          onPressed: () => onFiltersSelected(
            const PropertySearchFiltersEntity(
              segment: PropertySegment.investments,
              propertyType: InvestmentPropertyType.newDevelopment,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickFilterChip extends StatelessWidget {
  const _QuickFilterChip({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onPressed,
      side: const BorderSide(color: DSColors.outline),
      shape: const RoundedRectangleBorder(borderRadius: DSRadius.sm),
      backgroundColor: DSColors.surfaceContainerHigh,
      labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: DSColors.onSurface,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _SegmentDropdown extends StatelessWidget {
  const _SegmentDropdown({required this.value, required this.onChanged});

  final PropertySegment value;
  final ValueChanged<PropertySegment> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<PropertySegment>(
      initialValue: value,
      decoration: const InputDecoration(
        labelText: 'Segmento',
        border: OutlineInputBorder(borderRadius: DSRadius.sm),
      ),
      items: PropertySegment.values
          .map(
            (segment) => DropdownMenuItem<PropertySegment>(
              value: segment,
              child: Text(segment.label),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) return;
        onChanged(value);
      },
    );
  }
}

class _PropertyTypeDropdown extends StatelessWidget {
  const _PropertyTypeDropdown({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final PropertyFilterOption value;
  final List<PropertyFilterOption> options;
  final ValueChanged<PropertyFilterOption> onChanged;

  @override
  Widget build(BuildContext context) {
    final selectedValue = options.contains(value) ? value : options.first;
    return DropdownButtonFormField<PropertyFilterOption>(
      initialValue: selectedValue,
      decoration: const InputDecoration(
        labelText: 'Tipo do imovel',
        border: OutlineInputBorder(borderRadius: DSRadius.sm),
      ),
      items: options
          .map(
            (option) => DropdownMenuItem<PropertyFilterOption>(
              value: option,
              child: Text(option.label),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) return;
        onChanged(value);
      },
    );
  }
}

class _MinCountDropdown extends StatelessWidget {
  const _MinCountDropdown({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int?>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(borderRadius: DSRadius.sm),
      ),
      items: <DropdownMenuItem<int?>>[
        const DropdownMenuItem<int?>(value: null, child: Text('Qualquer')),
        for (final option in <int>[1, 2, 3, 4, 5])
          DropdownMenuItem<int?>(value: option, child: Text('$option+')),
      ],
      onChanged: onChanged,
    );
  }
}

class _PriceRangeSlider extends StatelessWidget with DesignSystemMixin {
  const _PriceRangeSlider({
    required this.properties,
    required this.filters,
    required this.onChanged,
  });

  final List<FeaturedPropertyEntity> properties;
  final PropertySearchFiltersEntity filters;
  final ValueChanged<PropertySearchFiltersEntity> onChanged;

  @override
  Widget build(BuildContext context) {
    if (properties.isEmpty) {
      return const SizedBox.shrink();
    }

    final prices = properties.map((property) => property.price).toList();
    final minPrice = prices.reduce(
      (value, element) => value < element ? value : element,
    );
    final maxPrice = prices.reduce(
      (value, element) => value > element ? value : element,
    );

    if (minPrice == maxPrice) {
      return _PriceRangeSummary(
        label: 'Valor',
        value: _formatCurrency(minPrice),
      );
    }

    final selectedMin = (filters.priceMin ?? minPrice).clamp(
      minPrice,
      maxPrice,
    );
    final selectedMax = (filters.priceMax ?? maxPrice).clamp(
      minPrice,
      maxPrice,
    );
    final rangeStart = selectedMin <= selectedMax ? selectedMin : selectedMax;
    final rangeEnd = selectedMin <= selectedMax ? selectedMax : selectedMin;
    final values = RangeValues(rangeStart.toDouble(), rangeEnd.toDouble());

    return DecoratedBox(
      decoration: BoxDecoration(
        color: DSColors.surfaceContainerHigh,
        borderRadius: DSRadius.sm,
        border: Border.all(color: DSColors.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          DSSpacing.md,
          DSSpacing.sm,
          DSSpacing.md,
          DSSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Faixa de valor',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: DSSpacing.xs),
            Text(
              '${_formatCurrency(values.start.round())} - ${_formatCurrency(values.end.round())}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: DSColors.onSurfaceVariant,
              ),
            ),
            RangeSlider(
              min: minPrice.toDouble(),
              max: maxPrice.toDouble(),
              values: values,
              labels: RangeLabels(
                _formatCurrency(values.start.round()),
                _formatCurrency(values.end.round()),
              ),
              onChanged: (value) {
                onChanged(
                  filters.copyWith(
                    priceMin: value.start.round(),
                    priceMax: value.end.round(),
                  ),
                );
              },
            ),
            Text(
              '* A faixa apresenta o imovel mais acessivel ao mais caro que possuimos.',
              style: typography.body.sm.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceRangeSummary extends StatelessWidget {
  const _PriceRangeSummary({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: DSColors.surfaceContainerHigh,
        borderRadius: DSRadius.sm,
        border: Border.all(color: DSColors.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.md),
        child: Row(
          children: <Widget>[
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: DSColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatCurrency(int price) {
  final text = price.toString();
  final buffer = StringBuffer();
  for (var index = 0; index < text.length; index++) {
    final positionFromEnd = text.length - index;
    buffer.write(text[index]);
    if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
      buffer.write('.');
    }
  }
  return 'R\$ ${buffer.toString()}';
}
