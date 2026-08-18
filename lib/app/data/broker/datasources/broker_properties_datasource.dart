import 'package:imobiliaria/app/data/api/broker_properties_endpoints.dart';
import 'package:legend_core/legend_core.dart';
import 'package:imobiliaria/app/data/api/admin_review_endpoints.dart';

class BrokerPropertiesDatasource
    with BrokerPropertiesEndpoints, AdminReviewEndpoints {
  BrokerPropertiesDatasource({required RestClient restClient})
    : _restClient = restClient;

  final RestClient _restClient;

  Future<DataSourceResponse<Map<String, dynamic>>> getBrokerProperties({
    required String status,
  }) async {
    final response = await _restClient.get<Map<String, dynamic>>(
      brokerProperties,
      queryParameters: <String, dynamic>{
        if (status.trim().isNotEmpty) 'status': status,
      },
    );

    return DataSourceResponse<Map<String, dynamic>>(
      data: response.data ?? const <String, dynamic>{},
      hasSuccess: response.statusCode == 200 && response.data != null,
    );
  }

  Future<DataSourceResponse<Map<String, dynamic>>> getBrokerProperty(
    String id,
  ) async {
    final response = await _restClient.get<Map<String, dynamic>>(
      brokerProperty(id),
    );

    return DataSourceResponse<Map<String, dynamic>>(
      data: response.data ?? const <String, dynamic>{},
      hasSuccess: response.statusCode == 200 && response.data != null,
    );
  }

  Future<DataSourceResponse<Map<String, dynamic>>> createBrokerProperty({
    required Map<String, dynamic> data,
  }) async {
    final response = await _restClient.post<Map<String, dynamic>>(
      brokerProperties,
      data: data,
    );

    return DataSourceResponse<Map<String, dynamic>>(
      data: response.data ?? const <String, dynamic>{},
      hasSuccess: response.statusCode == 200 && response.data != null,
    );
  }

  Future<DataSourceResponse<Map<String, dynamic>>>
  createBrokerPropertyDraft() async {
    final response = await _restClient.post<Map<String, dynamic>>(
      '$brokerProperties/draft',
    );

    return DataSourceResponse<Map<String, dynamic>>(
      data: response.data ?? const <String, dynamic>{},
      hasSuccess: response.statusCode == 200 && response.data != null,
    );
  }

  Future<DataSourceResponse<Map<String, dynamic>>> updateBrokerProperty({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    final response = await _restClient.patch<Map<String, dynamic>>(
      brokerProperty(id),
      data: data,
    );

    return DataSourceResponse<Map<String, dynamic>>(
      data: response.data ?? const <String, dynamic>{},
      hasSuccess: response.statusCode == 200 && response.data != null,
    );
  }

  Future<DataSourceResponse<Map<String, dynamic>>> updateBrokerPropertyStatus({
    required String id,
    required String status,
  }) async {
    final response = await _restClient.patch<Map<String, dynamic>>(
      brokerPropertyStatus(id),
      data: <String, dynamic>{'status': status},
    );

    return DataSourceResponse<Map<String, dynamic>>(
      data: response.data ?? const <String, dynamic>{},
      hasSuccess: response.statusCode == 200 && response.data != null,
    );
  }

  Future<DataSourceResponse<Map<String, dynamic>>> getAdminProperties({
    required String status,
    String query = '',
    bool featured = false,
  }) async {
    final response = await _restClient.get<Map<String, dynamic>>(
      adminProperties,
      queryParameters: <String, dynamic>{
        if (status.isNotEmpty) 'status': status,
        if (query.trim().isNotEmpty) 'query': query.trim(),
        if (featured) 'featured': true,
      },
    );

    return DataSourceResponse<Map<String, dynamic>>(
      data: response.data ?? const <String, dynamic>{},
      hasSuccess: response.statusCode == 200 && response.data != null,
    );
  }

  Future<DataSourceResponse<Map<String, dynamic>>> getAdminProperty(
    String id,
  ) async {
    final response = await _restClient.get<Map<String, dynamic>>(
      adminProperty(id),
    );

    return DataSourceResponse<Map<String, dynamic>>(
      data: response.data ?? const <String, dynamic>{},
      hasSuccess: response.statusCode == 200 && response.data != null,
    );
  }

  Future<DataSourceResponse<Map<String, dynamic>>> updateAdminProperty({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    final response = await _restClient.patch<Map<String, dynamic>>(
      adminProperty(id),
      data: data,
    );

    return DataSourceResponse<Map<String, dynamic>>(
      data: response.data ?? const <String, dynamic>{},
      hasSuccess: response.statusCode == 200 && response.data != null,
    );
  }

  Future<DataSourceResponse<Map<String, dynamic>>> createAdminProperty({
    required Map<String, dynamic> data,
  }) async {
    final response = await _restClient.post<Map<String, dynamic>>(
      adminProperties,
      data: data,
    );

    return DataSourceResponse<Map<String, dynamic>>(
      data: response.data ?? const <String, dynamic>{},
      hasSuccess: response.statusCode == 200 && response.data != null,
    );
  }

  Future<DataSourceResponse<Map<String, dynamic>>>
  createAdminPropertyDraft() async {
    final response = await _restClient.post<Map<String, dynamic>>(
      '$adminProperties/draft',
    );

    return DataSourceResponse<Map<String, dynamic>>(
      data: response.data ?? const <String, dynamic>{},
      hasSuccess: response.statusCode == 200 && response.data != null,
    );
  }

  Future<DataSourceResponse<Map<String, dynamic>>> updateAdminPropertyStatus({
    required String id,
    required String status,
  }) async {
    final response = await _restClient.patch<Map<String, dynamic>>(
      adminPropertyStatus(id),
      data: <String, dynamic>{'status': status},
    );

    return DataSourceResponse<Map<String, dynamic>>(
      data: response.data ?? const <String, dynamic>{},
      hasSuccess: response.statusCode == 200 && response.data != null,
    );
  }

  Future<DataSourceResponse<Map<String, dynamic>>> approveAdminProperty(
    String id,
  ) async {
    final response = await _restClient.post<Map<String, dynamic>>(
      adminApproveProperty(id),
    );
    return DataSourceResponse(
      data: response.data ?? {},
      hasSuccess: response.statusCode == 200 && response.data != null,
    );
  }

  Future<DataSourceResponse<Map<String, dynamic>>> rejectAdminProperty({
    required String id,
    String? note,
  }) async {
    final response = await _restClient.post<Map<String, dynamic>>(
      adminRejectProperty(id),
      data: <String, dynamic>{'note': note ?? ''},
    );
    return DataSourceResponse(
      data: response.data ?? {},
      hasSuccess: response.statusCode == 200 && response.data != null,
    );
  }
}
