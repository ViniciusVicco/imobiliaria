import 'package:imobiliaria/app/data/users/repositories/auth_repository.dart';
import 'package:imobiliaria/app/domain/users/entities/authenticated_user_entity.dart';
import 'package:legend_core/legend_core.dart';

class LoginWithEmailUseCase {
  LoginWithEmailUseCase({required this.repository});

  final AuthRepository repository;

  Future<DualResponse<Failure, AuthenticatedUserEntity>> call({
    required String email,
    required String password,
  }) {
    return repository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
