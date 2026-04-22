import 'dart:math';

import 'package:legend_core/legend_core.dart';

class PropertySegmentsDatasource {
  Future<DataSourceResponse<Map<String, dynamic>>> testIt({
    required String targetRoute,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final testResult = Random().nextBool();
    if (!testResult) {
      throw Exception('pre-flight failed');
    }

    return DataSourceResponse<Map<String, dynamic>>(
      data: <String, dynamic>{
        'isWorking': true,
        'route': targetRoute,
      },
      hasSuccess: testResult,
    );
  }
}
