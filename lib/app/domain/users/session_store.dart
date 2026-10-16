import 'package:imobiliaria/app/domain/users/entities/authenticated_user_entity.dart';
import 'package:legend_core/legend_core.dart';

class SessionStore extends Store {
  static final SessionStore instance = SessionStore._();

  SessionStore._();

  final AppState state = AppState();
  AuthenticatedUserEntity? user;
  bool initialized = false;

  bool get hasSession => user != null;

  void setLoading() {
    state.updateState(newState: AppStateEnum.isLoading);
  }

  void setSession(AuthenticatedUserEntity value) {
    user = value;
    state.updateState(newState: AppStateEnum.hasSuccess);
  }

  void clearSession() {
    user = null;
    state.updateState(newState: AppStateEnum.hasSuccess);
  }
}
