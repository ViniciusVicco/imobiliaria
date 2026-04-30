import 'package:imobiliaria/app/data/property_segments/repositories/property_segments_repository.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/featured_property_entity.dart';
import 'package:legend_core/legend_core.dart';

class GetFeaturedPropertiesUseCase {
  GetFeaturedPropertiesUseCase({required this.repository});

  final PropertySegmentsRepository repository;

  Future<DualResponse<Failure, List<FeaturedPropertyEntity>>> call() {
    return repository.getFeaturedProperties();
  }
}
