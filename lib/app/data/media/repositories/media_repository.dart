import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:imobiliaria/app/data/api/api_failure_mapper.dart';
import 'package:imobiliaria/app/data/media/datasources/media_datasource.dart';
import 'package:imobiliaria/app/data/media/failures/media_failure.dart';
import 'package:imobiliaria/app/data/media/models/property_media_model.dart';
import 'package:imobiliaria/app/domain/media/entities/property_media_entity.dart';
import 'package:legend_core/legend_core.dart';

class MediaRepository {
  MediaRepository({required this.datasource});

  final MediaDatasource datasource;

  Future<DualResponse<Failure, PropertyMediaEntity>> uploadPropertyImage({
    required String propertyId,
    required PropertyImageUploadEntity image,
  }) {
    return _requestMedia(
      () => datasource.uploadPropertyImage(
        propertyId: propertyId,
        data: image.toJson(),
      ),
    );
  }

  Future<DualResponse<Failure, PropertyMediaEntity>>
  uploadTemporaryPropertyImage({
    required String uploadSessionId,
    required PropertyImageUploadEntity image,
  }) {
    return _requestMedia(
      () => datasource.uploadTemporaryPropertyImage(
        data: image.toJson(uploadSessionId: uploadSessionId),
      ),
    );
  }

  Future<DualResponse<Failure, PropertyMediaEntity>> setCover({
    required String mediaId,
  }) {
    return _requestMedia(() => datasource.setCover(mediaId: mediaId));
  }

  Future<DualResponse<Failure, Uint8List>> getFile({
    required String mediaId,
  }) async {
    try {
      final response = await datasource.getFile(mediaId: mediaId);
      if (!response.hasSuccess) {
        return ErrorResponse<Failure, Uint8List>(MediaFailure());
      }

      return SuccessResponse<Failure, Uint8List>(response.data);
    } on DioException catch (error) {
      return ErrorResponse<Failure, Uint8List>(
        MediaFailure(ApiFailureMapper.fromDioException(error)),
      );
    } catch (_) {
      return ErrorResponse<Failure, Uint8List>(
        MediaFailure(ApiFailureMapper.unexpectedResponse()),
      );
    }
  }

  Future<DualResponse<Failure, PropertyMediaEntity>> pendingDelete({
    required String mediaId,
  }) {
    return _requestMedia(() => datasource.pendingDelete(mediaId: mediaId));
  }

  Future<DualResponse<Failure, PropertyMediaEntity>> restore({
    required String mediaId,
  }) {
    return _requestMedia(() => datasource.restore(mediaId: mediaId));
  }

  Future<DualResponse<Failure, PropertyMediaEntity>> _requestMedia(
    Future<DataSourceResponse<Map<String, dynamic>>> Function() request,
  ) async {
    try {
      final response = await request();
      if (!response.hasSuccess) {
        return ErrorResponse<Failure, PropertyMediaEntity>(MediaFailure());
      }

      return SuccessResponse<Failure, PropertyMediaEntity>(
        PropertyMediaModel.fromJson(response.data),
      );
    } on DioException catch (error) {
      return ErrorResponse<Failure, PropertyMediaEntity>(
        MediaFailure(ApiFailureMapper.fromDioException(error)),
      );
    } catch (_) {
      return ErrorResponse<Failure, PropertyMediaEntity>(
        MediaFailure(ApiFailureMapper.unexpectedResponse()),
      );
    }
  }
}
