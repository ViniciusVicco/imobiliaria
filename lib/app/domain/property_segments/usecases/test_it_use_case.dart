import 'package:imobiliaria/app/data/property_segments/repositories/property_segments_repository.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/test_entity.dart';
import 'package:legend_core/legend_core.dart';

class TestItUseCase {
  TestItUseCase({required this.repository});

  final PropertySegmentsRepository repository;

  Future<DualResponse<Failure, TestEntity>> call({
    required String targetRoute,
  }) {
    return repository.testIt(targetRoute: targetRoute);
  }
}
