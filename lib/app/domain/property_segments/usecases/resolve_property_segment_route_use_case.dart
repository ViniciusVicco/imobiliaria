import 'package:imobiliaria/app/data/property_segments/repositories/property_segments_repository.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/property_segment_route_entity.dart';
import 'package:legend_core/legend_core.dart';

class ResolvePropertySegmentRouteUseCase {
  ResolvePropertySegmentRouteUseCase({required this.repository});

  final PropertySegmentsRepository repository;

  Future<DualResponse<Failure, PropertySegmentRouteEntity>> call({
    required String targetRoute,
  }) {
    return repository.resolveSegmentRoute(targetRoute: targetRoute);
  }
}
