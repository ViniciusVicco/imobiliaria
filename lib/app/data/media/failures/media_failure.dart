import 'package:legend_core/legend_core.dart';

class MediaFailure extends Failure {
  MediaFailure([this.message = 'Nao foi possivel concluir a operacao de midia.']);

  @override
  final String message;
}
