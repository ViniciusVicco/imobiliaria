import 'package:imobiliaria/app/domain/users/entities/authenticated_user_entity.dart';
import 'package:imobiliaria/app/domain/users/entities/protected_route_access_entity.dart';

class ResolveProtectedRouteAccessUseCase {
  static const String _loginRoute = '/login';
  static const String _brokerRoute = '/broker';

  ProtectedRouteAccessEntity call({
    required AuthenticatedUserEntity? user,
    required UserRole requiredRole,
    required String requestedRoute,
  }) {
    if (user == null) {
      return ProtectedRouteAccessEntity(
        status: ProtectedRouteAccessStatus.redirect,
        redirectRoute: Uri(
          path: _loginRoute,
          queryParameters: <String, String>{'redirect': requestedRoute},
        ).toString(),
        message: 'Entre para acessar esta area.',
      );
    }

    if (!user.isActive) {
      return const ProtectedRouteAccessEntity(
        status: ProtectedRouteAccessStatus.blocked,
        message: 'Este usuario esta inativo.',
      );
    }

    if (user.isAdmin) {
      return ProtectedRouteAccessEntity(
        status: ProtectedRouteAccessStatus.allowed,
        user: user,
      );
    }

    if (requiredRole == UserRole.broker && user.isBroker) {
      return ProtectedRouteAccessEntity(
        status: ProtectedRouteAccessStatus.allowed,
        user: user,
      );
    }

    return const ProtectedRouteAccessEntity(
      status: ProtectedRouteAccessStatus.redirect,
      redirectRoute: _brokerRoute,
      message: 'Seu perfil nao pode acessar esta area.',
    );
  }
}
