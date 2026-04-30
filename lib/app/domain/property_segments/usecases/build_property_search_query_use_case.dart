import 'package:imobiliaria/app/data/property_segments/repositories/property_segments_repository.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/property_search_filters_entity.dart';
import 'package:legend_core/legend_core.dart';

class BuildPropertySearchQueryUseCase {
  BuildPropertySearchQueryUseCase({required this.repository});

  final PropertySegmentsRepository repository;

  Future<DualResponse<Failure, Uri>> call({
    required PropertySearchFiltersEntity filters,
  }) {
    return repository.buildPropertySearchUri(filters: filters);
  }
}
