import 'package:legend_core/legend_core.dart';

class HomeShowcaseFailure extends Failure {
  HomeShowcaseFailure([
    this.message = 'Nao foi possivel carregar a vitrine inicial.',
  ]);

  @override
  final String message;
}
