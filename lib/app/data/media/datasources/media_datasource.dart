import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:imobiliaria/app/data/api/media_endpoints.dart';
import 'package:legend_core/legend_core.dart';

class MediaDatasource with MediaEndpoints {
  MediaDatasource({required RestClient restClient}) : _restClient = restClient;

  final RestClient _restClient;

  Future<DataSourceResponse<Map<String, dynamic>>> uploadPropertyImage({
    required String propertyId,
    required Map<String, dynamic> data,
  }) async {
    final response = await _restClient.post<Map<String, dynamic>>(
      propertyImages(propertyId),
      data: data,
    );

    return DataSourceResponse<Map<String, dynamic>>(
      data: response.data ?? const <String, dynamic>{},
      hasSuccess: response.statusCode == 200 && response.data != null,
    );
  }

  Future<DataSourceResponse<Map<String, dynamic>>>
  uploadTemporaryPropertyImage({required Map<String, dynamic> data}) async {
    final response = await _restClient.post<Map<String, dynamic>>(
      temporaryPropertyImages,
      data: data,
    );

    return DataSourceResponse<Map<String, dynamic>>(
      data: response.data ?? const <String, dynamic>{},
      hasSuccess: response.statusCode == 200 && response.data != null,
    );
  }

  Future<DataSourceResponse<Map<String, dynamic>>> setCover({
    required String mediaId,
  }) async {
    final response = await _restClient.patch<Map<String, dynamic>>(
      mediaCover(mediaId),
    );

    return DataSourceResponse<Map<String, dynamic>>(
      data: response.data ?? const <String, dynamic>{},
      hasSuccess: response.statusCode == 200 && response.data != null,
    );
  }

  Future<DataSourceResponse<Uint8List>> getFile({
    required String mediaId,
  }) async {
    final response = await _restClient.get<List<int>>(
      mediaFile(mediaId),
      options: Options(responseType: ResponseType.bytes),
    );
    final data = response.data ?? const <int>[];

    return DataSourceResponse<Uint8List>(
      data: Uint8List.fromList(data),
      hasSuccess: response.statusCode == 200 && data.isNotEmpty,
    );
  }

  Future<DataSourceResponse<Map<String, dynamic>>> pendingDelete({
    required String mediaId,
  }) async {
    final response = await _restClient.patch<Map<String, dynamic>>(
      mediaPendingDelete(mediaId),
    );

    return DataSourceResponse<Map<String, dynamic>>(
      data: response.data ?? const <String, dynamic>{},
      hasSuccess: response.statusCode == 200 && response.data != null,
    );
  }

  Future<DataSourceResponse<Map<String, dynamic>>> restore({
    required String mediaId,
  }) async {
    final response = await _restClient.patch<Map<String, dynamic>>(
      mediaRestore(mediaId),
    );

    return DataSourceResponse<Map<String, dynamic>>(
      data: response.data ?? const <String, dynamic>{},
      hasSuccess: response.statusCode == 200 && response.data != null,
    );
  }
}
