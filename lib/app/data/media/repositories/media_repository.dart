import 'dart:typed_data';

import 'package:dio/dio.dart';
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
        MediaFailure(_mapApiMessage(error)),
      );
    } catch (_) {
      return ErrorResponse<Failure, Uint8List>(MediaFailure());
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
        MediaFailure(_mapApiMessage(error)),
      );
    } catch (_) {
      return ErrorResponse<Failure, PropertyMediaEntity>(MediaFailure());
    }
  }

  String _mapApiMessage(DioException error) {
    final data = error.response?.data;
    final errorBody = data is Map<String, dynamic>
        ? data['error'] as Map<String, dynamic>?
        : null;
    final errorMessage = errorBody?['message'] as String?;

    if (errorMessage != null && errorMessage.isNotEmpty) return errorMessage;
    if (error.response?.statusCode == 401) return 'Entre novamente.';
    if (error.response?.statusCode == 403) {
      return 'Seu perfil nao pode acessar esta area.';
    }
    if (error.response?.statusCode == 404) return 'Midia nao encontrada.';
    return 'Nao foi possivel concluir a operacao de midia.';
  }
}
