import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/property_search_filters_entity.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/search_property_entity.dart';
import 'package:imobiliaria/app/presentation/main/pages/search/widgets/stock_filter_panel.dart';
import 'package:imobiliaria/app/presentation/main/pages/search/widgets/stock_results.dart';
import 'package:imobiliaria/app/presentation/main/pages/search/widgets/stock_error_state.dart';

void main() {
  testWidgets('stock cards open their property ID', (tester) async {
    String? opened;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StockResults(
            result: _result,
            appliedFilters: const PropertySearchFiltersEntity(),
            canLoadMore: false,
            isLoadingMore: false,
            onLoadMore: () {},
            onPropertyPressed: (id) => opened = id,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(_result.items.first.title));
    expect(opened, _result.items.first.id);
  });
  testWidgets(
    'filter edits survive rebuild and apply and clear use callbacks',
    (tester) async {
      final query = TextEditingController();
      final neighborhood = TextEditingController();
      addTearDown(query.dispose);
      addTearDown(neighborhood.dispose);
      var filters = const PropertySearchFiltersEntity();
      PropertySearchFiltersEntity? submitted;
      var clears = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (context, setState) => StockFilterPanel(
                  filters: filters,
                  result: null,
                  queryController: query,
                  blockOrNeighborhoodController: neighborhood,
                  onFiltersChanged: (value) => setState(() => filters = value),
                  onSegmentChanged: (value) => setState(
                    () => filters = filters.copyWith(segment: value),
                  ),
                  onSubmit: () => submitted = filters,
                  onClear: () {
                    clears++;
                    setState(
                      () => filters = const PropertySearchFiltersEntity(),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Mais filtros'));
      await tester.pumpAndSettle();
      final queryField = find.widgetWithText(TextField, 'Palavra-chave');
      await tester.ensureVisible(queryField);
      await tester.enterText(queryField, 'varanda');
      await tester.pump();
      expect(query.text, 'varanda');
      expect(filters.query, 'varanda');
      await tester.ensureVisible(find.text('Aplicar filtros'));
      await tester.tap(find.text('Aplicar filtros'));
      expect(submitted?.query, 'varanda');
      await tester.ensureVisible(find.text('Limpar filtros'));
      await tester.tap(find.text('Limpar filtros'));
      await tester.pumpAndSettle();
      expect(clears, 1);
      expect(query.text, isEmpty);
      expect(filters.query, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('load more reacts to loading state without losing results', (
    tester,
  ) async {
    var loading = false;
    var loads = 0;
    late StateSetter rebuild;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return StockResults(
                result: _result,
                appliedFilters: const PropertySearchFiltersEntity(),
                canLoadMore: true,
                isLoadingMore: loading,
                onLoadMore: () => loads++,
              );
            },
          ),
        ),
      ),
    );
    await tester.scrollUntilVisible(find.text('Carregar mais'), 200);
    await tester.tap(find.text('Carregar mais'));
    expect(loads, 1);
    rebuild(() => loading = true);
    await tester.pump();
    expect(find.text('Carregando...'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.byWidgetPredicate((widget) => widget is FilledButton),
          )
          .onPressed,
      isNull,
    );
    rebuild(() => loading = false);
    await tester.pumpAndSettle();
    expect(find.text('Carregar mais'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty results open filters and error state retries', (
    tester,
  ) async {
    var opens = 0;
    var retries = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StockResults(
            result: null,
            appliedFilters: const PropertySearchFiltersEntity(),
            canLoadMore: false,
            isLoadingMore: false,
            onLoadMore: () {},
            onOpenFilters: () => opens++,
          ),
        ),
      ),
    );
    expect(
      find.text('Nenhum imovel encontrado. Ajuste ou limpe os filtros.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Filtros'));
    expect(opens, 1);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StockErrorState(
            message: 'Falha simulada',
            onRetry: () => retries++,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Tentar novamente'));
    expect(retries, 1);
  });

  for (final width in [390.0, 800.0, 1440.0]) {
    testWidgets('results fit width $width', (tester) async {
      await tester.binding.setSurfaceSize(Size(width, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StockResults(
              result: _result,
              appliedFilters: const PropertySearchFiltersEntity(),
              canLoadMore: false,
              isLoadingMore: false,
              onLoadMore: () {},
            ),
          ),
        ),
      );
      expect(find.text('Apartamento de teste'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

const _result = PropertySearchResultEntity(
  items: [
    SearchPropertyEntity(
      id: 'one',
      title: 'Apartamento de teste',
      segment: 'residential',
      propertyType: 'Apartamento',
      city: 'Palmas',
      neighborhood: 'Centro',
      subNeighborhood: '',
      coverUrl: '',
      areaM2: 80,
      bedrooms: 2,
      bathrooms: 2,
      garageSpaces: 1,
      propertyAgeYears: 2,
      price: 500000,
    ),
  ],
  pagination: PropertySearchPaginationEntity(
    page: 1,
    pageSize: 1,
    total: 2,
    totalPages: 2,
  ),
  priceRange: PropertySearchPriceRangeEntity(min: 300000, max: 900000),
);
