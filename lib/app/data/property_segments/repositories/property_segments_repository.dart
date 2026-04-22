import 'package:imobiliaria/app/data/property_segments/datasources/property_segments_datasource.dart';
import 'package:imobiliaria/app/data/property_segments/failures/test_failed_failure.dart';
import 'package:imobiliaria/app/data/property_segments/models/test_model.dart';
import 'package:legend_core/legend_core.dart';

class PropertySegmentsRepository {
  PropertySegmentsRepository({required this.datasource});

  final PropertySegmentsDatasource datasource;

  Future<DualResponse<Failure, TestModel>> testIt({
    required String targetRoute,
  }) async {
    try {
      final response = await datasource.testIt(targetRoute: targetRoute);
      if (response.hasSuccess) {
        return SuccessResponse<Failure, TestModel>(
          TestModel.fromJson(response.data),
        );
      }
      return ErrorResponse<Failure, TestModel>(TestFailedFailure());
    } catch (_) {
      return ErrorResponse<Failure, TestModel>(TestFailedFailure());
    }
  }
}
