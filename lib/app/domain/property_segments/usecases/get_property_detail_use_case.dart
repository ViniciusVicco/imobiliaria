import 'package:imobiliaria/app/data/property_segments/repositories/property_detail_repository.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/property_detail_entity.dart';
import 'package:legend_core/legend_core.dart';

class GetPropertyDetailUseCase {
  GetPropertyDetailUseCase({required this.repository});
  final PropertyDetailRepository repository;
  Future<DualResponse<PropertyDetailFailure, PropertyDetailEntity>> call(
    String id,
  ) => repository.get(id);
}
