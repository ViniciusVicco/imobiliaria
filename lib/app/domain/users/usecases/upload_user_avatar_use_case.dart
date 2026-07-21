import 'package:imobiliaria/app/data/users/repositories/user_profile_repository.dart';
import 'package:imobiliaria/app/domain/users/entities/user_profile_entity.dart';
import 'package:legend_core/legend_core.dart';

class UploadUserAvatarUseCase {
  UploadUserAvatarUseCase({required this.repository});

  final UserProfileRepository repository;

  Future<DualResponse<Failure, UserProfileEntity>> call({
    required String fileName,
    required String mimeType,
    required String contentBase64,
  }) {
    return repository.uploadAvatar(
      fileName: fileName,
      mimeType: mimeType,
      contentBase64: contentBase64,
    );
  }
}
