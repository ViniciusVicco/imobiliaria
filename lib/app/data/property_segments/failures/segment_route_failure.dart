import 'package:legend_core/legend_core.dart';

class SegmentRouteFailure extends Failure {
  SegmentRouteFailure([
    this.message = 'Nao foi possivel abrir este segmento agora.',
  ]);

  @override
  final String message;
}
