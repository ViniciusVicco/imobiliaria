import 'package:imobiliaria/app/data/property_segments/repositories/property_segments_repository.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/search_property_entity.dart';
import 'package:legend_core/legend_core.dart';

class SearchPublishedPropertiesUseCase {
  SearchPublishedPropertiesUseCase({required this.repository});

  final PropertySegmentsRepository repository;

  Future<DualResponse<Failure, PropertySearchResultEntity>> call({
    required Map<String, String> queryParameters,
  }) {
    return repository.searchPublishedProperties(
      queryParameters: queryParameters,
    );
  }
}
