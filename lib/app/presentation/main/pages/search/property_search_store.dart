import 'package:flutter/foundation.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/property_search_filters_entity.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/search_property_entity.dart';
import 'package:legend_core/legend_core.dart';

class PropertySearchStore extends Store {
  final AppState state = AppState();
  final ValueNotifier<bool> loadingMore = ValueNotifier<bool>(false);

  PropertySearchFiltersEntity draftFilters =
      const PropertySearchFiltersEntity();
  PropertySearchFiltersEntity appliedFilters =
      const PropertySearchFiltersEntity();
  PropertySearchResultEntity? result;
  String? _errorMessage;

  void initializeFilters(PropertySearchFiltersEntity filters) {
    draftFilters = filters;
    appliedFilters = filters;
  }

  void setDraftFilters(PropertySearchFiltersEntity filters) {
    draftFilters = filters;
    state.updateState(newState: AppStateEnum.hasSuccess);
  }

  void setLoading() {
    _errorMessage = null;
    state.updateState(newState: AppStateEnum.isLoading);
  }

  void setResult(PropertySearchResultEntity result) {
    this.result = result;
    _errorMessage = null;
    state.updateState(newState: AppStateEnum.hasSuccess);
  }

  void appendResult(PropertySearchResultEntity nextResult) {
    final current = result;
    if (current == null) {
      setResult(nextResult);
      return;
    }

    final itemsById = <String, SearchPropertyEntity>{
      for (final item in current.items) item.id: item,
      for (final item in nextResult.items) item.id: item,
    };

    result = PropertySearchResultEntity(
      items: itemsById.values.toList(),
      pagination: nextResult.pagination,
      priceRange: nextResult.priceRange,
    );
    _errorMessage = null;
    state.updateState(newState: AppStateEnum.hasSuccess);
  }

  void setError(String message) {
    _errorMessage = message;
    state.updateState(newState: AppStateEnum.hasError);
  }

  void setLoadMoreError(String message) {
    _errorMessage = message;
    state.updateState(newState: AppStateEnum.hasSuccess);
  }

  String? get errorMessage => _errorMessage;

  bool get canLoadMore {
    final pagination = result?.pagination;
    return pagination != null && pagination.page < pagination.totalPages;
  }
}
