import 'package:imobiliaria/app/data/users/datasources/auth_datasource.dart';
import 'package:imobiliaria/app/data/users/repositories/auth_repository.dart';
import 'package:imobiliaria/app/domain/users/usecases/login_with_email_use_case.dart';
import 'package:imobiliaria/app/presentation/authentication/authentication_module.dart';
import 'package:imobiliaria/app/presentation/authentication/pages/login/login_controller.dart';
import 'package:imobiliaria/app/presentation/authentication/pages/login/login_store.dart';
import 'package:imobiliaria/app/presentation/main/main_module.dart';
import 'package:legend_core/legend_core.dart';

class AuthenticationInjector extends ModuleInjector<AuthenticationModule> {
  @override
  void controllers() {
    registerFactory(
      () => LoginController(
        store: get<LoginStore>(),
        loginWithEmail: get<LoginWithEmailUseCase>(),
        navigator: get<AppNavigator>(),
      ),
    );
  }

  @override
  void core() {
    registerSingleton<AppNavigator>(Module.get<MainModule>().navigator);
  }

  @override
  void datasources() {
    registerFactory(() => AuthDatasource());
  }

  @override
  void repositories() {
    registerFactory(
      () => AuthRepository(datasource: get<AuthDatasource>()),
    );
  }

  @override
  void stores() {
    registerFactory(() => LoginStore());
  }

  @override
  void usecases() {
    registerFactory(
      () => LoginWithEmailUseCase(repository: get<AuthRepository>()),
    );
  }
}
