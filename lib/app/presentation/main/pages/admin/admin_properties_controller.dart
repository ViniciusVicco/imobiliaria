import 'package:imobiliaria/app/domain/broker/entities/broker_property_entity.dart';
import 'package:imobiliaria/app/domain/broker/usecases/create_admin_property_use_case.dart';
import 'package:imobiliaria/app/domain/broker/usecases/get_admin_properties_use_case.dart';
import 'package:imobiliaria/app/domain/broker/usecases/save_admin_property_use_case.dart';
import 'package:imobiliaria/app/domain/broker/usecases/update_admin_property_status_use_case.dart';
import 'package:imobiliaria/app/domain/media/usecases/get_property_media_file_use_case.dart';
import 'package:imobiliaria/app/domain/broker/usecases/approve_admin_property_use_case.dart';
import 'package:imobiliaria/app/domain/broker/usecases/reject_admin_property_use_case.dart';
import 'package:imobiliaria/app/domain/admin/usecases/get_admin_notifications_use_case.dart';
import 'package:imobiliaria/app/domain/admin/usecases/mark_admin_notification_read_use_case.dart';
import 'package:imobiliaria/app/presentation/main/main_routes.dart';
import 'package:imobiliaria/app/presentation/main/pages/admin/admin_properties_store.dart';
import 'package:legend_core/legend_core.dart';
import 'dart:typed_data';

class AdminPropertiesController extends Controller {
  AdminPropertiesController({
    required this.store,
    required this.getAdminProperties,
    required this.getPropertyMediaFile,
    required this.createAdminProperty,
    required this.saveAdminProperty,
    required this.updateAdminPropertyStatus,
    required this.navigator,
    required this.approveAdminProperty,
    required this.rejectAdminProperty,
    required this.getAdminNotifications,
    required this.markAdminNotificationRead,
  });

  final AdminPropertiesStore store;
  final GetAdminPropertiesUseCase getAdminProperties;
  final GetPropertyMediaFileUseCase getPropertyMediaFile;
  final CreateAdminPropertyUseCase createAdminProperty;
  final SaveAdminPropertyUseCase saveAdminProperty;
  final UpdateAdminPropertyStatusUseCase updateAdminPropertyStatus;
  final AppNavigator navigator;
  final ApproveAdminPropertyUseCase approveAdminProperty;
  final RejectAdminPropertyUseCase rejectAdminProperty;
  final GetAdminNotificationsUseCase getAdminNotifications;
  final MarkAdminNotificationReadUseCase markAdminNotificationRead;

  Future<void> loadProperties({
    String? status,
    String? query,
    bool? featured,
  }) async {
    store.setFilters(status: status, query: query, featured: featured);
    store.setLoading();

    final result = await getAdminProperties.call(
      status: store.selectedStatus,
      query: store.query,
      featured: store.featured,
    );
    result.getResult(
      onSuccess: (data) => store.setProperties(data.items),
      onError: (error) => store.setError(error.message),
    );
    final notifications = await getAdminNotifications.call();
    notifications.getResult(
      onSuccess: (data) => store.setUnreadNotifications(data.unreadCount),
      onError: (_) {},
    );
  }

  Future<bool> approve(String id) async {
    store.setLoading();
    final result = await approveAdminProperty.call(id);
    var ok = false;
    result.getResult(
      onSuccess: (_) => ok = true,
      onError: (error) => store.setError(error.message),
    );
    if (ok) await loadProperties(status: store.selectedStatus);
    return ok;
  }

  Future<bool> reject({required String id, String? note}) async {
    store.setLoading();
    final result = await rejectAdminProperty.call(id: id, note: note);
    var ok = false;
    result.getResult(
      onSuccess: (_) => ok = true,
      onError: (error) => store.setError(error.message),
    );
    if (ok) await loadProperties(status: store.selectedStatus);
    return ok;
  }

  Future<void> markNotificationRead(String id) async {
    await markAdminNotificationRead.call(id);
    await loadProperties(status: store.selectedStatus);
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
    if (replace) {
      navigator.pushReplacementNamed(MainRoutes.adminPropertyNew);
    } else {
      navigator.pushNamed(MainRoutes.adminPropertyNew);
    }
    return true;
  }

  void openEditForm(BrokerPropertyEntity property) {
    navigator.pushNamed(MainRoutes.adminPropertyEditPath(property.id));
  }

  Future<Uint8List?> loadMediaFile(String mediaId) async {
    final result = await getPropertyMediaFile.call(mediaId: mediaId);
    Uint8List? bytes;
    result.getResult(onSuccess: (data) => bytes = data, onError: (_) {});
    return bytes;
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
