import 'package:imobiliaria/app/domain/users/entities/authenticated_user_entity.dart';
import 'package:imobiliaria/app/domain/users/usecases/get_current_user_session_use_case.dart';
import 'package:imobiliaria/app/domain/users/usecases/login_with_email_use_case.dart';
import 'package:imobiliaria/app/presentation/authentication/pages/login/login_store.dart';
import 'package:imobiliaria/app/presentation/main/main_routes.dart';
import 'package:legend_core/legend_core.dart';

class LoginController extends Controller {
  LoginController({
    required this.store,
    required this.loginWithEmail,
    required this.getCurrentUserSession,
    required AppNavigator navigator,
  }) : _navigator = navigator;

  final LoginStore store;
  final LoginWithEmailUseCase loginWithEmail;
  final GetCurrentUserSessionUseCase getCurrentUserSession;
  final AppNavigator _navigator;

  Future<void> resumeValidSession({String? redirectRoute}) async {
    store.setLoading();
    final result = await getCurrentUserSession.call();

    result.getResult(
      onSuccess: (user) {
        if (user == null) {
          store.setIdle();
          return;
        }

        store.setSuccess();
        _navigator.pushReplacementNamed(
          _resolveDestination(user: user, redirectRoute: redirectRoute),
        );
      },
      onError: (_) => store.setIdle(),
    );
  }

  Future<void> submit({
    required String email,
    required String password,
    String? redirectRoute,
  }) async {
    if (email.trim().isEmpty || password.isEmpty) {
      store.setError('Informe email e senha.');
      return;
    }

    store.setLoading();
    final result = await loginWithEmail.call(email: email, password: password);

    result.getResult(
      onSuccess: (user) {
        store.setSuccess();
        _navigator.pushReplacementNamed(
          _resolveDestination(user: user, redirectRoute: redirectRoute),
        );
      },
      onError: (error) => store.setError(error.message),
    );
  }

  String _resolveDestination({
    required AuthenticatedUserEntity user,
    required String? redirectRoute,
  }) {
    if (redirectRoute != null && redirectRoute.trim().isNotEmpty) {
      return redirectRoute;
    }
    if (user.isAdmin) return MainRoutes.admin;
    return MainRoutes.broker;
  }
}
