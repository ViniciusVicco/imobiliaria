import 'package:imobiliaria/app/presentation/authentication/authentication_injector.dart';
import 'package:imobiliaria/app/presentation/authentication/authentication_routes.dart';
import 'package:imobiliaria/app/presentation/authentication/pages/login/login_page.dart';
import 'package:legend_core/legend_core.dart';

class AuthenticationModule extends Module {
  @override
  String get initialRoute => AuthenticationRoutes.login;

  @override
  ModuleInjector<AuthenticationModule> get injector =>
      AuthenticationInjector();

  @override
  Map<String, RouteBuilder> get routes => <String, RouteBuilder>{
    AuthenticationRoutes.login: (context, arguments) => LoginPage(
      routeData: arguments is ModuleRouteData ? arguments : null,
    ),
  };
}
