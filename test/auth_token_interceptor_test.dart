import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imobiliaria/app/data/api/auth_token_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Dio dio;
  setUp(() {
    SharedPreferences.setMockInitialValues({
      AuthTokenInterceptor.accessTokenKey: 'saved-session-token',
    });
    dio = Dio(BaseOptions(baseUrl: 'http://localhost:3333/api/v1'));
    dio.interceptors.add(AuthTokenInterceptor());
    // Capture the actual outgoing options without a network or backend.
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) => handler.resolve(
          Response<dynamic>(requestOptions: options, statusCode: 200),
        ),
      ),
    );
  });
  tearDown(() => dio.close(force: true));

  for (final path in [
    '/me',
    '/me/avatar',
    '/me/profile',
    '/me/password',
    '/api/v1/me/avatar',
    'http://localhost:3333/api/v1/me/avatar',
    '/admin/users/one/avatar',
    '/broker/properties',
    '/media/upload',
    '/auth/logout',
  ]) {
    test('sends the saved session token to $path', () async {
      final response = await dio.request<dynamic>(
        path,
        options: Options(
          method: 'POST',
          sendTimeout: const Duration(seconds: 60),
        ),
      );
      expect(
        response.requestOptions.headers['Authorization'],
        'Bearer saved-session-token',
      );
    });
  }

  for (final path in [
    '/auth/login',
    '/properties',
    '/membership',
    '/me-other',
  ]) {
    test('does not attach the session token to public path $path', () async {
      final response = await dio.get<dynamic>(path);
      expect(response.requestOptions.headers['Authorization'], isNull);
    });
  }

  test('does not invent a token when the user is signed out', () async {
    SharedPreferences.setMockInitialValues({});
    final response = await dio.post<dynamic>('/me/avatar');
    expect(response.requestOptions.headers['Authorization'], isNull);
  });
}
