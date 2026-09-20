import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/property_search_filters_entity.dart';
import 'package:imobiliaria/app/presentation/main/main_module.dart';
import 'package:imobiliaria/app/presentation/main/pages/search/property_search_controller.dart';
import 'package:legend_core/legend_core.dart';

import 'widgets/stock_error_state.dart';
import 'widgets/stock_filter_panel.dart';
import 'widgets/stock_loading_state.dart';
import 'widgets/stock_results.dart';

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
            return const StockLoadingState();
          }
          if (state == AppStateEnum.hasError) {
            return StockErrorState(
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
                final content = ValueListenableBuilder<bool>(
                  valueListenable: controller.store.loadingMore,
                  builder: (context, isLoadingMore, child) => StockResults(
                    result: controller.store.result,
                    appliedFilters: controller.store.appliedFilters,
                    errorMessage: controller.store.errorMessage,
                    canLoadMore: controller.store.canLoadMore,
                    isLoadingMore: isLoadingMore,
                    onLoadMore: controller.loadMore,
                    onOpenFilters: isDesktop ? null : _openMobileFilters,
                  ),
                );

                if (!isDesktop) return content;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: 340,
                      height:
                          MediaQuery.sizeOf(context).height -
                          kToolbarHeight -
                          (DSSpacing.md * 2),
                      child: SingleChildScrollView(
                        child: StockFilterPanel(
                          filters: controller.store.draftFilters,
                          result: controller.store.result,
                          queryController: _queryController,
                          blockOrNeighborhoodController:
                              _blockOrNeighborhoodController,
                          onFiltersChanged: controller.updateDraftFilters,
                          onSegmentChanged: controller.updateDraftSegment,
                          onSubmit: controller.applyFilters,
                          onClear: controller.clearFilters,
                        ),
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
          child: StockFilterPanel(
            filters: controller.store.draftFilters,
            result: controller.store.result,
            queryController: _queryController,
            blockOrNeighborhoodController: _blockOrNeighborhoodController,
            onFiltersChanged: controller.updateDraftFilters,
            onSegmentChanged: controller.updateDraftSegment,
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
