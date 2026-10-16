import 'package:imobiliaria/app/data/users/repositories/auth_repository.dart';
import 'package:imobiliaria/app/domain/users/entities/authenticated_user_entity.dart';
import 'package:legend_core/legend_core.dart';

class WatchCurrentUserSessionUseCase {
  WatchCurrentUserSessionUseCase({required this.repository});

  final AuthRepository repository;

  Stream<DualResponse<Failure, AuthenticatedUserEntity?>> call() {
    return repository.watchCurrentSession();
  }
}
