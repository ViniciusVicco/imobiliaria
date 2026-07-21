import 'dart:typed_data';

import 'package:imobiliaria/app/domain/broker/usecases/get_broker_properties_use_case.dart';
import 'package:imobiliaria/app/domain/media/usecases/get_property_media_file_use_case.dart';
import 'package:imobiliaria/app/domain/users/entities/user_profile_entity.dart';
import 'package:imobiliaria/app/domain/users/usecases/get_user_profile_use_case.dart';
import 'package:imobiliaria/app/domain/users/usecases/update_user_password_use_case.dart';
import 'package:imobiliaria/app/domain/users/usecases/update_user_profile_use_case.dart';
import 'package:imobiliaria/app/domain/users/usecases/upload_user_avatar_use_case.dart';
import 'package:imobiliaria/app/presentation/main/main_routes.dart';
import 'package:imobiliaria/app/presentation/main/pages/broker/broker_store.dart';
import 'package:imobiliaria/app/presentation/main/pages/broker/helpers/property_image_picker.dart';
import 'package:legend_core/legend_core.dart';

class BrokerController extends Controller {
  BrokerController({
    required this.store,
    required this.getBrokerProperties,
    required this.getPropertyMediaFile,
    required this.getUserProfile,
    required this.updateUserProfile,
    required this.updateUserPassword,
    required this.uploadUserAvatar,
    required this.navigator,
  });

  final BrokerStore store;
  final GetBrokerPropertiesUseCase getBrokerProperties;
  final GetPropertyMediaFileUseCase getPropertyMediaFile;
  final GetUserProfileUseCase getUserProfile;
  final UpdateUserProfileUseCase updateUserProfile;
  final UpdateUserPasswordUseCase updateUserPassword;
  final UploadUserAvatarUseCase uploadUserAvatar;
  final AppNavigator navigator;

  Future<void> load() async {
    store.setLoading();

    final profileResult = await getUserProfile.call();
    final propertiesResult = await getBrokerProperties.call(status: '');

    UserProfileEntity? profile;
    String? errorMessage;
    profileResult.getResult(
      onSuccess: (data) => profile = data,
      onError: (error) => errorMessage = error.message,
    );

    propertiesResult.getResult(
      onSuccess: (data) {
        if (profile == null) return;
        store.setLoaded(
          properties: data.items,
          statusCounts: data.statusCounts,
          profile: profile!,
        );
      },
      onError: (error) => errorMessage = error.message,
    );

    if (errorMessage != null) store.setError(errorMessage!);
  }

  Future<void> loadProperties(String status) async {
    final result = await getBrokerProperties.call(status: status);
    result.getResult(
      onSuccess: (data) => store.setProperties(
        properties: data.items,
        statusCounts: data.statusCounts,
        status: status,
      ),
      onError: (error) => store.setError(error.message),
    );
  }

  void openNewProperty() {
    navigator.pushNamed(MainRoutes.brokerPropertyNew);
  }

  void openEditProperty(String id) {
    navigator.pushNamed(MainRoutes.brokerPropertyEditPath(id));
  }

  Future<Uint8List?> loadMediaFile(String mediaId) async {
    final result = await getPropertyMediaFile.call(mediaId: mediaId);
    Uint8List? bytes;
    result.getResult(onSuccess: (data) => bytes = data, onError: (_) {});
    return bytes;
  }

  Future<bool> saveProfile() async {
    if (!store.hasProfileChanges || store.isSavingProfile) return false;

    store.setProfileSaving(true);
    final result = await updateUserProfile.call(
      UserProfileUpdateEntity(
        name: store.nameController.text,
        phone: store.phoneController.text,
        whatsapp: store.whatsappController.text,
        creci: store.creciController.text,
        about: store.aboutController.text,
      ),
    );

    var saved = false;
    result.getResult(
      onSuccess: (profile) {
        store.setProfile(profile);
        saved = true;
      },
      onError: (error) => store.setError(error.message),
    );
    store.setProfileSaving(false);
    return saved;
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    final result = await updateUserPassword.call(
      currentPassword: currentPassword,
      newPassword: newPassword,
      newPasswordConfirmation: newPasswordConfirmation,
    );

    var changed = false;
    result.getResult(
      onSuccess: (_) => changed = true,
      onError: (error) => store.setError(error.message),
    );
    return changed;
  }

  Future<bool> pickAndUploadAvatar() async {
    final image = await pickPropertyImage();
    if (image == null) return false;

    store.setAvatarUploading(true);
    final result = await uploadUserAvatar.call(
      fileName: image.fileName,
      mimeType: image.mimeType,
      contentBase64: image.contentBase64,
    );

    var uploaded = false;
    result.getResult(
      onSuccess: (profile) {
        store.setProfile(profile);
        uploaded = true;
      },
      onError: (error) => store.setError(error.message),
    );
    store.setAvatarUploading(false);
    return uploaded;
  }
}
