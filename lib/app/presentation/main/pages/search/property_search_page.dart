import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/featured_property_entity.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/property_search_filters_entity.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/search_property_entity.dart';
import 'package:imobiliaria/app/presentation/main/main_module.dart';
import 'package:imobiliaria/app/presentation/main/pages/property_segments/widgets/search/property_search_panel.dart';
import 'package:imobiliaria/app/presentation/main/pages/search/property_search_controller.dart';
import 'package:imobiliaria/app/presentation/main/widgets/property_card_image.dart';
import 'package:legend_core/legend_core.dart';

class PropertySearchPage extends StatefulWidget {
  const PropertySearchPage({super.key, this.routeData});

  final ModuleRouteData? routeData;

  @override
  State<PropertySearchPage> createState() => _PropertySearchPageState();
}

class _PropertySearchPageState
    extends
        StateController<
          MainModule,
          PropertySearchPage,
          PropertySearchController
        > {
  late final TextEditingController _queryController;
  late final TextEditingController _blockOrNeighborhoodController;

  Map<String, String> get _queryParameters =>
      widget.routeData?.queryParameters ?? const <String, String>{};

  @override
  void initState() {
    super.initState();
    final initialFilters = PropertySearchFiltersEntity.fromQueryParameters(
      _queryParameters,
    );
    _queryController = TextEditingController(text: initialFilters.query);
    _blockOrNeighborhoodController = TextEditingController(
      text: initialFilters.blockOrNeighborhood,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.load(_queryParameters);
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
      appBar: AppBar(title: const Text('Imóveis a venda')),
      body: ValueListenableBuilder<AppStateEnum>(
        valueListenable: controller.store.state,
        builder: (context, state, child) {
          if (state == AppStateEnum.isLoading) {
            return const _StockLoadingState();
          }
          if (state == AppStateEnum.hasError) {
            return _StockErrorState(
              message:
                  controller.store.errorMessage ??
                  'Nao foi possivel carregar os imóveis a venda.',
              onRetry: controller.retry,
            );
          }

          return DSPageLayoutContainer(
            padding: const EdgeInsets.all(DSSpacing.md),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 980;
                final content = _StockResults(
                  controller: controller,
                  onOpenFilters: isDesktop ? null : _openMobileFilters,
                );

                if (!isDesktop) return content;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: 340,
                      height: MediaQuery.sizeOf(context).height -
                          kToolbarHeight -
                          (DSSpacing.md * 2),
                      child: SingleChildScrollView(
                        child: _buildFilterPanel(),
                      ),
                    ),
                    const SizedBox(width: DSSpacing.lg),
                    Expanded(child: content),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterPanel({VoidCallback? onSubmit, VoidCallback? onClear}) {
    final result = controller.store.result;
    return PropertySearchPanel(
      filters: controller.store.draftFilters,
      properties: _asFeaturedProperties(result?.items),
      queryController: _queryController,
      blockOrNeighborhoodController: _blockOrNeighborhoodController,
      onFiltersChanged: controller.updateDraftFilters,
      onSegmentChanged: controller.updateDraftSegment,
      onSubmit: onSubmit ?? controller.applyFilters,
      onClear: onClear ?? controller.clearFilters,
      title: 'Filtrar imóveis a venda',
      submitLabel: 'Aplicar filtros',
      allowAll: true,
      vertical: true,
      autoSubmitShortcuts: false,
      priceRangeMin: result?.priceRange.min,
      priceRangeMax: result?.priceRange.max,
    );
  }

  Future<void> _openMobileFilters() {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.92,
        minChildSize: 0.55,
        maxChildSize: 0.96,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(DSSpacing.md),
          child: _buildFilterPanel(
            onSubmit: () {
              Navigator.of(context).pop();
              controller.applyFilters();
            },
            onClear: () {
              Navigator.of(context).pop();
              controller.clearFilters();
            },
          ),
        ),
      ),
    );
  }
}

class _StockResults extends StatelessWidget {
  const _StockResults({required this.controller, this.onOpenFilters});

  final PropertySearchController controller;
  final VoidCallback? onOpenFilters;

  @override
  Widget build(BuildContext context) {
    final store = controller.store;
    final result = store.result;
    final items = result?.items ?? const <SearchPropertyEntity>[];

    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Nossos imóveis a venda',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: DSSpacing.xxs),
                        Text(
                          _buildSummary(result),
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: DSColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  if (onOpenFilters != null)
                    FilledButton.icon(
                      onPressed: onOpenFilters,
                      icon: const Icon(Icons.tune),
                      label: const Text('Filtros'),
                    ),
                ],
              ),
              const SizedBox(height: DSSpacing.md),
              _AppliedFilterChips(filters: store.appliedFilters),
              if (store.errorMessage != null) ...<Widget>[
                const SizedBox(height: DSSpacing.sm),
                Text(
                  store.errorMessage!,
                  style: const TextStyle(color: DSColors.error),
                ),
              ],
              const SizedBox(height: DSSpacing.lg),
            ],
          ),
        ),
        if (items.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: _StockEmptyState(),
          )
        else ...<Widget>[
          SliverLayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.crossAxisExtent;
              final columns = width >= 900
                  ? 3
                  : width >= 600
                  ? 2
                  : 1;

              return SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      _StockPropertyCard(property: items[index]),
                  childCount: items.length,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: DSSpacing.md,
                  crossAxisSpacing: DSSpacing.md,
                  mainAxisExtent: 392,
                ),
              );
            },
          ),
          if (store.canLoadMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: DSSpacing.xl),
                child: Center(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: store.loadingMore,
                    builder: (context, isLoading, child) {
                      return FilledButton.icon(
                        onPressed: isLoading ? null : controller.loadMore,
                        icon: isLoading
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.expand_more),
                        label: Text(
                          isLoading ? 'Carregando...' : 'Carregar mais',
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }

  String _buildSummary(PropertySearchResultEntity? result) {
    final total = result?.pagination.total ?? 0;
    if (total == 1) return '1 imovel publicado em Palmas.';
    return '$total imoveis publicados em Palmas.';
  }
}

class _AppliedFilterChips extends StatelessWidget {
  const _AppliedFilterChips({required this.filters});

  final PropertySearchFiltersEntity filters;

  @override
  Widget build(BuildContext context) {
    final labels = <String>[
      if (filters.segment != PropertySegment.all) filters.segment.label,
      if (filters.propertyType != AnyPropertyType.any)
        filters.propertyType.label,
      if (filters.blockOrNeighborhood.trim().isNotEmpty)
        filters.blockOrNeighborhood.trim(),
      if (filters.tag.trim().isNotEmpty) _tagLabel(filters.tag),
      if (filters.query.trim().isNotEmpty) '"${filters.query.trim()}"',
      if (filters.bedroomsMin != null) '${filters.bedroomsMin}+ quartos',
      if (filters.bathroomsMin != null) '${filters.bathroomsMin}+ banheiros',
      if (filters.garageSpacesMin != null) '${filters.garageSpacesMin}+ vagas',
      if (filters.priceMin != null)
        'A partir de ${_formatPrice(filters.priceMin!)}',
      if (filters.priceMax != null) 'Ate ${_formatPrice(filters.priceMax!)}',
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

class _StockLoadingState extends StatelessWidget {
  const _StockLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _StockErrorState extends StatelessWidget {
  const _StockErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline, color: DSColors.primary, size: 40),
            const SizedBox(height: DSSpacing.md),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: DSSpacing.md),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockEmptyState extends StatelessWidget {
  const _StockEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(DSSpacing.lg),
        child: Text(
          'Nenhum imovel encontrado. Ajuste ou limpe os filtros.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _StockPropertyCard extends StatelessWidget {
  const _StockPropertyCard({required this.property});

  final SearchPropertyEntity property;

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
            PropertyCardImage(coverUrl: property.coverUrl, tags: property.tags),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(DSSpacing.sm),
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
                      _formatPropertyLocation(property),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: DSColors.onSurfaceVariant),
                    ),
                    const Spacer(),
                    _PropertyFacts(property: property),
                    const SizedBox(height: DSSpacing.sm),
                    Text(
                      _formatPrice(property.price),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: DSColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
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
}

class _PropertyFacts extends StatelessWidget {
  const _PropertyFacts({required this.property});

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

String _formatPropertyLocation(SearchPropertyEntity property) {
  return <String>[
    if (property.subNeighborhood.trim().isNotEmpty)
      property.subNeighborhood.trim(),
    property.neighborhood.trim(),
    property.city.trim(),
  ].where((part) => part.isNotEmpty).join(' - ');
}

String _formatPrice(int price) {
  final text = price.toString();
  final buffer = StringBuffer();
  for (var index = 0; index < text.length; index++) {
    final positionFromEnd = text.length - index;
    buffer.write(text[index]);
    if (positionFromEnd > 1 && positionFromEnd % 3 == 1) buffer.write('.');
  }
  return 'R\$ ${buffer.toString()}';
}

String _tagLabel(String tag) {
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
