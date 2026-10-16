import 'package:imobiliaria/app/data/admin/repositories/admin_brokers_repository.dart';
import 'package:imobiliaria/app/domain/admin/entities/admin_broker_entity.dart';
import 'package:imobiliaria/app/domain/users/entities/user_profile_entity.dart';
import 'package:legend_core/legend_core.dart';

class UpdateAdminBrokerUseCase {
  UpdateAdminBrokerUseCase({required this.repository});
  final AdminBrokersRepository repository;
  Future<DualResponse<Failure, AdminBrokerEntity>> call(
    String id,
    UserProfileUpdateEntity profile,
  ) => repository.updateBroker(id, profile);
}

class UploadAdminBrokerAvatarUseCase {
  UploadAdminBrokerAvatarUseCase({required this.repository});
  final AdminBrokersRepository repository;
  Future<DualResponse<Failure, AdminBrokerEntity>> call(
    String id, {
    required String fileName,
    required String mimeType,
    required String contentBase64,
  }) => repository.uploadAvatar(
    id,
    fileName: fileName,
    mimeType: mimeType,
    contentBase64: contentBase64,
  );
}
