import 'package:imobiliaria/app/domain/property_segments/entities/property_search_filters_entity.dart';
import 'package:imobiliaria/app/domain/property_segments/usecases/search_published_properties_use_case.dart';
import 'package:imobiliaria/app/presentation/main/main_routes.dart';
import 'package:imobiliaria/app/presentation/main/pages/search/property_search_store.dart';
import 'package:legend_core/legend_core.dart';

class PropertySearchController extends Controller {
  PropertySearchController({
    required this.store,
    required this.searchPublishedProperties,
    required AppNavigator navigator,
  }) : _navigator = navigator;

  final PropertySearchStore store;
  final SearchPublishedPropertiesUseCase searchPublishedProperties;
  final AppNavigator _navigator;
  Map<String, String> _appliedQueryParameters = const <String, String>{};

  Future<void> load(Map<String, String> queryParameters) async {
    final filters = PropertySearchFiltersEntity.fromQueryParameters(
      queryParameters,
    );
    store.initializeFilters(filters);
    _appliedQueryParameters = filters.toQueryParameters();
    await _searchInitial();
  }

  void updateDraftFilters(PropertySearchFiltersEntity filters) {
    store.setDraftFilters(filters);
  }

  void updateDraftSegment(PropertySegment segment) {
    updateDraftFilters(
      store.draftFilters.copyWith(segment: segment, tag: '', tagOnly: false),
    );
  }

  Future<void> applyFilters() {
    return _openCanonicalStock(store.draftFilters);
  }

  Future<void> clearFilters() {
    return _openCanonicalStock(const PropertySearchFiltersEntity());
  }

  Future<void> retry() => _searchInitial();

  Future<void> loadMore() async {
    final current = store.result;
    if (current == null || !store.canLoadMore || store.loadingMore.value) {
      return;
    }

    store.loadingMore.value = true;
    final nextQuery = <String, String>{
      ..._appliedQueryParameters,
      'page': '${current.pagination.page + 1}',
      'pageSize': '${current.pagination.pageSize}',
    };
    final result = await searchPublishedProperties.call(
      queryParameters: nextQuery,
    );

    result.getResult(
      onSuccess: store.appendResult,
      onError: (error) => store.setLoadMoreError(error.message),
    );
    store.loadingMore.value = false;
  }

  Future<void> _searchInitial() async {
    store.setLoading();
    final result = await searchPublishedProperties.call(
      queryParameters: _appliedQueryParameters,
    );

    result.getResult(
      onSuccess: store.setResult,
      onError: (error) => store.setError(error.message),
    );
  }

  Future<void> _openCanonicalStock(PropertySearchFiltersEntity filters) {
    final uri = Uri(
      path: MainRoutes.stock,
      queryParameters: filters.toQueryParameters(),
    );
    return _navigator.pushReplacementNamed(uri.toString());
  }
}
