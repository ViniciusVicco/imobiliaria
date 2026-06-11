import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/search_property_entity.dart';
import 'package:imobiliaria/app/presentation/main/main_module.dart';
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
  Map<String, String> get _queryParameters =>
      widget.routeData?.queryParameters ?? const <String, String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.search(_queryParameters);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Busca de imoveis')),
      body: ValueListenableBuilder<AppStateEnum>(
        valueListenable: controller.store.state,
        builder: (context, state, child) {
          return DSPageLayoutContainer(
            padding: const EdgeInsets.all(DSSpacing.md),
            child: switch (state) {
              AppStateEnum.isLoading => const _SearchLoadingState(),
              AppStateEnum.hasError => _SearchErrorState(
                message:
                    controller.store.errorMessage ??
                    'Nao foi possivel carregar os resultados.',
                onRetry: controller.retry,
              ),
              AppStateEnum.hasSuccess => _SearchSuccessState(
                result: controller.store.result,
                queryParameters: _queryParameters,
              ),
              _ => const _SearchLoadingState(),
            },
          );
        },
      ),
    );
  }
}

class _SearchLoadingState extends StatelessWidget {
  const _SearchLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _SearchErrorState extends StatelessWidget {
  const _SearchErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: DSColors.surfaceContainer,
          borderRadius: DSRadius.md,
          border: Border.all(color: DSColors.outline),
        ),
        child: Padding(
          padding: const EdgeInsets.all(DSSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.error_outline,
                color: DSColors.primary,
                size: 40,
              ),
              const SizedBox(height: DSSpacing.md),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: DSSpacing.md),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchSuccessState extends StatelessWidget {
  const _SearchSuccessState({
    required this.result,
    required this.queryParameters,
  });

  final PropertySearchResultEntity? result;
  final Map<String, String> queryParameters;

  @override
  Widget build(BuildContext context) {
    final searchResult = result;
    final items = searchResult?.items ?? const <SearchPropertyEntity>[];

    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Resultados da busca',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: DSSpacing.xs),
              Text(
                _buildSummary(searchResult),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: DSColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: DSSpacing.md),
              _SearchFilterChips(queryParameters: queryParameters),
              const SizedBox(height: DSSpacing.lg),
            ],
          ),
        ),
        if (items.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: _SearchEmptyState(),
          )
        else
          SliverLayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.crossAxisExtent;
              final columns = width >= 1040
                  ? 3
                  : width >= 700
                  ? 2
                  : 1;

              return SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      _SearchPropertyCard(property: items[index]),
                  childCount: items.length,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: DSSpacing.md,
                  crossAxisSpacing: DSSpacing.md,
                  mainAxisExtent: 456,
                ),
              );
            },
          ),
      ],
    );
  }

  String _buildSummary(PropertySearchResultEntity? result) {
    final total = result?.pagination.total ?? 0;
    if (total == 1) return '1 imovel encontrado em Palmas.';
    return '$total imoveis encontrados em Palmas.';
  }
}

class _SearchFilterChips extends StatelessWidget {
  const _SearchFilterChips({required this.queryParameters});

  final Map<String, String> queryParameters;

  @override
  Widget build(BuildContext context) {
    final entries = queryParameters.entries
        .where((entry) => entry.value.trim().isNotEmpty)
        .toList();

    if (entries.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: DSSpacing.sm,
      runSpacing: DSSpacing.sm,
      children: entries
          .map((entry) => Chip(label: Text('${entry.key}: ${entry.value}')))
          .toList(),
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: DSColors.surfaceContainer,
          borderRadius: DSRadius.md,
          border: Border.all(color: DSColors.outline),
        ),
        child: Padding(
          padding: const EdgeInsets.all(DSSpacing.lg),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.search_off, color: DSColors.primary),
              const SizedBox(width: DSSpacing.sm),
              Flexible(
                child: Text(
                  'Nenhum imovel encontrado com esses filtros.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchPropertyCard extends StatelessWidget {
  const _SearchPropertyCard({required this.property});

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
                    _PropertyLocationText(property: property),
                    const SizedBox(height: DSSpacing.md),
                    _PropertyFacts(property: property),
                    const SizedBox(height: DSSpacing.xs),
                    Text(
                      _formatPrice(property.price),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: DSColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: DSSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(BootstrapIcons.house_door),
                        label: const Text('Ver imovel'),
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

class _PropertyLocationText extends StatelessWidget {
  const _PropertyLocationText({required this.property});

  final SearchPropertyEntity property;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Icon(
          Icons.location_on_outlined,
          size: 17,
          color: DSColors.onSurfaceVariant,
        ),
        const SizedBox(width: DSSpacing.xxs),
        Expanded(
          child: Text(
            _formatPropertyLocation(property),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: DSColors.onSurfaceVariant,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _PropertyFacts extends StatelessWidget {
  const _PropertyFacts({required this.property});

  final SearchPropertyEntity property;

  @override
  Widget build(BuildContext context) {
    final facts = <_PropertyFact>[
      _PropertyFact(
        icon: Icons.square_foot_outlined,
        label: '${property.areaM2} m2',
      ),
      if (property.bedrooms != null)
        _PropertyFact(
          icon: Icons.bed_outlined,
          label: '${property.bedrooms} quartos',
        ),
      _PropertyFact(
        icon: Icons.bathtub_outlined,
        label: '${property.bathrooms} banheiros',
      ),
      _PropertyFact(
        icon: Icons.directions_car_outlined,
        label: '${property.garageSpaces} vagas',
      ),
      _PropertyFact(
        icon: Icons.calendar_month_outlined,
        label: _formatPropertyAge(property),
      ),
    ];

    return Wrap(
      spacing: DSSpacing.md,
      runSpacing: DSSpacing.sm,
      children: facts
          .map((fact) => _PropertyFactItem(icon: fact.icon, label: fact.label))
          .toList(),
    );
  }

  String _formatPropertyAge(SearchPropertyEntity property) {
    if (property.propertyAgeYears <= 1) return 'Lancamento';
    return '${property.propertyAgeYears} anos';
  }
}

class _PropertyFact {
  const _PropertyFact({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class _PropertyFactItem extends StatelessWidget {
  const _PropertyFactItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 16, color: DSColors.onSurfaceVariant),
        const SizedBox(width: DSSpacing.xxs),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: DSColors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

String _formatPropertyLocation(SearchPropertyEntity property) {
  final locationParts = <String>[
    if (property.subNeighborhood.trim().isNotEmpty)
      property.subNeighborhood.trim(),
    property.neighborhood.trim(),
    property.city.trim(),
  ].where((part) => part.isNotEmpty).toList();

  return locationParts.join(' - ');
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
