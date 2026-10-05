import 'package:legend_core/legend_core.dart';

class UserProfileFailure extends Failure {
  UserProfileFailure([this.message = 'Nao foi possivel atualizar o perfil.']);

  @override
  final String message;
}
