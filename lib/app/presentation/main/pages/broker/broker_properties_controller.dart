import 'package:imobiliaria/app/domain/broker/entities/broker_property_entity.dart';
import 'package:imobiliaria/app/domain/broker/usecases/get_broker_properties_use_case.dart';
import 'package:imobiliaria/app/domain/broker/usecases/save_broker_property_use_case.dart';
import 'package:imobiliaria/app/domain/broker/usecases/update_broker_property_status_use_case.dart';
import 'package:imobiliaria/app/domain/media/usecases/get_property_media_file_use_case.dart';
import 'package:imobiliaria/app/presentation/main/main_routes.dart';
import 'package:imobiliaria/app/presentation/main/pages/broker/broker_properties_store.dart';
import 'package:legend_core/legend_core.dart';
import 'dart:typed_data';

class BrokerPropertiesController extends Controller {
  BrokerPropertiesController({
    required this.store,
    required this.getBrokerProperties,
    required this.getPropertyMediaFile,
    required this.saveBrokerProperty,
    required this.updateBrokerPropertyStatus,
    required this.navigator,
  });

  final BrokerPropertiesStore store;
  final GetBrokerPropertiesUseCase getBrokerProperties;
  final GetPropertyMediaFileUseCase getPropertyMediaFile;
  final SaveBrokerPropertyUseCase saveBrokerProperty;
  final UpdateBrokerPropertyStatusUseCase updateBrokerPropertyStatus;
  final AppNavigator navigator;

  Future<void> loadProperties({String? status}) async {
    final nextStatus = status ?? store.selectedStatus;
    store.setStatus(nextStatus);
    store.setLoading();

    final result = await getBrokerProperties.call(status: nextStatus);
    result.getResult(
      onSuccess: (data) => store.setProperties(data.items),
      onError: (error) => store.setError(error.message),
    );
  }

  Future<bool> saveProperty({
    String? id,
    required BrokerPropertyFormEntity property,
  }) async {
    final validationMessage = validateProperty(property);
    if (validationMessage != null) {
      store.setError(validationMessage);
      return false;
    }

    store.setLoading();
    final result = await saveBrokerProperty.call(id: id, property: property);

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

  Future<bool> createDraftAndOpenForm({bool replace = false}) async {
    if (replace) {
      navigator.pushReplacementNamed(MainRoutes.brokerPropertyNew);
    } else {
      navigator.pushNamed(MainRoutes.brokerPropertyNew);
    }
    return true;
  }

  void openEditForm(BrokerPropertyEntity property) {
    navigator.pushNamed(MainRoutes.brokerPropertyEditPath(property.id));
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
    final result = await updateBrokerPropertyStatus.call(
      id: id,
      status: status,
    );

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

  String? validateProperty(BrokerPropertyFormEntity property) {
    if (property.title.trim().isEmpty ||
        property.propertyType.trim().isEmpty ||
        property.city.trim().isEmpty ||
        property.neighborhood.trim().isEmpty ||
        property.coverUrl.trim().isEmpty) {
      return 'Informe titulo, tipo, cidade, bairro e foto de capa.';
    }

    final imageUrls = property.imageUrls
        .map((url) => url.trim())
        .where((url) => url.isNotEmpty)
        .toList();
    if (imageUrls.length < 4 || imageUrls.length > 12) {
      return 'Informe entre 4 e 12 URLs de fotos.';
    }

    if (property.areaM2 <= 0 || property.price <= 0) {
      return 'Informe area e valor maiores que zero.';
    }

    return null;
  }
}
