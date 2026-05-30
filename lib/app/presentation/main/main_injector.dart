import 'package:dio/dio.dart';
import 'package:imobiliaria/app/data/users/datasources/auth_datasource.dart';
import 'package:imobiliaria/app/data/users/repositories/auth_repository.dart';
import 'package:imobiliaria/app/data/property_segments/datasources/property_segments_datasource.dart';
import 'package:imobiliaria/app/data/property_segments/repositories/property_segments_repository.dart';
import 'package:imobiliaria/app/domain/property_segments/usecases/build_property_search_query_use_case.dart';
import 'package:imobiliaria/app/domain/property_segments/usecases/get_featured_properties_use_case.dart';
import 'package:imobiliaria/app/domain/property_segments/usecases/get_home_brand_content_use_case.dart';
import 'package:imobiliaria/app/domain/property_segments/usecases/resolve_property_segment_route_use_case.dart';
import 'package:imobiliaria/app/domain/property_segments/usecases/search_published_properties_use_case.dart';
import 'package:imobiliaria/app/domain/users/usecases/get_current_user_session_use_case.dart';
import 'package:imobiliaria/app/domain/users/usecases/logout_use_case.dart';
import 'package:imobiliaria/app/domain/users/usecases/resolve_protected_route_access_use_case.dart';
import 'package:imobiliaria/app/domain/users/usecases/watch_current_user_session_use_case.dart';
import 'package:imobiliaria/app/presentation/main/main_module.dart';
import 'package:imobiliaria/app/presentation/main/pages/property_segments/property_segments_home_controller.dart';
import 'package:imobiliaria/app/presentation/main/pages/property_segments/property_segments_home_store.dart';
import 'package:imobiliaria/app/presentation/main/pages/search/property_search_controller.dart';
import 'package:imobiliaria/app/presentation/main/pages/search/property_search_store.dart';
import 'package:imobiliaria/app/presentation/main/widgets/auth/auth_guard_controller.dart';
import 'package:imobiliaria/app/presentation/main/widgets/auth/auth_guard_store.dart';
import 'package:imobiliaria/env/rest_base_enviroment.dart';
import 'package:legend_core/legend_core.dart';

class PropertySegmentsModuleInjector extends ModuleInjector<MainModule> {
  @override
  void controllers() {
    registerFactory(
      () => PropertySegmentsHomeController(
        store: get<PropertySegmentsHomeStore>(),
        resolveSegmentRoute: get<ResolvePropertySegmentRouteUseCase>(),
        buildPropertySearchQuery: get<BuildPropertySearchQueryUseCase>(),
        getFeaturedProperties: get<GetFeaturedPropertiesUseCase>(),
        getHomeBrandContent: get<GetHomeBrandContentUseCase>(),
        navigator: get<AppNavigator>(),
      ),
    );
    registerFactory(
      () => AuthGuardController(
        store: get<AuthGuardStore>(),
        getCurrentUserSession: get<GetCurrentUserSessionUseCase>(),
        resolveProtectedRouteAccess: get<ResolveProtectedRouteAccessUseCase>(),
        navigator: get<AppNavigator>(),
      ),
    );
    registerFactory(
      () => PropertySearchController(
        store: get<PropertySearchStore>(),
        searchPublishedProperties: get<SearchPublishedPropertiesUseCase>(),
      ),
    );
  }

  @override
  void core() {
    registerSingleton<AppNavigator>(Module.get<MainModule>().navigator);
    registerFactory(
      () => RestClient(
        options: BaseOptions(
          baseUrl: RestBaseEnviroment.baseEnv.baseUrl,
          connectTimeout: const Duration(seconds: 2),
          receiveTimeout: const Duration(seconds: 5),
        ),
      ),
    );
  }

  @override
  void stores() {
    registerSingleton(PropertySegmentsHomeStore());
    registerFactory(() => PropertySearchStore());
    registerFactory(() => AuthGuardStore());
  }

  @override
  void datasources() {
    registerFactory(
      () => PropertySegmentsDatasource(restClient: get<RestClient>()),
    );
    registerFactory(() => AuthDatasource());
  }

  @override
  void repositories() {
    registerFactory(
      () => PropertySegmentsRepository(
        datasource: get<PropertySegmentsDatasource>(),
      ),
    );
    registerFactory(() => AuthRepository(datasource: get<AuthDatasource>()));
  }

  @override
  void usecases() {
    registerFactory(
      () => ResolvePropertySegmentRouteUseCase(
        repository: get<PropertySegmentsRepository>(),
      ),
    );
    registerFactory(
      () => BuildPropertySearchQueryUseCase(
        repository: get<PropertySegmentsRepository>(),
      ),
    );
    registerFactory(
      () => GetFeaturedPropertiesUseCase(
        repository: get<PropertySegmentsRepository>(),
      ),
    );
    registerFactory(
      () => GetHomeBrandContentUseCase(
        repository: get<PropertySegmentsRepository>(),
      ),
    );
    registerFactory(
      () => SearchPublishedPropertiesUseCase(
        repository: get<PropertySegmentsRepository>(),
      ),
    );
    registerFactory(() => LogoutUseCase(repository: get<AuthRepository>()));
    registerFactory(
      () => GetCurrentUserSessionUseCase(repository: get<AuthRepository>()),
    );
    registerFactory(
      () => WatchCurrentUserSessionUseCase(repository: get<AuthRepository>()),
    );
    registerFactory(() => ResolveProtectedRouteAccessUseCase());
  }
}
