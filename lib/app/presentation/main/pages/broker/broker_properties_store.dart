import 'package:imobiliaria/app/domain/broker/entities/broker_property_entity.dart';
import 'package:legend_core/legend_core.dart';

class BrokerPropertiesStore extends Store {
  final AppState state = AppState();
  List<BrokerPropertyEntity> properties = const <BrokerPropertyEntity>[];
  String selectedStatus = 'published';
  String? _errorMessage;

  void setStatus(String status) {
    selectedStatus = status;
  }

  void setLoading() {
    _errorMessage = null;
    state.updateState(newState: AppStateEnum.isLoading);
  }

  void setProperties(List<BrokerPropertyEntity> properties) {
    this.properties = properties;
    _errorMessage = null;
    state.updateState(newState: AppStateEnum.hasSuccess);
  }

  void setError(String message) {
    _errorMessage = message;
    state.updateState(newState: AppStateEnum.hasError);
  }

  String? get errorMessage => _errorMessage;
}
