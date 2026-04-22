import 'package:imobiliaria/app/domain/property_segments/usecases/test_it_use_case.dart';
import 'package:imobiliaria/app/presentation/main/pages/property_segments/property_segments_home_store.dart';
import 'package:legend_core/legend_core.dart';

class PropertySegmentsHomeController extends Controller {
  PropertySegmentsHomeController({
    required this.store,
    required this.testItUseCase,
    required AppNavigator navigator,
  }) : _navigator = navigator;

  final PropertySegmentsHomeStore store;
  final TestItUseCase testItUseCase;
  final AppNavigator _navigator;

  Future<void> onSegmentPressed({required String targetRoute}) async {
    store.setLoading();

    final result = await testItUseCase.call(targetRoute: targetRoute);

    result.getResult(
      onSuccess: (success) {
        if (success.isWorking) {
          store.setSuccess();
          _navigator.pushNamed(success.route);
          return;
        }

        store.setError('Unexpected segment validation error.');
      },
      onError: (error) {
        store.setError(error.message);
      },
    );
  }
}
