import 'package:legend_core/legend_core.dart';

class AdminBrokersFailure extends Failure {
  AdminBrokersFailure([
    this.message = 'Nao foi possivel carregar os corretores agora.',
  ]);

  @override
  final String message;
}
