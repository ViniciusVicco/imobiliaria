import 'package:imobiliaria/app/data/property_segments/datasources/property_segments_datasource.dart';
import 'package:imobiliaria/app/data/property_segments/repositories/property_segments_repository.dart';
import 'package:imobiliaria/app/domain/property_segments/usecases/resolve_property_segment_route_use_case.dart';
import 'package:imobiliaria/app/presentation/main/main_module.dart';
import 'package:imobiliaria/app/presentation/main/pages/property_segments/property_segments_home_controller.dart';
import 'package:imobiliaria/app/presentation/main/pages/property_segments/property_segments_home_store.dart';
import 'package:legend_core/legend_core.dart';

class PropertySegmentsModuleInjector extends ModuleInjector<MainModule> {
  @override
  void controllers() {
    registerFactory(
      () => PropertySegmentsHomeController(
        store: get<PropertySegmentsHomeStore>(),
        resolveSegmentRoute: get<ResolvePropertySegmentRouteUseCase>(),
        navigator: get<AppNavigator>(),
      ),
    );
  }

  @override
  void core() {
    registerSingleton<AppNavigator>(Module.get<MainModule>().navigator);
  }

  @override
  void stores() {
    registerSingleton(PropertySegmentsHomeStore());
  }

  @override
  void datasources() {
    registerFactory(() => PropertySegmentsDatasource());
  }

  @override
  void repositories() {
    registerFactory(
      () => PropertySegmentsRepository(
        datasource: get<PropertySegmentsDatasource>(),
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
  }
}
