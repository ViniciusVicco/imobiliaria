import 'package:legend_core/legend_core.dart';
import 'package:imobiliaria/app/domain/property_segments/usecases/get_property_detail_use_case.dart';
import 'property_resume_store.dart';

class PropertyResumeController extends Controller {
  PropertyResumeController({required this.store, required this.getProperty});
  final PropertyResumeStore store;
  final GetPropertyDetailUseCase getProperty;
  int _request = 0;
  @override
  void dispose() {
    _request++;
    super.dispose();
  }

  Future<void> load(String id) async {
    final request = ++_request;
    store.property = null;
    store.error = null;
    store.unavailable = false;
    store.state.updateState(newState: AppStateEnum.isLoading);
    final result = await getProperty(id);
    if (request != _request) return;
    result.getResult(
      onSuccess: (property) {
        store.property = property;
        store.state.updateState(newState: AppStateEnum.hasSuccess);
      },
      onError: (error) {
        store.error = error.message;
        store.unavailable = error.unavailable;
        store.state.updateState(newState: AppStateEnum.hasError);
      },
    );
  }
}
