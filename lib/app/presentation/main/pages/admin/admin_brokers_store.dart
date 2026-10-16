import 'package:imobiliaria/app/domain/admin/entities/admin_broker_entity.dart';
import 'package:legend_core/legend_core.dart';

class AdminBrokersStore extends Store {
  final AppState state = AppState();
  List<AdminBrokerEntity> brokers = const <AdminBrokerEntity>[];
  String? _errorMessage;

  void setLoading() {
    _errorMessage = null;
    state.updateState(newState: AppStateEnum.isLoading);
  }

  void setBrokers(List<AdminBrokerEntity> brokers) {
    this.brokers = brokers;
    _errorMessage = null;
    state.updateState(newState: AppStateEnum.hasSuccess);
  }

  void setError(String message) {
    _errorMessage = message;
    state.updateState(newState: AppStateEnum.hasError);
  }

  String? get errorMessage => _errorMessage;
}
