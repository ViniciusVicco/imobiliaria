import 'package:imobiliaria/app/domain/property_segments/entities/featured_property_entity.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/home_brand_content_entity.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/property_search_filters_entity.dart';
import 'package:imobiliaria/app/domain/users/entities/authenticated_user_entity.dart';
import 'package:legend_core/legend_core.dart';

class PropertySegmentsHomeStore extends Store {
  final AppState state = AppState();
  PropertySearchFiltersEntity filters = const PropertySearchFiltersEntity();
  List<FeaturedPropertyEntity> featuredProperties =
      const <FeaturedPropertyEntity>[];
  HomeBrandContentEntity? brandContent;
  AuthenticatedUserEntity? authenticatedUser;
  String? _errorMessage;

  void setLoading() {
    _errorMessage = null;
    state.updateState(newState: AppStateEnum.isLoading);
  }

  void setSuccess() {
    _errorMessage = null;
    state.updateState(newState: AppStateEnum.hasSuccess);
  }

  void setHomeContent({
    required List<FeaturedPropertyEntity> featuredProperties,
    required HomeBrandContentEntity brandContent,
  }) {
    this.featuredProperties = featuredProperties;
    this.brandContent = brandContent;
    setSuccess();
  }

  void setFilters(PropertySearchFiltersEntity filters) {
    this.filters = filters;
    state.updateState(newState: state.value);
  }

  void setAuthenticatedUser(AuthenticatedUserEntity? user) {
    authenticatedUser = user;
    state.updateState(newState: state.value);
  }

  void setError(String message) {
    _errorMessage = message;
    state.updateState(newState: AppStateEnum.hasError);
  }

  String? consumeErrorMessage() {
    final message = _errorMessage;
    _errorMessage = null;
    return message;
  }
}
