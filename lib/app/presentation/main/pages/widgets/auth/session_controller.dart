import 'package:imobiliaria/app/domain/users/entities/authenticated_user_entity.dart';
import 'package:imobiliaria/app/domain/users/session_store.dart';
import 'package:imobiliaria/app/domain/users/usecases/get_current_user_session_use_case.dart';
import 'package:imobiliaria/app/domain/users/usecases/logout_use_case.dart';
import 'package:imobiliaria/app/presentation/main/main_routes.dart';
import 'package:legend_core/legend_core.dart';

class SessionController extends Controller {
  SessionController({
    required this.store,
    required this.getCurrentUserSession,
    required this.logoutUseCase,
    required AppNavigator navigator,
  }) : _navigator = navigator;

  final SessionStore store;
  final GetCurrentUserSessionUseCase getCurrentUserSession;
  final LogoutUseCase logoutUseCase;
  final AppNavigator _navigator;
  Future<void> initialize() async {
    if (store.initialized) return;
    store.initialized = true;
    store.setLoading();

    final result = await getCurrentUserSession.call();
    result.getResult(
      onSuccess: (user) {
        if (user == null) {
          store.clearSession();
        } else {
          store.setSession(user);
        }
      },
      onError: (_) => store.clearSession(),
    );
  }

  void setSession(AuthenticatedUserEntity user) {
    store.setSession(user);
  }

  void clearSession() {
    store.clearSession();
  }

  Future<String?> logout() async {
    final currentUser = store.user;
    store.setLoading();
    final result = await logoutUseCase.call();
    String? errorMessage;
    result.getResult(
      onSuccess: (_) {
        store.clearSession();
        _navigator.pushNamedAndRemoveUntil(MainRoutes.home, (route) => false);
      },
      onError: (error) {
        errorMessage = error.message;
        if (currentUser != null) store.setSession(currentUser);
      },
    );
    return errorMessage;
  }
}
