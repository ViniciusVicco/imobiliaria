import 'package:imobiliaria/app/data/api/auth_token_interceptor.dart';
import 'package:legend_core/legend_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthDatasource {
  AuthDatasource({required RestClient restClient}) : _restClient = restClient;

  final RestClient _restClient;

  Future<DataSourceResponse<Map<String, dynamic>>>
  signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final response = await _restClient.post<Map<String, dynamic>>(
      '/auth/login',
      data: <String, dynamic>{'email': email, 'password': password},
    );
    return DataSourceResponse<Map<String, dynamic>>(
      data: response.data ?? const <String, dynamic>{},
      hasSuccess: response.statusCode == 200 && response.data != null,
    );
  }

  Future<DataSourceResponse<Map<String, dynamic>>>
  getCurrentUserProfile() async {
    final response = await _restClient.get<Map<String, dynamic>>(
      '/me',
    );
    return DataSourceResponse<Map<String, dynamic>>(
      data: response.data ?? const <String, dynamic>{},
      hasSuccess: response.statusCode == 200 && response.data != null,
    );
  }

  Future<DataSourceResponse<void>> saveAccessToken(String accessToken) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      AuthTokenInterceptor.accessTokenKey,
      accessToken,
    );
    return DataSourceResponse<void>(data: null, hasSuccess: true);
  }

  Future<DataSourceResponse<String?>> getAccessToken() async {
    final preferences = await SharedPreferences.getInstance();
    final accessToken = preferences.getString(
      AuthTokenInterceptor.accessTokenKey,
    );
    return DataSourceResponse<String?>(
      data: accessToken,
      hasSuccess: accessToken != null && accessToken.isNotEmpty,
    );
  }

  Future<DataSourceResponse<void>> clearAccessToken() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(AuthTokenInterceptor.accessTokenKey);
    return DataSourceResponse<void>(data: null, hasSuccess: true);
  }
}
