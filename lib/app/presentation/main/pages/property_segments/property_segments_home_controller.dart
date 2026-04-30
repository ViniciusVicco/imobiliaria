import 'package:imobiliaria/app/domain/property_segments/usecases/resolve_property_segment_route_use_case.dart';
import 'package:imobiliaria/app/presentation/main/pages/property_segments/property_segments_home_store.dart';
import 'package:legend_core/legend_core.dart';

class PropertySegmentsHomeController extends Controller {
  PropertySegmentsHomeController({
    required this.store,
    required this.resolveSegmentRoute,
    required AppNavigator navigator,
  }) : _navigator = navigator;

  final PropertySegmentsHomeStore store;
  final ResolvePropertySegmentRouteUseCase resolveSegmentRoute;
  final AppNavigator _navigator;

  Future<void> onSegmentPressed({required String targetRoute}) async {
    store.setLoading();

    final result = await resolveSegmentRoute.call(targetRoute: targetRoute);

    result.getResult(
      onSuccess: (success) {
        if (success.canNavigate) {
          store.setSuccess();
          _navigator.pushNamed(success.route);
          return;
        }

        store.setError('Nao foi possivel abrir este segmento agora.');
      },
      onError: (error) {
        store.setError(error.message);
      },
    );
  }
}
