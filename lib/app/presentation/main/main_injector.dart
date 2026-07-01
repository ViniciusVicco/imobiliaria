import 'package:dio/dio.dart';
import 'package:imobiliaria/app/data/admin/datasources/admin_brokers_datasource.dart';
import 'package:imobiliaria/app/data/admin/repositories/admin_brokers_repository.dart';
import 'package:imobiliaria/app/data/api/auth_token_interceptor.dart';
import 'package:imobiliaria/app/data/broker/datasources/broker_properties_datasource.dart';
import 'package:imobiliaria/app/data/broker/repositories/broker_properties_repository.dart';
import 'package:imobiliaria/app/data/media/datasources/media_datasource.dart';
import 'package:imobiliaria/app/data/media/repositories/media_repository.dart';
import 'package:imobiliaria/app/data/users/datasources/auth_datasource.dart';
import 'package:imobiliaria/app/data/users/repositories/auth_repository.dart';
import 'package:imobiliaria/app/data/property_segments/datasources/property_segments_datasource.dart';
import 'package:imobiliaria/app/data/property_segments/repositories/property_segments_repository.dart';
import 'package:imobiliaria/app/domain/admin/usecases/create_admin_broker_use_case.dart';
import 'package:imobiliaria/app/domain/admin/usecases/get_admin_brokers_use_case.dart';
import 'package:imobiliaria/app/domain/broker/usecases/create_admin_property_draft_use_case.dart';
import 'package:imobiliaria/app/domain/broker/usecases/create_admin_property_use_case.dart';
import 'package:imobiliaria/app/domain/broker/usecases/create_broker_property_draft_use_case.dart';
import 'package:imobiliaria/app/domain/broker/usecases/get_admin_properties_use_case.dart';
import 'package:imobiliaria/app/domain/broker/usecases/get_admin_property_use_case.dart';
import 'package:imobiliaria/app/domain/broker/usecases/get_broker_property_use_case.dart';
import 'package:imobiliaria/app/domain/broker/usecases/get_broker_properties_use_case.dart';
import 'package:imobiliaria/app/domain/broker/usecases/save_admin_property_use_case.dart';
import 'package:imobiliaria/app/domain/broker/usecases/save_broker_property_use_case.dart';
import 'package:imobiliaria/app/domain/broker/usecases/update_admin_property_status_use_case.dart';
import 'package:imobiliaria/app/domain/broker/usecases/update_broker_property_status_use_case.dart';
import 'package:imobiliaria/app/domain/media/usecases/delete_property_media_use_case.dart';
import 'package:imobiliaria/app/domain/media/usecases/get_property_media_file_use_case.dart';
import 'package:imobiliaria/app/domain/media/usecases/restore_property_media_use_case.dart';
import 'package:imobiliaria/app/domain/media/usecases/set_property_cover_use_case.dart';
import 'package:imobiliaria/app/domain/media/usecases/upload_property_image_use_case.dart';
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
import 'package:imobiliaria/app/presentation/main/pages/admin/admin_brokers_controller.dart';
import 'package:imobiliaria/app/presentation/main/pages/admin/admin_brokers_store.dart';
import 'package:imobiliaria/app/presentation/main/pages/admin/admin_properties_controller.dart';
import 'package:imobiliaria/app/presentation/main/pages/admin/admin_properties_store.dart';
import 'package:imobiliaria/app/presentation/main/pages/broker/broker_properties_controller.dart';
import 'package:imobiliaria/app/presentation/main/pages/broker/broker_properties_store.dart';
import 'package:imobiliaria/app/presentation/main/pages/broker/property_form_controller.dart';
import 'package:imobiliaria/app/presentation/main/pages/broker/property_form_store.dart';
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
        getCurrentUserSession: get<GetCurrentUserSessionUseCase>(),
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
    registerFactory(
      () => AdminBrokersController(
        store: get<AdminBrokersStore>(),
        getAdminBrokers: get<GetAdminBrokersUseCase>(),
        createAdminBroker: get<CreateAdminBrokerUseCase>(),
      ),
    );
    registerFactory(
      () => BrokerPropertiesController(
        store: get<BrokerPropertiesStore>(),
        getBrokerProperties: get<GetBrokerPropertiesUseCase>(),
        createBrokerPropertyDraft: get<CreateBrokerPropertyDraftUseCase>(),
        saveBrokerProperty: get<SaveBrokerPropertyUseCase>(),
        updateBrokerPropertyStatus: get<UpdateBrokerPropertyStatusUseCase>(),
        navigator: get<AppNavigator>(),
      ),
    );
    registerFactory(
      () => PropertyFormController(
        store: get<PropertyFormStore>(),
        getBrokerProperty: get<GetBrokerPropertyUseCase>(),
        getAdminProperty: get<GetAdminPropertyUseCase>(),
        getAdminBrokers: get<GetAdminBrokersUseCase>(),
        saveBrokerProperty: get<SaveBrokerPropertyUseCase>(),
        saveAdminProperty: get<SaveAdminPropertyUseCase>(),
        updateBrokerPropertyStatus: get<UpdateBrokerPropertyStatusUseCase>(),
        updateAdminPropertyStatus: get<UpdateAdminPropertyStatusUseCase>(),
        uploadPropertyImage: get<UploadPropertyImageUseCase>(),
        setPropertyCover: get<SetPropertyCoverUseCase>(),
        getPropertyMediaFile: get<GetPropertyMediaFileUseCase>(),
        deletePropertyMedia: get<DeletePropertyMediaUseCase>(),
        restorePropertyMedia: get<RestorePropertyMediaUseCase>(),
      ),
    );
    registerFactory(
      () => AdminPropertiesController(
        store: get<AdminPropertiesStore>(),
        getAdminProperties: get<GetAdminPropertiesUseCase>(),
        createAdminPropertyDraft: get<CreateAdminPropertyDraftUseCase>(),
        createAdminProperty: get<CreateAdminPropertyUseCase>(),
        saveAdminProperty: get<SaveAdminPropertyUseCase>(),
        updateAdminPropertyStatus: get<UpdateAdminPropertyStatusUseCase>(),
        navigator: get<AppNavigator>(),
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
        interceptors: <Interceptor>[AuthTokenInterceptor()],
      ),
    );
  }

  @override
  void stores() {
    registerSingleton(PropertySegmentsHomeStore());
    registerFactory(() => PropertySearchStore());
    registerFactory(() => AuthGuardStore());
    registerFactory(() => AdminBrokersStore());
    registerFactory(() => BrokerPropertiesStore());
    registerFactory(() => PropertyFormStore());
    registerFactory(() => AdminPropertiesStore());
  }

  @override
  void datasources() {
    registerFactory(
      () => PropertySegmentsDatasource(restClient: get<RestClient>()),
    );
    registerFactory(() => AuthDatasource(restClient: get<RestClient>()));
    registerFactory(
      () => AdminBrokersDatasource(restClient: get<RestClient>()),
    );
    registerFactory(
      () => BrokerPropertiesDatasource(restClient: get<RestClient>()),
    );
    registerFactory(() => MediaDatasource(restClient: get<RestClient>()));
  }

  @override
  void repositories() {
    registerFactory(
      () => PropertySegmentsRepository(
        datasource: get<PropertySegmentsDatasource>(),
      ),
    );
    registerFactory(() => AuthRepository(datasource: get<AuthDatasource>()));
    registerFactory(
      () => AdminBrokersRepository(
        datasource: get<AdminBrokersDatasource>(),
      ),
    );
    registerFactory(
      () => BrokerPropertiesRepository(
        datasource: get<BrokerPropertiesDatasource>(),
      ),
    );
    registerFactory(
      () => MediaRepository(
        datasource: get<MediaDatasource>(),
      ),
    );
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
    registerFactory(
      () => GetAdminBrokersUseCase(
        repository: get<AdminBrokersRepository>(),
      ),
    );
    registerFactory(
      () => CreateAdminBrokerUseCase(
        repository: get<AdminBrokersRepository>(),
      ),
    );
    registerFactory(
      () => GetBrokerPropertiesUseCase(
        repository: get<BrokerPropertiesRepository>(),
      ),
    );
    registerFactory(
      () => GetBrokerPropertyUseCase(
        repository: get<BrokerPropertiesRepository>(),
      ),
    );
    registerFactory(
      () => CreateBrokerPropertyDraftUseCase(
        repository: get<BrokerPropertiesRepository>(),
      ),
    );
    registerFactory(
      () => SaveBrokerPropertyUseCase(
        repository: get<BrokerPropertiesRepository>(),
      ),
    );
    registerFactory(
      () => UpdateBrokerPropertyStatusUseCase(
        repository: get<BrokerPropertiesRepository>(),
      ),
    );
    registerFactory(
      () => GetAdminPropertiesUseCase(
        repository: get<BrokerPropertiesRepository>(),
      ),
    );
    registerFactory(
      () => GetAdminPropertyUseCase(
        repository: get<BrokerPropertiesRepository>(),
      ),
    );
    registerFactory(
      () => CreateAdminPropertyDraftUseCase(
        repository: get<BrokerPropertiesRepository>(),
      ),
    );
    registerFactory(
      () => CreateAdminPropertyUseCase(
        repository: get<BrokerPropertiesRepository>(),
      ),
    );
    registerFactory(
      () => SaveAdminPropertyUseCase(
        repository: get<BrokerPropertiesRepository>(),
      ),
    );
    registerFactory(
      () => UpdateAdminPropertyStatusUseCase(
        repository: get<BrokerPropertiesRepository>(),
      ),
    );
    registerFactory(
      () => UploadPropertyImageUseCase(
        repository: get<MediaRepository>(),
      ),
    );
    registerFactory(
      () => SetPropertyCoverUseCase(
        repository: get<MediaRepository>(),
      ),
    );
    registerFactory(
      () => GetPropertyMediaFileUseCase(
        repository: get<MediaRepository>(),
      ),
    );
    registerFactory(
      () => DeletePropertyMediaUseCase(
        repository: get<MediaRepository>(),
      ),
    );
    registerFactory(
      () => RestorePropertyMediaUseCase(
        repository: get<MediaRepository>(),
      ),
    );
  }
}
