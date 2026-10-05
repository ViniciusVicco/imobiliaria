abstract class RestEnvAbstract {
  final String baseUrl;
  final String enviromentName;
  RestEnvAbstract({required this.baseUrl, required this.enviromentName});
}

class RestEnv extends RestEnvAbstract {
  RestEnv({required super.baseUrl, required super.enviromentName});
}
