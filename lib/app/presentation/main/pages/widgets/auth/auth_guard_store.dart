import 'package:imobiliaria/app/domain/users/entities/authenticated_user_entity.dart';
import 'package:legend_core/legend_core.dart';

class AuthGuardStore extends Store {
  final AppState state = AppState();
  AuthenticatedUserEntity? user;
  String? message;

  void setLoading() {
    message = null;
    state.updateState(newState: AppStateEnum.isLoading);
  }

  void setAllowed(AuthenticatedUserEntity user) {
    this.user = user;
    message = null;
    state.updateState(newState: AppStateEnum.hasSuccess);
  }

  void setBlocked(String message) {
    this.message = message;
    state.updateState(newState: AppStateEnum.hasError);
  }
}
