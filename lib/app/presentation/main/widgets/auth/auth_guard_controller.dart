import 'package:imobiliaria/app/domain/users/entities/authenticated_user_entity.dart';
import 'package:imobiliaria/app/domain/users/entities/protected_route_access_entity.dart';
import 'package:imobiliaria/app/domain/users/session_store.dart';
import 'package:imobiliaria/app/domain/users/usecases/get_current_user_session_use_case.dart';
import 'package:imobiliaria/app/domain/users/usecases/resolve_protected_route_access_use_case.dart';
import 'package:imobiliaria/app/presentation/main/widgets/auth/auth_guard_store.dart';
import 'package:legend_core/legend_core.dart';

class AuthGuardController extends Controller {
  AuthGuardController({
    required this.store,
    required this.getCurrentUserSession,
    required this.resolveProtectedRouteAccess,
    required this.sessionStore,
    required AppNavigator navigator,
  }) : _navigator = navigator;

  final AuthGuardStore store;
  final GetCurrentUserSessionUseCase getCurrentUserSession;
  final ResolveProtectedRouteAccessUseCase resolveProtectedRouteAccess;
  final SessionStore sessionStore;
  final AppNavigator _navigator;

  Future<void> ensureAccess({
    required UserRole requiredRole,
    required String requestedRoute,
  }) async {
    store.setLoading();
    final result = await getCurrentUserSession.call();

    result.getResult(
      onSuccess: (user) {
        final access = resolveProtectedRouteAccess.call(
          user: user,
          requiredRole: requiredRole,
          requestedRoute: requestedRoute,
        );

        if (access.canAccess && access.user != null) {
          sessionStore.setSession(access.user!);
          store.setAllowed(access.user!);
          return;
        }

        final redirectRoute = access.redirectRoute;
        if (access.status == ProtectedRouteAccessStatus.redirect &&
            redirectRoute != null) {
          _navigator.pushReplacementNamed(redirectRoute);
          return;
        }

        sessionStore.clearSession();
        store.setBlocked(access.message ?? 'Acesso bloqueado.');
      },
      onError: (error) {
        sessionStore.clearSession();
        store.setBlocked(error.message);
      },
    );
  }
}
