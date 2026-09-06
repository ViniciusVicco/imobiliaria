import 'dart:typed_data';

import 'package:imobiliaria/app/domain/broker/entities/broker_property_entity.dart';
import 'package:imobiliaria/app/domain/admin/usecases/get_admin_brokers_use_case.dart';
import 'package:imobiliaria/app/domain/broker/usecases/get_admin_property_use_case.dart';
import 'package:imobiliaria/app/domain/broker/usecases/get_broker_property_use_case.dart';
import 'package:imobiliaria/app/domain/broker/usecases/save_admin_property_use_case.dart';
import 'package:imobiliaria/app/domain/broker/usecases/save_broker_property_use_case.dart';
import 'package:imobiliaria/app/domain/broker/usecases/update_admin_property_status_use_case.dart';
import 'package:imobiliaria/app/domain/broker/usecases/update_broker_property_status_use_case.dart';
import 'package:imobiliaria/app/domain/media/entities/property_media_entity.dart';
import 'package:imobiliaria/app/domain/media/usecases/delete_property_media_use_case.dart';
import 'package:imobiliaria/app/domain/media/usecases/get_property_media_file_use_case.dart';
import 'package:imobiliaria/app/domain/media/usecases/restore_property_media_use_case.dart';
import 'package:imobiliaria/app/domain/media/usecases/set_property_cover_use_case.dart';
import 'package:imobiliaria/app/domain/media/usecases/upload_property_image_use_case.dart';
import 'package:imobiliaria/app/domain/media/usecases/upload_temporary_property_image_use_case.dart';
import 'package:imobiliaria/app/presentation/main/pages/broker/property_form_store.dart';
import 'package:legend_core/legend_core.dart';

class PropertyFormController extends Controller {
  PropertyFormController({
    required this.store,
    required this.getBrokerProperty,
    required this.getAdminProperty,
    required this.getAdminBrokers,
    required this.saveBrokerProperty,
    required this.saveAdminProperty,
    required this.updateBrokerPropertyStatus,
    required this.updateAdminPropertyStatus,
    required this.uploadPropertyImage,
    required this.uploadTemporaryPropertyImage,
    required this.setPropertyCover,
    required this.getPropertyMediaFile,
    required this.deletePropertyMedia,
    required this.restorePropertyMedia,
  });

  final PropertyFormStore store;
  final GetBrokerPropertyUseCase getBrokerProperty;
  final GetAdminPropertyUseCase getAdminProperty;
  final GetAdminBrokersUseCase getAdminBrokers;
  final SaveBrokerPropertyUseCase saveBrokerProperty;
  final SaveAdminPropertyUseCase saveAdminProperty;
  final UpdateBrokerPropertyStatusUseCase updateBrokerPropertyStatus;
  final UpdateAdminPropertyStatusUseCase updateAdminPropertyStatus;
  final UploadPropertyImageUseCase uploadPropertyImage;
  final UploadTemporaryPropertyImageUseCase uploadTemporaryPropertyImage;
  final SetPropertyCoverUseCase setPropertyCover;
  final GetPropertyMediaFileUseCase getPropertyMediaFile;
  final DeletePropertyMediaUseCase deletePropertyMedia;
  final RestorePropertyMediaUseCase restorePropertyMedia;
  bool _isAdminMode = false;

  void startNewProperty({required bool isAdmin}) {
    _isAdminMode = isAdmin;
    store.setProperty(
      BrokerPropertyEntity(
        id: '',
        title: '',
        description: '',
        segment: 'residential',
        propertyType: 'Apartamento',
        city: 'Palmas',
        neighborhood: '',
        subNeighborhood: '',
        coverUrl: '',
        imageUrls: const <String>[],
        videoUrl: '',
        tags: const <String>[],
        areaM2: 0,
        privateAreaM2: 0,
        totalAreaM2: 0,
        bedrooms: 0,
        bathrooms: 1,
        garageSpaces: 0,
        propertyAgeYears: 0,
        price: 0,
        status: isAdmin ? 'published' : 'pending_review',
        isFeatured: false,
        updatedAt: '',
      ),
    );

    if (isAdmin) loadBrokers();
  }

  Future<void> loadProperty(String id, {required bool isAdmin}) async {
    _isAdminMode = isAdmin;
    store.setLoading();
    final result = isAdmin
        ? await getAdminProperty.call(id)
        : await getBrokerProperty.call(id);
    result.getResult(
      onSuccess: store.setProperty,
      onError: (error) => store.setError(error.message),
    );

    if (isAdmin) await loadBrokers();
  }

  Future<void> loadBrokers() async {
    final result = await getAdminBrokers.call();
    result.getResult(onSuccess: store.setBrokers, onError: (_) {});
  }

  Future<bool> saveProperty(
    BrokerPropertyFormEntity property, {
    required bool isAdmin,
  }) async {
    final current = store.property;
    if (current == null) return false;

    store.setLoading();
    final result = isAdmin
        ? await saveAdminProperty.call(id: current.id, property: property)
        : await saveBrokerProperty.call(id: current.id, property: property);

    var wasSaved = false;
    result.getResult(
      onSuccess: (property) {
        wasSaved = true;
        store.setProperty(property);
      },
      onError: (error) => store.setError(error.message),
    );
    return wasSaved;
  }

  Future<bool> finalizeProperty({required bool isAdmin}) async {
    final current = store.property;
    if (current == null) return false;

    store.setLoading();
    final result = isAdmin
        ? await updateAdminPropertyStatus.call(
            id: current.id,
            status: 'published',
          )
        : await updateBrokerPropertyStatus.call(
            id: current.id,
            status: 'pending_review',
          );

    var wasFinalized = false;
    result.getResult(
      onSuccess: (property) {
        wasFinalized = true;
        store.setProperty(property);
      },
      onError: (error) => store.setError(error.message),
    );
    return wasFinalized;
  }

  Future<bool> uploadImage(PropertyImageUploadEntity image) async {
    final current = store.property;
    if (current == null) return false;

    store.setLoading();
    final result = await uploadPropertyImage.call(
      propertyId: current.id,
      image: image,
    );

    var wasUploaded = false;
    result.getResult(
      onSuccess: (_) {
        wasUploaded = true;
      },
      onError: (error) => store.setError(error.message),
    );

    if (wasUploaded) await loadProperty(current.id, isAdmin: _isAdminMode);
    return wasUploaded;
  }

  Future<bool> uploadTemporaryImage({
    required String uploadSessionId,
    required PropertyImageUploadEntity image,
  }) async {
    final current = store.property;
    if (current == null) return false;

    store.setLoading();
    final result = await uploadTemporaryPropertyImage.call(
      uploadSessionId: uploadSessionId,
      image: image,
    );

    var wasUploaded = false;
    result.getResult(
      onSuccess: (media) {
        wasUploaded = true;
        final latest = store.property ?? current;
        final existingMedia = latest.media.any((item) => item.id == media.id);
        final nextMedia = existingMedia
            ? latest.media
            : <PropertyMediaEntity>[...latest.media, media];
        final nextCoverUrl = latest.coverUrl.trim().isEmpty
            ? media.publicUrl
            : latest.coverUrl;
        store.setProperty(
          latest.copyWith(media: nextMedia, coverUrl: nextCoverUrl),
        );
      },
      onError: (error) => store.setError(error.message),
    );

    return wasUploaded;
  }

  Future<bool> setCover(String mediaId) async {
    return _runMediaMutation(() => setPropertyCover.call(mediaId: mediaId));
  }

  void setTemporaryCover(String mediaId) {
    final current = store.property;
    if (current == null || current.id.isNotEmpty) return;

    PropertyMediaEntity? media;
    for (final item in current.media) {
      if (item.id == mediaId) {
        media = item;
        break;
      }
    }

    if (media == null) return;

    store.setProperty(
      current.copyWith(
        coverUrl: media.publicUrl.trim().isNotEmpty
            ? media.publicUrl
            : media.url,
      ),
    );
  }

  Future<Uint8List?> loadMediaFile(String mediaId) async {
    final result = await getPropertyMediaFile.call(mediaId: mediaId);
    Uint8List? bytes;
    result.getResult(onSuccess: (data) => bytes = data, onError: (_) {});
    return bytes;
  }

  Future<bool> pendingDelete(String mediaId) async {
    return _runMediaMutation(() => deletePropertyMedia.call(mediaId: mediaId));
  }

  Future<bool> restore(String mediaId) async {
    return _runMediaMutation(() => restorePropertyMedia.call(mediaId: mediaId));
  }

  Future<bool> _runMediaMutation(
    Future<DualResponse<Failure, PropertyMediaEntity>> Function() action,
  ) async {
    final current = store.property;
    if (current == null) return false;

    store.setLoading();
    final result = await action();

    var wasUpdated = false;
    result.getResult(
      onSuccess: (media) {
        wasUpdated = true;
        if (current.id.isEmpty) {
          final nextMedia = current.media
              .map((item) => item.id == media.id ? media : item)
              .toList();
          store.setProperty(current.copyWith(media: nextMedia));
        }
      },
      onError: (error) => store.setError(error.message),
    );

    if (wasUpdated && current.id.isNotEmpty) {
      await loadProperty(current.id, isAdmin: _isAdminMode);
    }
    return wasUpdated;
  }
}
