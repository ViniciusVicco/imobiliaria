import 'package:dio/dio.dart';
import 'package:imobiliaria/app/data/admin/datasources/admin_notifications_datasource.dart';
import 'package:imobiliaria/app/data/api/api_failure_mapper.dart';
import 'package:imobiliaria/app/data/admin/failures/admin_brokers_failure.dart';
import 'package:imobiliaria/app/data/admin/models/admin_notification_model.dart';
import 'package:imobiliaria/app/domain/admin/entities/admin_notification_entity.dart';
import 'package:legend_core/legend_core.dart';

class AdminNotificationsRepository {
  AdminNotificationsRepository({required this.datasource});
  final AdminNotificationsDatasource datasource;

  Future<DualResponse<Failure, AdminNotificationsEntity>>
  getNotifications() async {
    try {
      final response = await datasource.getNotifications();
      if (!response.hasSuccess) {
        return ErrorResponse<Failure, AdminNotificationsEntity>(
          AdminBrokersFailure(),
        );
      }
      return SuccessResponse<Failure, AdminNotificationsEntity>(
        AdminNotificationsModel.fromJson(response.data),
      );
    } on DioException catch (error) {
      return ErrorResponse<Failure, AdminNotificationsEntity>(
        AdminBrokersFailure(ApiFailureMapper.fromDioException(error)),
      );
    } catch (_) {
      return ErrorResponse<Failure, AdminNotificationsEntity>(
        AdminBrokersFailure(ApiFailureMapper.unexpectedResponse()),
      );
    }
  }

  Future<DualResponse<Failure, bool>> markRead(String id) async {
    try {
      final response = await datasource.markRead(id);
      if (!response.hasSuccess) {
        return ErrorResponse<Failure, bool>(AdminBrokersFailure());
      }
      return SuccessResponse<Failure, bool>(true);
    } on DioException catch (error) {
      return ErrorResponse<Failure, bool>(
        AdminBrokersFailure(ApiFailureMapper.fromDioException(error)),
      );
    } catch (_) {
      return ErrorResponse<Failure, bool>(
        AdminBrokersFailure(ApiFailureMapper.unexpectedResponse()),
      );
    }
  }
}
