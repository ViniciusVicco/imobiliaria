import 'package:dio/dio.dart';
import 'package:legend_core/legend_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthDatasource {
  AuthDatasource({required RestClient restClient}) : _restClient = restClient;

  static const String _accessTokenKey = 'seletta_access_token';

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

  Future<DataSourceResponse<Map<String, dynamic>>> getCurrentUserProfile({
    required String accessToken,
  }) async {
    final response = await _restClient.get<Map<String, dynamic>>(
      '/me',
      options: Options(
        headers: <String, dynamic>{'Authorization': 'Bearer $accessToken'},
      ),
    );
    return DataSourceResponse<Map<String, dynamic>>(
      data: response.data ?? const <String, dynamic>{},
      hasSuccess: response.statusCode == 200 && response.data != null,
    );
  }

  Future<DataSourceResponse<void>> saveAccessToken(String accessToken) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_accessTokenKey, accessToken);
    return DataSourceResponse<void>(data: null, hasSuccess: true);
  }

  Future<DataSourceResponse<String?>> getAccessToken() async {
    final preferences = await SharedPreferences.getInstance();
    final accessToken = preferences.getString(_accessTokenKey);
    return DataSourceResponse<String?>(
      data: accessToken,
      hasSuccess: accessToken != null && accessToken.isNotEmpty,
    );
  }

  Future<DataSourceResponse<void>> clearAccessToken() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_accessTokenKey);
    return DataSourceResponse<void>(data: null, hasSuccess: true);
  }
}
