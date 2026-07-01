import 'dart:async';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthTokenInterceptor extends Interceptor {
  static const String accessTokenKey = 'seletta_access_token';
  static const Set<int> _sessionInvalidStatusCodes = <int>{401, 403, 404};
  static const Set<String> _protectedPaths = <String>{'/me', '/auth/logout'};
  static const Set<String> _protectedPathPrefixes = <String>{
    '/admin',
    '/broker',
    '/media',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    unawaited(_handleRequest(options, handler));
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    unawaited(_handleError(err, handler));
  }

  Future<void> _handleRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isProtectedRequest(options)) {
      handler.next(options);
      return;
    }

    try {
      final preferences = await SharedPreferences.getInstance();
      final accessToken = preferences.getString(accessTokenKey);
      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    } catch (_) {
      // Continue without a token if local storage is unavailable.
    } finally {
      handler.next(options);
    }
  }

  Future<void> _handleError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      final statusCode = err.response?.statusCode;
      final isProtectedPath = _isProtectedRequest(err.requestOptions);
      final authorization = err.requestOptions.headers['Authorization'];
      final hasBearerToken =
          authorization is String && authorization.startsWith('Bearer ');

      if (isProtectedPath &&
          hasBearerToken &&
          _sessionInvalidStatusCodes.contains(statusCode)) {
        final preferences = await SharedPreferences.getInstance();
        await preferences.remove(accessTokenKey);
      }
    } catch (_) {
      // Keep the original HTTP error as the source of truth.
    } finally {
      handler.next(err);
    }
  }

  bool _isProtectedRequest(RequestOptions options) {
    return _candidatePaths(options).any(_isProtectedPath);
  }

  Iterable<String> _candidatePaths(RequestOptions options) sync* {
    yield _normalizePath(options.path);
    yield _normalizePath(options.uri.path);
  }

  String _normalizePath(String path) {
    final parsedPath = Uri.tryParse(path)?.path ?? path;
    if (parsedPath.startsWith('/api/v1/')) {
      return parsedPath.replaceFirst('/api/v1', '');
    }
    return parsedPath;
  }

  bool _isProtectedPath(String path) {
    if (_protectedPaths.contains(path)) return true;
    return _protectedPathPrefixes.any(
      (prefix) => path == prefix || path.startsWith('$prefix/'),
    );
  }
}
