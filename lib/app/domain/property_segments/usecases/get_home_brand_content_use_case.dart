import 'package:imobiliaria/app/data/property_segments/repositories/property_segments_repository.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/home_brand_content_entity.dart';
import 'package:legend_core/legend_core.dart';

class GetHomeBrandContentUseCase {
  GetHomeBrandContentUseCase({required this.repository});

  final PropertySegmentsRepository repository;

  Future<DualResponse<Failure, HomeBrandContentEntity>> call() {
    return repository.getHomeBrandContent();
  }
}
