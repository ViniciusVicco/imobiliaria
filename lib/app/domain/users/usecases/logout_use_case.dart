import 'package:imobiliaria/app/data/users/repositories/auth_repository.dart';
import 'package:legend_core/legend_core.dart';

class LogoutUseCase {
  LogoutUseCase({required this.repository});

  final AuthRepository repository;

  Future<DualResponse<Failure, void>> call() {
    return repository.signOut();
  }
}
