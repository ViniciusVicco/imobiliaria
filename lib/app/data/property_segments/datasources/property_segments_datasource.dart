import 'package:legend_core/legend_core.dart';

class PropertySegmentsDatasource {
  Future<DataSourceResponse<Map<String, dynamic>>> resolveSegmentRoute({
    required String targetRoute,
  }) async {
    return DataSourceResponse<Map<String, dynamic>>(
      data: <String, dynamic>{
        'canNavigate': true,
        'route': targetRoute,
      },
      hasSuccess: true,
    );
  }
}
