import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiFailureMapper {
  const ApiFailureMapper._();

  static String fromDioException(
    DioException error, {
    String fallbackMessage = 'Nao foi possivel concluir a operacao agora.',
    Map<int, String> statusMessages = const <int, String>{},
  }) {
    final apiMessage = _apiErrorMessage(error.response?.data);
    if (apiMessage != null) {
      _debugLog(error, apiMessage);
      return apiMessage;
    }

    final statusCode = error.response?.statusCode;
    final statusMessage = statusCode == null
        ? null
        : statusMessages[statusCode];
    if (statusMessage != null && statusMessage.isNotEmpty) {
      _debugLog(error, statusMessage);
      return statusMessage;
    }

    final message = switch (error.type) {
      DioExceptionType.connectionError =>
        'Nao foi possivel conectar ao servidor. Verifique se o backend esta rodando e se a URL esta correta.',
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => 'O servidor demorou para responder.',
      DioExceptionType.badCertificate =>
        'Nao foi possivel validar a conexao com o servidor.',
      DioExceptionType.cancel => 'Operacao cancelada.',
      DioExceptionType.unknown
          when _looksLikeCorsOrBrowserNetworkError(error) =>
        'Falha de rede ou CORS. Confirme origem do app e CORS do backend.',
      DioExceptionType.badResponse when statusCode == 401 => 'Entre novamente.',
      DioExceptionType.badResponse when statusCode == 403 =>
        'Seu perfil nao pode acessar esta area.',
      DioExceptionType.badResponse when statusCode == 404 =>
        'Registro nao encontrado.',
      _ => fallbackMessage,
    };

    _debugLog(error, message);
    return message;
  }

  static String unexpectedResponse([
    String fallbackMessage = 'Recebemos uma resposta inesperada do servidor.',
  ]) {
    if (kDebugMode) {
      debugPrint('[api-error] unexpected response: $fallbackMessage');
    }
    return fallbackMessage;
  }

  static String? _apiErrorMessage(Object? data) {
    if (data is! Map<String, dynamic>) return null;

    final error = data['error'];
    if (error is! Map<String, dynamic>) return null;

    final message = error['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message.trim();
    }

    return null;
  }

  static bool _looksLikeCorsOrBrowserNetworkError(DioException error) {
    final message = error.message ?? error.error?.toString() ?? '';
    return message.contains('XMLHttpRequest') ||
        message.contains('onError') ||
        message.contains('CORS') ||
        message.contains('Failed to fetch');
  }

  static void _debugLog(DioException error, String message) {
    if (!kDebugMode) return;

    final data = error.response?.data;
    final apiCode = error.response?.statusCode;
    debugPrint(
      '[api-error] type=${error.type} status=${error.response?.statusCode} code=$apiCode message=$message path=${error.requestOptions.uri}',
    );
  }
}
