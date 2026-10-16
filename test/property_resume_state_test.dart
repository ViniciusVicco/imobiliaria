import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:legend_core/legend_core.dart' hide Response;
import 'package:imobiliaria/app/data/property_segments/repositories/property_detail_repository.dart';
import 'package:imobiliaria/app/domain/property_segments/usecases/get_property_detail_use_case.dart';
import 'package:imobiliaria/app/presentation/main/pages/property_resume/property_resume_controller.dart';
import 'package:imobiliaria/app/presentation/main/pages/property_resume/property_resume_store.dart';

class _Client extends RestClient {
  _Client() : super(options: BaseOptions(baseUrl: 'https://example.com'));
  int status = 200;
  Completer<void>? pending;
  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    await pending?.future;
    final request = RequestOptions(path: path);
    if (status != 200) {
      throw DioException(
        requestOptions: request,
        response: Response(requestOptions: request, statusCode: status),
      );
    }
    return Response<T>(
      requestOptions: request,
      statusCode: status,
      data: {'id': path.split('/').last, 'title': 'Casa', 'price': 820000} as T,
    );
  }
}

void main() {
  test(
    '404 is unavailable; server errors are retryable; retry loads detail',
    () async {
      final client = _Client();
      final store = PropertyResumeStore();
      final controller = PropertyResumeController(
        store: store,
        getProperty: GetPropertyDetailUseCase(
          repository: PropertyDetailRepository(client: client),
        ),
      );
      client.status = 404;
      await controller.load('missing');
      expect(store.unavailable, isTrue);
      expect(store.error, contains('indisponível'));
      client.status = 500;
      await controller.load('failed');
      expect(store.unavailable, isFalse);
      expect(store.state.value, AppStateEnum.hasError);
      client.status = 200;
      await controller.load('published');
      expect(store.property?.id, 'published');
      expect(store.state.value, AppStateEnum.hasSuccess);
      controller.dispose();
      store.dispose();
    },
  );
  test('late response after page disposal is ignored', () async {
    final client = _Client()..pending = Completer<void>();
    final store = PropertyResumeStore();
    final controller = PropertyResumeController(
      store: store,
      getProperty: GetPropertyDetailUseCase(
        repository: PropertyDetailRepository(client: client),
      ),
    );
    final request = controller.load('late');
    controller.dispose();
    store.dispose();
    client.pending!.complete();
    await request;
  });
}
