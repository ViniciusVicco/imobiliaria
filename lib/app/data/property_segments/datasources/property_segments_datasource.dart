import 'package:imobiliaria/app/data/api/property_segments_endpoints.dart';
import 'package:legend_core/legend_core.dart';

class PropertySegmentsDatasource with PropertySegmentsEndpoints {
  final RestClient restClient;
  PropertySegmentsDatasource({required this.restClient});

  Future<DataSourceResponse<Map<String, dynamic>>> resolveSegmentRoute({
    required String targetRoute,
  }) async {
    return DataSourceResponse<Map<String, dynamic>>(
      data: <String, dynamic>{'canNavigate': true, 'route': targetRoute},
      hasSuccess: true,
    );
  }

  Future<DataSourceResponse<List<Map<String, dynamic>>>>
  getFeaturedProperties() async {
    final response = await restClient.get<Map<String, dynamic>>(
      featuredProperties,
    );
    final body = response.data;
    if (response.statusCode == 200 && body != null) {
      final items = body['items'] as List<dynamic>? ?? const <dynamic>[];
      return DataSourceResponse<List<Map<String, dynamic>>>(
        data: items.cast<Map<String, dynamic>>(),
        hasSuccess: true,
      );
    }

    return DataSourceResponse<List<Map<String, dynamic>>>(
      data: const <Map<String, dynamic>>[],
      hasSuccess: false,
    );
  }

  Future<DataSourceResponse<Map<String, dynamic>>> getHomeBrandContent() async {
    final response = await restClient.get<Map<String, dynamic>>(
      brandContent,
    );
    final body = response.data;
    if (response.statusCode == 200 && body != null) {
      return DataSourceResponse<Map<String, dynamic>>(
        data: body,
        hasSuccess: true,
      );
    }

    return DataSourceResponse<Map<String, dynamic>>(
      data: const <String, dynamic>{},
      hasSuccess: false,
    );
  }

  Future<DataSourceResponse<Map<String, dynamic>>> searchPublishedProperties({
    required Map<String, String> queryParameters,
  }) async {
    final response = await restClient.get<Map<String, dynamic>>(
      propertiesSearch,
      queryParameters: <String, dynamic>{
        'page': '1',
        'pageSize': '24',
        ...queryParameters,
      },
    );
    final body = response.data;

    return DataSourceResponse<Map<String, dynamic>>(
      data: body ?? const <String, dynamic>{},
      hasSuccess: response.statusCode == 200 && body != null,
    );
  }
}
