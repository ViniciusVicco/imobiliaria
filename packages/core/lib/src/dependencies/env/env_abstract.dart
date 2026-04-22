import 'package:legend_core/src/dependencies/env/enviroment.dart';

abstract class EnvAbstract {
  Enviroment resolve() {
    final env = const String.fromEnvironment('ENV').toUpperCase();
    if (env.isEmpty) throw Exception('Env not defined');
    if (env == prod.configName.toUpperCase()) return prod;
    if (env == hom.configName.toUpperCase()) return hom;
    return dev;
  }

  bool get isProd => resolve().configName == prod.configName;

  bool get isOnDebug => const bool.fromEnvironment('ON_DEBUG');

  Enviroment get prod;
  Enviroment get hom;
  Enviroment get dev;
}


