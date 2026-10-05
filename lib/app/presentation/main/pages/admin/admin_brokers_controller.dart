import 'package:imobiliaria/app/domain/admin/usecases/edit_admin_broker_use_case.dart';
import 'package:imobiliaria/app/domain/admin/entities/admin_broker_entity.dart';
import 'package:imobiliaria/app/domain/users/entities/user_profile_entity.dart';
import 'package:imobiliaria/app/presentation/main/pages/broker/helpers/property_image_picker.dart';
import 'package:imobiliaria/app/domain/admin/usecases/create_admin_broker_use_case.dart';
import 'package:imobiliaria/app/domain/admin/usecases/get_admin_brokers_use_case.dart';
import 'package:imobiliaria/app/presentation/main/pages/admin/admin_brokers_store.dart';
import 'package:legend_core/legend_core.dart';

class AdminBrokersController extends Controller {
  AdminBrokersController({
    required this.store,
    required this.getAdminBrokers,
    required this.createAdminBroker,
    required this.updateAdminBroker,
    required this.uploadAdminBrokerAvatar,
  });

  final AdminBrokersStore store;
  final GetAdminBrokersUseCase getAdminBrokers;
  final CreateAdminBrokerUseCase createAdminBroker;

  final UpdateAdminBrokerUseCase updateAdminBroker;
  final UploadAdminBrokerAvatarUseCase uploadAdminBrokerAvatar;
  String? editError;
  bool _isEditing = false;

  Future<AdminBrokerEntity?> saveBroker(
    String id,
    UserProfileUpdateEntity profile,
  ) async {
    if (_isEditing) return null;
    editError = null;
    if (profile.name.trim().length < 2 || profile.phone.trim().isEmpty) {
      editError = 'Informe nome completo e celular.';
      return null;
    }
    _isEditing = true;
    try {
      final result = await updateAdminBroker.call(id, profile);
      AdminBrokerEntity? saved;
      result.getResult(
        onSuccess: (value) => saved = value,
        onError: (error) => editError = error.message,
      );
      return saved;
    } finally {
      _isEditing = false;
    }
  }

  Future<AdminBrokerEntity?> uploadAvatar(
    String id,
    PickedPropertyImage image,
  ) async {
    if (_isEditing) return null;
    _isEditing = true;
    editError = null;
    try {
      final result = await uploadAdminBrokerAvatar.call(
        id,
        fileName: image.fileName,
        mimeType: image.mimeType,
        contentBase64: image.contentBase64,
      );
      AdminBrokerEntity? saved;
      result.getResult(
        onSuccess: (value) => saved = value,
        onError: (error) => editError = error.message,
      );
      return saved;
    } catch (_) {
      editError = 'Nao foi possivel ler a imagem. Tente novamente.';
      return null;
    } finally {
      _isEditing = false;
    }
  }

  Future<void> loadBrokers() async {
    store.setLoading();
    final result = await getAdminBrokers.call();

    result.getResult(
      onSuccess: store.setBrokers,
      onError: (error) => store.setError(error.message),
    );
  }

  Future<bool> createBroker({
    required String name,
    required String email,
    required String emailConfirmation,
    required String phone,
  }) async {
    if (name.trim().isEmpty ||
        email.trim().isEmpty ||
        emailConfirmation.trim().isEmpty) {
      store.setError('Informe nome, e-mail e confirmacao de e-mail.');
      return false;
    }

    if (email.trim().toLowerCase() != emailConfirmation.trim().toLowerCase()) {
      store.setError('Confirme o mesmo e-mail do corretor.');
      return false;
    }

    store.setLoading();
    final result = await createAdminBroker.call(
      name: name,
      email: email,
      emailConfirmation: emailConfirmation,
      phone: phone,
    );

    var wasCreated = false;
    result.getResult(
      onSuccess: (_) {
        wasCreated = true;
      },
      onError: (error) => store.setError(error.message),
    );

    if (wasCreated) {
      await loadBrokers();
    }

    return wasCreated;
  }
}
