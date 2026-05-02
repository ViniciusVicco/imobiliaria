import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/featured_property_entity.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/home_brand_content_entity.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/property_search_filters_entity.dart';
import 'package:imobiliaria/app/presentation/main/main_module.dart';
import 'package:imobiliaria/app/presentation/main/pages/property_segments/property_segments_home_controller.dart';
import 'package:imobiliaria/app/presentation/main/pages/property_segments/widgets/youtube_embed.dart';
import 'package:legend_core/legend_core.dart';

class PropertySegmentsHomePage extends StatefulWidget {
  const PropertySegmentsHomePage({super.key});

  @override
  State<PropertySegmentsHomePage> createState() =>
      _PropertySegmentsHomePageState();
}

class _PropertySegmentsHomePageState
    extends
        StateController<
          MainModule,
          PropertySegmentsHomePage,
          PropertySegmentsHomeController
        >
    with DesignSystemMixin {
  final _contactKey = GlobalKey();
  final _aboutKey = GlobalKey();
  final _missionKey = GlobalKey();
  late final TextEditingController _queryController;
  late final TextEditingController _blockOrNeighborhoodController;

  @override
  void initState() {
    super.initState();
    final filters = controller.store.filters;
    _queryController = TextEditingController(text: filters.query);
    _blockOrNeighborhoodController = TextEditingController(
      text: filters.blockOrNeighborhood,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadHome();
    });
  }

  @override
  void dispose() {
    _queryController.dispose();
    _blockOrNeighborhoodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<AppStateEnum>(
        valueListenable: controller.store.state,
        builder: (context, state, child) {
          final isLoading = state == AppStateEnum.isLoading;
          final errorMessage = state == AppStateEnum.hasError
              ? controller.store.consumeErrorMessage()
              : null;

          if (errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(errorMessage)));
            });
          }

          final brandContent = controller.store.brandContent;

          return Stack(
            children: <Widget>[
              CustomScrollView(
                slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: _TopNavigation(
                      onNewDevelopmentsPressed: () =>
                          controller.onNewDevelopmentsPressed(),
                      onContactPressed: () => _scrollTo(_contactKey),
                      onAboutPressed: () => _scrollTo(_aboutKey),
                      onMissionPressed: () => _scrollTo(_missionKey),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: DSPageLayoutContainer(
                      padding: const EdgeInsets.fromLTRB(
                        DSSpacing.md,
                        DSSpacing.xl,
                        DSSpacing.md,
                        DSSpacing.lg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _BrandMessage(content: brandContent),
                          const SizedBox(height: DSSpacing.lg),
                          _SearchPanel(
                            filters: controller.store.filters,
                            properties: controller.store.featuredProperties,
                            queryController: _queryController,
                            blockOrNeighborhoodController:
                                _blockOrNeighborhoodController,
                            onFiltersChanged: controller.updateFilters,
                            onSegmentChanged: controller.updateSegment,
                            onSubmit: () => controller.onSearchSubmitted(),
                          ),
                          const SizedBox(height: DSSpacing.xl),
                          _FeaturedPropertiesSection(
                            properties: controller.store.featuredProperties,
                            onSimilarSearch: _searchSimilar,
                          ),
                          const SizedBox(height: DSSpacing.xl),
                          _VideoSection(
                            content: brandContent,
                            onPressed: () => controller.onVideoPressed(),
                          ),
                          const SizedBox(height: DSSpacing.xl),
                          _BrandCardsSection(
                            contactKey: _contactKey,
                            aboutKey: _aboutKey,
                            missionKey: _missionKey,
                            content: brandContent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (isLoading)
                Positioned.fill(
                  child: ColoredBox(
                    color: DSColors.surface.withValues(alpha: 0.55),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _scrollTo(GlobalKey key) {
    final targetContext = key.currentContext;
    if (targetContext == null) return;
    Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  void _searchSimilar(FeaturedPropertyEntity property) {
    final segment = switch (property.segment) {
      'commercial' => PropertySegment.commercial,
      'investments' => PropertySegment.investments,
      _ => PropertySegment.residential,
    };

    controller.updateSegment(segment);
    controller.onSearchSubmitted();
  }
}

class _TopNavigation extends StatelessWidget {
  const _TopNavigation({
    required this.onNewDevelopmentsPressed,
    required this.onContactPressed,
    required this.onAboutPressed,
    required this.onMissionPressed,
  });

  final VoidCallback onNewDevelopmentsPressed;
  final VoidCallback onContactPressed;
  final VoidCallback onAboutPressed;
  final VoidCallback onMissionPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.md),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: DSColors.surfaceContainer,
            borderRadius: DSRadius.md,
            border: Border.all(color: DSColors.outline),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.md,
              vertical: DSSpacing.sm,
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: DSSpacing.xs,
              children: <Widget>[
                TextButton(
                  onPressed: onNewDevelopmentsPressed,
                  child: const Text('Novidades na planta'),
                ),
                Wrap(
                  spacing: DSSpacing.xs,
                  children: <Widget>[
                    TextButton(
                      onPressed: onContactPressed,
                      child: const Text('Contatos'),
                    ),
                    TextButton(
                      onPressed: onAboutPressed,
                      child: const Text('Sobre nos'),
                    ),
                    TextButton(
                      onPressed: onMissionPressed,
                      child: const Text('Missao'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandMessage extends StatelessWidget {
  const _BrandMessage({required this.content});

  final HomeBrandContentEntity? content;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Seletta Imobiliaria',
          style: Theme.of(
            context,
          ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: DSSpacing.sm),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 780),
          child: Text(
            content?.mission ??
                'Curadoria de imoveis para morar, investir e expandir negocios.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: DSColors.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchPanel extends StatefulWidget {
  const _SearchPanel({
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
  State<_SearchPanel> createState() => _SearchPanelState();
}

class _SearchPanelState extends State<_SearchPanel> {
  bool _showAdvancedFilters = false;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: DSColors.surfaceContainer,
        borderRadius: DSRadius.lg,
        border: Border.all(color: DSColors.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Busca em Palmas',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: DSSpacing.md),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 920;
                final mainFields = <_WeightedField>[
                  _WeightedField(
                    flex: 3,
                    child: TextField(
                      controller: widget.blockOrNeighborhoodController,
                      decoration: const InputDecoration(
                        labelText: 'Bairro, quadra ou condominio',
                        hintText:
                            'Ex: 706 Sul, Arse 72, Plano Diretor Sul, Mirante do Lago',
                        border: OutlineInputBorder(borderRadius: DSRadius.sm),
                      ),
                      onChanged: (value) => widget.onFiltersChanged(
                        widget.filters.copyWith(blockOrNeighborhood: value),
                      ),
                    ),
                  ),
                  _WeightedField(
                    flex: 2,
                    child: _SegmentDropdown(
                      value: widget.filters.segment,
                      onChanged: widget.onSegmentChanged,
                    ),
                  ),
                  _WeightedField(
                    flex: 2,
                    child: _PropertyTypeDropdown(
                      value: widget.filters.propertyType,
                      options: widget.filters.segment.propertyTypes,
                      onChanged: (value) => widget.onFiltersChanged(
                        widget.filters.copyWith(propertyType: value),
                      ),
                    ),
                  ),
                  _WeightedField(
                    flex: 0,
                    child: SizedBox(
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
                                  child: field.child,
                                )
                              : Expanded(
                                  flex: field.flex,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      right: DSSpacing.sm,
                                    ),
                                    child: field.child,
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
                          child: field.child,
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(height: DSSpacing.sm),
            _QuickFilterChips(
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
                        _ResponsiveFieldGrid(
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
    widget.blockOrNeighborhoodController.text = value;
    widget.onFiltersChanged(
      widget.filters.copyWith(blockOrNeighborhood: value),
    );
    widget.onSubmit();
  }

  void _selectQuickFilters(PropertySearchFiltersEntity filters) {
    widget.onFiltersChanged(filters);
    widget.onSubmit();
  }
}

class _WeightedField {
  const _WeightedField({required this.flex, required this.child});

  final int flex;
  final Widget child;
}

class _QuickFilterChips extends StatelessWidget {
  const _QuickFilterChips({
    required this.onLocationSelected,
    required this.onFiltersSelected,
  });

  final ValueChanged<String> onLocationSelected;
  final ValueChanged<PropertySearchFiltersEntity> onFiltersSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: DSSpacing.xs,
      runSpacing: DSSpacing.xs,
      children: <Widget>[
        _QuickFilterChip(
          label: '706 Sul',
          onPressed: () => onLocationSelected('706 Sul'),
        ),
        _QuickFilterChip(
          label: 'Plano Diretor Sul',
          onPressed: () => onLocationSelected('Plano Diretor Sul'),
        ),
        _QuickFilterChip(
          label: 'Plano Diretor Norte',
          onPressed: () => onLocationSelected('Plano Diretor Norte'),
        ),
        _QuickFilterChip(
          label: 'Taquaralto',
          onPressed: () => onLocationSelected('Taquaralto'),
        ),
        _QuickFilterChip(
          label: 'Orla',
          onPressed: () => onLocationSelected('Orla'),
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

class _ResponsiveFieldGrid extends StatelessWidget {
  const _ResponsiveFieldGrid({required this.columns, required this.children});

  final int columns;
  final List<Widget> children;

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
        mainAxisExtent: 68,
      ),
      itemBuilder: (context, index) => children[index],
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
        value: _formatSliderCurrency(minPrice),
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
              '${_formatSliderCurrency(values.start.round())} - ${_formatSliderCurrency(values.end.round())}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: DSColors.onSurfaceVariant,
              ),
            ),
            RangeSlider(
              min: minPrice.toDouble(),
              max: maxPrice.toDouble(),
              values: values,
              labels: RangeLabels(
                _formatSliderCurrency(values.start.round()),
                _formatSliderCurrency(values.end.round()),
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
              "* A faixa apresenta o imóvel mais acessível ao mais caro que possuímos.",
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

String _formatSliderCurrency(int price) {
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

class _FeaturedPropertiesSection extends StatelessWidget {
  const _FeaturedPropertiesSection({
    required this.properties,
    required this.onSimilarSearch,
  });

  final List<FeaturedPropertyEntity> properties;
  final ValueChanged<FeaturedPropertyEntity> onSimilarSearch;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Destaques', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: DSSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 1040
                ? 3
                : constraints.maxWidth >= 700
                ? 2
                : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: properties.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: DSSpacing.md,
                crossAxisSpacing: DSSpacing.md,
                mainAxisExtent: 470,
              ),
              itemBuilder: (context, index) {
                final property = properties[index];
                return _FeaturedPropertyCard(
                  property: property,
                  onSimilarSearch: () => onSimilarSearch(property),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _FeaturedPropertyCard extends StatelessWidget {
  const _FeaturedPropertyCard({
    required this.property,
    required this.onSimilarSearch,
  });

  final FeaturedPropertyEntity property;
  final VoidCallback onSimilarSearch;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: DSColors.surfaceContainer,
        borderRadius: DSRadius.md,
        border: Border.all(color: DSColors.outline),
      ),
      child: ClipRRect(
        borderRadius: DSRadius.md,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: property.coverUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    ColoredBox(color: DSColors.surfaceContainerHigh),
                errorWidget: (context, url, error) => const ColoredBox(
                  color: DSColors.surfaceContainerHigh,
                  child: Icon(Icons.home_work_outlined),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(DSSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      property.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: DSSpacing.xs),
                    Text(
                      '${property.neighborhood}, ${property.city}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: DSColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: DSSpacing.sm),
                    Wrap(
                      spacing: DSSpacing.xs,
                      runSpacing: DSSpacing.xs,
                      children: <Widget>[
                        _FactChip(label: '${property.areaM2} m2'),
                        if (property.bedrooms != null)
                          _FactChip(label: '${property.bedrooms} quartos'),
                        _FactChip(label: '${property.bathrooms} banheiros'),
                        _FactChip(label: '${property.garageSpaces} vagas'),
                        _FactChip(label: _formatPropertyAge(property)),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      _formatPrice(property.price),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: DSColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: DSSpacing.sm),
                    OutlinedButton.icon(
                      onPressed: onSimilarSearch,
                      icon: const Icon(Icons.tune),
                      label: const Text('Buscar similares'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(int price) {
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

  String _formatPropertyAge(FeaturedPropertyEntity property) {
    if (property.propertyAgeYears <= 1) return 'Lançamento';
    return '${property.propertyAgeYears} anos';
  }
}

class _FactChip extends StatelessWidget {
  const _FactChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      backgroundColor: DSColors.surfaceContainerHigh,
      side: const BorderSide(color: DSColors.outline),
      shape: const RoundedRectangleBorder(borderRadius: DSRadius.sm),
    );
  }
}

class _VideoSection extends StatelessWidget {
  const _VideoSection({required this.content, required this.onPressed});

  final HomeBrandContentEntity? content;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final videoUrl = content?.videoUrl ?? '';
    final videoTitle = content?.videoTitle ?? 'Video da Seletta';
    final embedUrl = _toYoutubeEmbedUrl(videoUrl);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: DSColors.surfaceContainer,
        borderRadius: DSRadius.lg,
        border: Border.all(color: DSColors.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(videoTitle, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: DSSpacing.sm),
            Text(
              'Conheca nossa forma de apresentar oportunidades e acompanhar cada decisao.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: DSColors.onSurfaceVariant),
            ),
            const SizedBox(height: DSSpacing.md),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: DSRadius.md,
                child: ColoredBox(
                  color: DSColors.surfaceContainerHigh,
                  child: YoutubeEmbed(
                    embedUrl: embedUrl,
                    title: videoTitle,
                    fallback: _VideoFallback(
                      thumbnailUrl: content?.videoThumbnailUrl ?? '',
                      onPressed: onPressed,
                      enabled: videoUrl.isNotEmpty,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _toYoutubeEmbedUrl(String url) {
    final videoId = _extractYoutubeVideoId(url);
    if (videoId == null) return '';
    return 'https://www.youtube.com/embed/$videoId?rel=0&modestbranding=1';
  }

  String? _extractYoutubeVideoId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    if (uri.host.contains('youtu.be') && uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.first;
    }

    if (uri.host.contains('youtube.com')) {
      final videoId = uri.queryParameters['v'];
      if (videoId != null && videoId.isNotEmpty) return videoId;

      final embedIndex = uri.pathSegments.indexOf('embed');
      if (embedIndex != -1 && uri.pathSegments.length > embedIndex + 1) {
        return uri.pathSegments[embedIndex + 1];
      }
    }

    return null;
  }
}

class _VideoFallback extends StatelessWidget {
  const _VideoFallback({
    required this.thumbnailUrl,
    required this.onPressed,
    required this.enabled,
  });

  final String thumbnailUrl;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        if (thumbnailUrl.isNotEmpty)
          CachedNetworkImage(
            imageUrl: thumbnailUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                const ColoredBox(color: DSColors.surfaceContainerHigh),
            errorWidget: (context, url, error) =>
                const ColoredBox(color: DSColors.surfaceContainerHigh),
          )
        else
          const ColoredBox(color: DSColors.surfaceContainerHigh),
        ColoredBox(color: DSColors.surface.withValues(alpha: 0.34)),
        Center(
          child: FilledButton.icon(
            onPressed: enabled ? onPressed : null,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Assistir no YouTube'),
          ),
        ),
      ],
    );
  }
}

class _BrandCardsSection extends StatelessWidget {
  const _BrandCardsSection({
    required this.contactKey,
    required this.aboutKey,
    required this.missionKey,
    required this.content,
  });

  final GlobalKey contactKey;
  final GlobalKey aboutKey;
  final GlobalKey missionKey;
  final HomeBrandContentEntity? content;

  @override
  Widget build(BuildContext context) {
    final contact = content?.contact;
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 860 ? 3 : 1;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: columns,
          mainAxisSpacing: DSSpacing.md,
          crossAxisSpacing: DSSpacing.md,
          childAspectRatio: columns == 1 ? 2.4 : 1.18,
          children: <Widget>[
            _BrandInfoCard(
              key: contactKey,
              title: 'Contatos',
              body:
                  '${contact?.phone ?? ''}\n${contact?.whatsapp ?? ''}\n${contact?.email ?? ''}',
            ),
            _BrandInfoCard(
              key: aboutKey,
              title: 'Sobre nos',
              body:
                  content?.about ??
                  'Curadoria imobiliaria para clientes que valorizam contexto, criterio e clareza.',
            ),
            _BrandInfoCard(
              key: missionKey,
              title: 'Missao',
              body:
                  content?.mission ??
                  'Conectar pessoas a imoveis com uma experiencia humana e objetiva.',
            ),
          ],
        );
      },
    );
  }
}

class _BrandInfoCard extends StatelessWidget {
  const _BrandInfoCard({super.key, required this.title, required this.body});

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
