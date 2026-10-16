import 'package:imobiliaria/app/domain/broker/entities/broker_property_entity.dart';
import 'package:imobiliaria/app/domain/admin/entities/admin_broker_entity.dart';
import 'package:legend_core/legend_core.dart';

class PropertyFormStore extends Store {
  final AppState state = AppState();
  BrokerPropertyEntity? property;
  List<AdminBrokerEntity> brokers = const <AdminBrokerEntity>[];
  String? _errorMessage;

  void setLoading() {
    _errorMessage = null;
    state.updateState(newState: AppStateEnum.isLoading);
  }

  void setProperty(BrokerPropertyEntity property) {
    this.property = property;
    _errorMessage = null;
    state.updateState(newState: AppStateEnum.hasSuccess);
  }

  void setBrokers(List<AdminBrokerEntity> brokers) {
    this.brokers = brokers;
    state.updateState(newState: state.value);
  }

  void setError(String message) {
    _errorMessage = message;
    state.updateState(newState: AppStateEnum.hasError);
  }

  String? get errorMessage => _errorMessage;
}
