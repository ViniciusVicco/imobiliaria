import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:imobiliaria/app/assets/custom_assets.dart';
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
    try {
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
    } catch (_) {}

    final data = await _loadJsonList(CustomAssets.mocks.featuredProperties);
    return DataSourceResponse<List<Map<String, dynamic>>>(
      data: data,
      hasSuccess: true,
    );
  }

  Future<DataSourceResponse<Map<String, dynamic>>> getHomeBrandContent() async {
    try {
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
    } catch (_) {}

    final data = await _loadJsonMap(CustomAssets.mocks.homeBrandContent);
    return DataSourceResponse<Map<String, dynamic>>(
      data: data,
      hasSuccess: true,
    );
  }

  Future<Map<String, dynamic>> _loadJsonMap(String path) async {
    final source = await rootBundle.loadString(path);
    return jsonDecode(source) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> _loadJsonList(String path) async {
    final source = await rootBundle.loadString(path);
    final data = jsonDecode(source) as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }
}
