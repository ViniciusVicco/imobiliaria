import 'package:imobiliaria/app/data/property_segments/datasources/property_segments_datasource.dart';
import 'package:imobiliaria/app/data/property_segments/failures/segment_route_failure.dart';
import 'package:imobiliaria/app/data/property_segments/models/property_segment_route_model.dart';
import 'package:legend_core/legend_core.dart';

class PropertySegmentsRepository {
  PropertySegmentsRepository({required this.datasource});

  final PropertySegmentsDatasource datasource;

  Future<DualResponse<Failure, PropertySegmentRouteModel>> resolveSegmentRoute({
    required String targetRoute,
  }) async {
    try {
      final response = await datasource.resolveSegmentRoute(
        targetRoute: targetRoute,
      );
      if (response.hasSuccess) {
        return SuccessResponse<Failure, PropertySegmentRouteModel>(
          PropertySegmentRouteModel.fromJson(response.data),
        );
      }
      return ErrorResponse<Failure, PropertySegmentRouteModel>(
        SegmentRouteFailure(),
      );
    } catch (_) {
      return ErrorResponse<Failure, PropertySegmentRouteModel>(
        SegmentRouteFailure(),
      );
    }
  }
}
