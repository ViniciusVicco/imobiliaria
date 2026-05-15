import 'package:legend_core/legend_core.dart';

class AuthFailure extends Failure {
  AuthFailure([this._message = 'Nao foi possivel autenticar agora.']);

  final String _message;

  @override
  String get message => _message;
}
