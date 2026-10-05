import 'package:flutter_test/flutter_test.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/search_property_entity.dart';
import 'package:imobiliaria/app/presentation/main/pages/search/property_search_store.dart';

void main() {
  test('load more appends unique properties and advances pagination', () {
    final store = PropertySearchStore();
    store.setResult(_result(page: 1, ids: const <String>['one', 'two']));

    store.appendResult(_result(page: 2, ids: const <String>['two', 'three']));

    expect(store.result?.items.map((item) => item.id), <String>[
      'one',
      'two',
      'three',
    ]);
    expect(store.result?.pagination.page, 2);
    expect(store.canLoadMore, isFalse);
  });
}

PropertySearchResultEntity _result({
  required int page,
  required List<String> ids,
}) {
  return PropertySearchResultEntity(
    items: ids.map(_property).toList(),
    pagination: PropertySearchPaginationEntity(
      page: page,
      pageSize: 2,
      total: 3,
      totalPages: 2,
    ),
    priceRange: const PropertySearchPriceRangeEntity(min: 300000, max: 900000),
  );
}

SearchPropertyEntity _property(String id) {
  return SearchPropertyEntity(
    id: id,
    title: 'Imovel $id',
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
  );
}
