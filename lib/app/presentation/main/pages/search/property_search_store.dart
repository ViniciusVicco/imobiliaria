import 'package:imobiliaria/app/domain/property_segments/entities/search_property_entity.dart';
import 'package:legend_core/legend_core.dart';

class PropertySearchStore extends Store {
  final AppState state = AppState();
  PropertySearchResultEntity? result;
  String? _errorMessage;

  void setLoading() {
    _errorMessage = null;
    state.updateState(newState: AppStateEnum.isLoading);
  }

  void setResult(PropertySearchResultEntity result) {
    this.result = result;
    _errorMessage = null;
    state.updateState(newState: AppStateEnum.hasSuccess);
  }

  void setError(String message) {
    _errorMessage = message;
    state.updateState(newState: AppStateEnum.hasError);
  }

  String? get errorMessage => _errorMessage;
}
