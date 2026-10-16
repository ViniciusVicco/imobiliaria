import 'package:legend_core/legend_core.dart';

class RestBaseEnviroment {
  static Map<String, String> get headers {
    final host = Uri.parse(baseEnv.baseUrl).host;
    return host.endsWith('.ngrok-free.dev') ||
            host.endsWith('.ngrok-free.app') ||
            host.endsWith('.ngrok.app')
        ? const {'ngrok-skip-browser-warning': '1'}
        : const {};
  }

  static final RestEnv baseEnv = RestEnv(
    baseUrl: const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://another-absently-blunt.ngrok-free.dev/api/v1',
    ),
    enviromentName: 'seletta-go-live',
  );
}
