import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/property_search_filters_entity.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/search_property_entity.dart';
import 'applied_filter_chips.dart';
import 'stock_empty_state.dart';
import 'stock_property_card.dart';

class StockResults extends StatelessWidget {
  const StockResults({
    super.key,
    required this.result,
    required this.appliedFilters,
    required this.canLoadMore,
    required this.isLoadingMore,
    required this.onLoadMore,
    this.errorMessage,
    this.onOpenFilters,
    this.onPropertyPressed,
    this.filters,
  });

  final PropertySearchResultEntity? result;
  final PropertySearchFiltersEntity appliedFilters;
  final bool canLoadMore;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;
  final String? errorMessage;
  final VoidCallback? onOpenFilters;
  final ValueChanged<String>? onPropertyPressed;
  final Widget? filters;

  @override
  Widget build(BuildContext context) {
    final items = result?.items ?? const <SearchPropertyEntity>[];

    return CustomScrollView(
      slivers: <Widget>[
        if (filters != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: DSSpacing.lg),
              child: filters,
            ),
          ),
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
              AppliedFilterChips(filters: appliedFilters),
              if (errorMessage != null) ...<Widget>[
                const SizedBox(height: DSSpacing.sm),
                Text(
                  errorMessage!,
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
            child: StockEmptyState(),
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
                  (context, index) => StockPropertyCard(
                    property: items[index],
                    onPressed: onPropertyPressed == null
                        ? null
                        : () => onPropertyPressed!(items[index].id),
                  ),
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
          if (canLoadMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: DSSpacing.xl),
                child: Center(
                  child: FilledButton.icon(
                    onPressed: isLoadingMore ? null : onLoadMore,
                    icon: isLoadingMore
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.expand_more),
                    label: Text(
                      isLoadingMore ? 'Carregando...' : 'Carregar mais',
                    ),
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
