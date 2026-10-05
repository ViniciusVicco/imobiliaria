import 'package:imobiliaria/app/data/users/repositories/user_profile_repository.dart';
import 'package:imobiliaria/app/domain/users/entities/user_profile_entity.dart';
import 'package:legend_core/legend_core.dart';

class UpdateUserPasswordUseCase {
  UpdateUserPasswordUseCase({required this.repository});

  final UserProfileRepository repository;

  Future<DualResponse<Failure, UserProfileEntity>> call({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) {
    return repository.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      newPasswordConfirmation: newPasswordConfirmation,
    );
  }
}
