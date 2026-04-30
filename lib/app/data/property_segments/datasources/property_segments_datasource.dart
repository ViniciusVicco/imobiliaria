import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:legend_core/legend_core.dart';

class PropertySegmentsDatasource {
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
    final data = await _loadJsonList('assets/mocks/featured_properties.json');
    return DataSourceResponse<List<Map<String, dynamic>>>(
      data: data,
      hasSuccess: true,
    );
  }

  Future<DataSourceResponse<Map<String, dynamic>>> getHomeBrandContent() async {
    final data = await _loadJsonMap('assets/mocks/home_brand_content.json');
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
