import 'package:legend_core/legend_core.dart';

class BrokerPropertiesFailure extends Failure {
  BrokerPropertiesFailure([
    this.message = 'Nao foi possivel carregar os imoveis agora.',
  ]);

  @override
  final String message;
}
