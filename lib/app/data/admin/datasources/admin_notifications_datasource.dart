import 'package:imobiliaria/app/data/api/admin_review_endpoints.dart';
import 'package:legend_core/legend_core.dart';

class AdminNotificationsDatasource with AdminReviewEndpoints {
  AdminNotificationsDatasource({required RestClient restClient})
    : _restClient = restClient;
  final RestClient _restClient;

  Future<DataSourceResponse<Map<String, dynamic>>> getNotifications() async {
    final response = await _restClient.get<Map<String, dynamic>>(
      adminNotifications,
    );
    return DataSourceResponse(
      data: response.data ?? {},
      hasSuccess: response.statusCode == 200 && response.data != null,
    );
  }

  Future<DataSourceResponse<Map<String, dynamic>>> markRead(String id) async {
    final response = await _restClient.patch<Map<String, dynamic>>(
      adminNotificationRead(id),
    );
    return DataSourceResponse(
      data: response.data ?? {},
      hasSuccess: response.statusCode == 200 && response.data != null,
    );
  }
}
