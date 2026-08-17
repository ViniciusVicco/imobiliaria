import 'package:legend_core/legend_core.dart';

class RestBaseEnviroment {
  static final RestEnv baseEnv = RestEnv(
    baseUrl: 'http://localhost:3333/api/v1',
    enviromentName: 'local',
  );
}
