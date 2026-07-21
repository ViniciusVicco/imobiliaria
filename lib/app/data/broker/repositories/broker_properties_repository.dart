import 'package:dio/dio.dart';
import 'package:imobiliaria/app/data/api/api_failure_mapper.dart';
import 'package:imobiliaria/app/data/broker/datasources/broker_properties_datasource.dart';
import 'package:imobiliaria/app/data/broker/failures/broker_properties_failure.dart';
import 'package:imobiliaria/app/data/broker/models/broker_property_model.dart';
import 'package:imobiliaria/app/domain/broker/entities/broker_property_entity.dart';
import 'package:legend_core/legend_core.dart';

class BrokerPropertiesRepository {
  BrokerPropertiesRepository({required this.datasource});

  final BrokerPropertiesDatasource datasource;

  Future<DualResponse<Failure, BrokerPropertiesResultEntity>>
  getBrokerProperties({required String status}) {
    return _getProperties(() => datasource.getBrokerProperties(status: status));
  }

  Future<DualResponse<Failure, BrokerPropertyEntity>> getBrokerProperty(
    String id,
  ) {
    return _getProperty(() => datasource.getBrokerProperty(id));
  }

  Future<DualResponse<Failure, BrokerPropertyEntity>> createBrokerProperty(
    BrokerPropertyFormEntity property,
  ) {
    return _getProperty(
      () => datasource.createBrokerProperty(data: property.toJson()),
    );
  }

  Future<DualResponse<Failure, BrokerPropertyEntity>>
  createBrokerPropertyDraft() {
    return _getProperty(() => datasource.createBrokerPropertyDraft());
  }

  Future<DualResponse<Failure, BrokerPropertyEntity>> updateBrokerProperty({
    required String id,
    required BrokerPropertyFormEntity property,
  }) {
    return _getProperty(
      () => datasource.updateBrokerProperty(id: id, data: property.toJson()),
    );
  }

  Future<DualResponse<Failure, BrokerPropertyEntity>> updateBrokerStatus({
    required String id,
    required String status,
  }) {
    return _getProperty(
      () => datasource.updateBrokerPropertyStatus(id: id, status: status),
    );
  }

  Future<DualResponse<Failure, BrokerPropertiesResultEntity>>
  getAdminProperties({required String status, required String query}) {
    return _getProperties(
      () => datasource.getAdminProperties(status: status, query: query),
    );
  }

  Future<DualResponse<Failure, BrokerPropertyEntity>> getAdminProperty(
    String id,
  ) {
    return _getProperty(() => datasource.getAdminProperty(id));
  }

  Future<DualResponse<Failure, BrokerPropertyEntity>> updateAdminProperty({
    required String id,
    required BrokerPropertyFormEntity property,
  }) {
    return _getProperty(
      () => datasource.updateAdminProperty(id: id, data: property.toJson()),
    );
  }

  Future<DualResponse<Failure, BrokerPropertyEntity>> createAdminProperty(
    BrokerPropertyFormEntity property,
  ) {
    return _getProperty(
      () => datasource.createAdminProperty(data: property.toJson()),
    );
  }

  Future<DualResponse<Failure, BrokerPropertyEntity>>
  createAdminPropertyDraft() {
    return _getProperty(() => datasource.createAdminPropertyDraft());
  }

  Future<DualResponse<Failure, BrokerPropertyEntity>> updateAdminStatus({
    required String id,
    required String status,
  }) {
    return _getProperty(
      () => datasource.updateAdminPropertyStatus(id: id, status: status),
    );
  }

  Future<DualResponse<Failure, BrokerPropertiesResultEntity>> _getProperties(
    Future<DataSourceResponse<Map<String, dynamic>>> Function() request,
  ) async {
    try {
      final response = await request();
      if (!response.hasSuccess) {
        return ErrorResponse<Failure, BrokerPropertiesResultEntity>(
          BrokerPropertiesFailure(),
        );
      }

      return SuccessResponse<Failure, BrokerPropertiesResultEntity>(
        BrokerPropertiesResultModel.fromJson(response.data),
      );
    } on DioException catch (error) {
      return ErrorResponse<Failure, BrokerPropertiesResultEntity>(
        BrokerPropertiesFailure(ApiFailureMapper.fromDioException(error)),
      );
    } catch (_) {
      return ErrorResponse<Failure, BrokerPropertiesResultEntity>(
        BrokerPropertiesFailure(ApiFailureMapper.unexpectedResponse()),
      );
    }
  }

  Future<DualResponse<Failure, BrokerPropertyEntity>> _getProperty(
    Future<DataSourceResponse<Map<String, dynamic>>> Function() request,
  ) async {
    try {
      final response = await request();
      if (!response.hasSuccess) {
        return ErrorResponse<Failure, BrokerPropertyEntity>(
          BrokerPropertiesFailure('Nao foi possivel salvar o imovel agora.'),
        );
      }

      return SuccessResponse<Failure, BrokerPropertyEntity>(
        BrokerPropertyModel.fromJson(response.data),
      );
    } on DioException catch (error) {
      return ErrorResponse<Failure, BrokerPropertyEntity>(
        BrokerPropertiesFailure(ApiFailureMapper.fromDioException(error)),
      );
    } catch (_) {
      return ErrorResponse<Failure, BrokerPropertyEntity>(
        BrokerPropertiesFailure(ApiFailureMapper.unexpectedResponse()),
      );
    }
  }
}
