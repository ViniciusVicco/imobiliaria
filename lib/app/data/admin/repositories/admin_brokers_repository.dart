import 'package:dio/dio.dart';
import 'package:imobiliaria/app/data/api/api_failure_mapper.dart';
import 'package:imobiliaria/app/data/admin/datasources/admin_brokers_datasource.dart';
import 'package:imobiliaria/app/data/admin/failures/admin_brokers_failure.dart';
import 'package:imobiliaria/app/data/admin/models/admin_broker_model.dart';
import 'package:imobiliaria/app/domain/admin/entities/admin_broker_entity.dart';
import 'package:legend_core/legend_core.dart';

class AdminBrokersRepository {
  AdminBrokersRepository({required this.datasource});

  final AdminBrokersDatasource datasource;

  Future<DualResponse<Failure, List<AdminBrokerEntity>>> getBrokers() async {
    try {
      final usersResponse = await datasource.getBrokers();
      final summariesResponse = await datasource.getBrokerPropertySummaries();

      if (!usersResponse.hasSuccess || !summariesResponse.hasSuccess) {
        return ErrorResponse<Failure, List<AdminBrokerEntity>>(
          AdminBrokersFailure(),
        );
      }

      final summaryByBrokerId = <String, Map<String, dynamic>>{
        for (final summary in summariesResponse.data)
          (summary['brokerId'] as String? ?? ''): summary,
      };

      return SuccessResponse<Failure, List<AdminBrokerEntity>>(
        usersResponse.data
            .map(
              (userJson) => AdminBrokerModel.fromJson(
                userJson: userJson,
                summaryJson: summaryByBrokerId[userJson['id']],
              ),
            )
            .toList(),
      );
    } on DioException catch (error) {
      return ErrorResponse<Failure, List<AdminBrokerEntity>>(
        AdminBrokersFailure(ApiFailureMapper.fromDioException(error)),
      );
    } catch (_) {
      return ErrorResponse<Failure, List<AdminBrokerEntity>>(
        AdminBrokersFailure(ApiFailureMapper.unexpectedResponse()),
      );
    }
  }

  Future<DualResponse<Failure, AdminBrokerEntity>> createBroker({
    required CreateBrokerEntity broker,
  }) async {
    try {
      final response = await datasource.createBroker(data: broker.toJson());

      if (!response.hasSuccess) {
        return ErrorResponse<Failure, AdminBrokerEntity>(
          AdminBrokersFailure('Nao foi possivel criar o corretor agora.'),
        );
      }

      return SuccessResponse<Failure, AdminBrokerEntity>(
        AdminBrokerModel.fromJson(
          userJson: response.data,
          summaryJson: const <String, dynamic>{'totalProperties': 0},
        ),
      );
    } on DioException catch (error) {
      return ErrorResponse<Failure, AdminBrokerEntity>(
        AdminBrokersFailure(ApiFailureMapper.fromDioException(error)),
      );
    } catch (_) {
      return ErrorResponse<Failure, AdminBrokerEntity>(
        AdminBrokersFailure(ApiFailureMapper.unexpectedResponse()),
      );
    }
  }
}
