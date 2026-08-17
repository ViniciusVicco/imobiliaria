import 'package:imobiliaria/app/data/api/admin_endpoints.dart';
import 'package:legend_core/legend_core.dart';

class AdminBrokersDatasource with AdminEndpoints {
  AdminBrokersDatasource({required RestClient restClient})
    : _restClient = restClient;

  final RestClient _restClient;

  Future<DataSourceResponse<List<Map<String, dynamic>>>> getBrokers() async {
    final response = await _restClient.get<Map<String, dynamic>>(
      adminUsers,
      queryParameters: <String, dynamic>{'role': 'broker'},
    );
    final items = response.data?['items'] as List<dynamic>? ?? const <dynamic>[];

    return DataSourceResponse<List<Map<String, dynamic>>>(
      data: items.cast<Map<String, dynamic>>(),
      hasSuccess: response.statusCode == 200 && response.data != null,
    );
  }

  Future<DataSourceResponse<List<Map<String, dynamic>>>>
  getBrokerPropertySummaries() async {
    final response = await _restClient.get<Map<String, dynamic>>(
      brokersPropertySummary,
    );
    final items = response.data?['items'] as List<dynamic>? ?? const <dynamic>[];

    return DataSourceResponse<List<Map<String, dynamic>>>(
      data: items.cast<Map<String, dynamic>>(),
      hasSuccess: response.statusCode == 200 && response.data != null,
    );
  }

  Future<DataSourceResponse<Map<String, dynamic>>> createBroker({
    required Map<String, dynamic> data,
  }) async {
    final response = await _restClient.post<Map<String, dynamic>>(
      adminBrokers,
      data: data,
    );

    return DataSourceResponse<Map<String, dynamic>>(
      data: response.data ?? const <String, dynamic>{},
      hasSuccess: response.statusCode == 200 && response.data != null,
    );
  }
}
