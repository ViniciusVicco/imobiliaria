import 'package:imobiliaria/app/domain/broker/entities/broker_property_entity.dart';
import 'package:imobiliaria/app/domain/broker/usecases/create_admin_property_draft_use_case.dart';
import 'package:imobiliaria/app/domain/broker/usecases/create_admin_property_use_case.dart';
import 'package:imobiliaria/app/domain/broker/usecases/get_admin_properties_use_case.dart';
import 'package:imobiliaria/app/domain/broker/usecases/save_admin_property_use_case.dart';
import 'package:imobiliaria/app/domain/broker/usecases/update_admin_property_status_use_case.dart';
import 'package:imobiliaria/app/presentation/main/main_routes.dart';
import 'package:imobiliaria/app/presentation/main/pages/admin/admin_properties_store.dart';
import 'package:legend_core/legend_core.dart';

class AdminPropertiesController extends Controller {
  AdminPropertiesController({
    required this.store,
    required this.getAdminProperties,
    required this.createAdminPropertyDraft,
    required this.createAdminProperty,
    required this.saveAdminProperty,
    required this.updateAdminPropertyStatus,
    required this.navigator,
  });

  final AdminPropertiesStore store;
  final GetAdminPropertiesUseCase getAdminProperties;
  final CreateAdminPropertyDraftUseCase createAdminPropertyDraft;
  final CreateAdminPropertyUseCase createAdminProperty;
  final SaveAdminPropertyUseCase saveAdminProperty;
  final UpdateAdminPropertyStatusUseCase updateAdminPropertyStatus;
  final AppNavigator navigator;

  Future<void> loadProperties({String? status, String? query}) async {
    store.setFilters(status: status, query: query);
    store.setLoading();

    final result = await getAdminProperties.call(
      status: store.selectedStatus,
      query: store.query,
    );
    result.getResult(
      onSuccess: (data) => store.setProperties(data.items),
      onError: (error) => store.setError(error.message),
    );
  }

  Future<bool> saveProperty({
    required String id,
    required BrokerPropertyFormEntity property,
  }) async {
    store.setLoading();
    final result = await saveAdminProperty.call(id: id, property: property);

    var wasSaved = false;
    result.getResult(
      onSuccess: (_) {
        wasSaved = true;
      },
      onError: (error) => store.setError(error.message),
    );

    if (wasSaved) await loadProperties();
    return wasSaved;
  }

  Future<bool> createProperty({
    required BrokerPropertyFormEntity property,
  }) async {
    store.setLoading();
    final result = await createAdminProperty.call(property: property);

    var wasCreated = false;
    result.getResult(
      onSuccess: (_) {
        wasCreated = true;
      },
      onError: (error) => store.setError(error.message),
    );

    if (wasCreated) await loadProperties(status: 'published');
    return wasCreated;
  }

  Future<bool> createDraftAndOpenForm({bool replace = false}) async {
    store.setLoading();
    final result = await createAdminPropertyDraft.call();

    var wasCreated = false;
    result.getResult(
      onSuccess: (property) {
        wasCreated = true;
        final route = MainRoutes.adminPropertyEditPath(property.id);
        if (replace) {
          navigator.pushReplacementNamed(route);
        } else {
          navigator.pushNamed(route);
        }
      },
      onError: (error) => store.setError(error.message),
    );

    return wasCreated;
  }

  void openEditForm(BrokerPropertyEntity property) {
    navigator.pushNamed(MainRoutes.adminPropertyEditPath(property.id));
  }

  Future<bool> updateStatus({
    required String id,
    required String status,
  }) async {
    store.setLoading();
    final result = await updateAdminPropertyStatus.call(id: id, status: status);

    var wasUpdated = false;
    result.getResult(
      onSuccess: (_) {
        wasUpdated = true;
      },
      onError: (error) => store.setError(error.message),
    );

    if (wasUpdated) await loadProperties();
    return wasUpdated;
  }
}
