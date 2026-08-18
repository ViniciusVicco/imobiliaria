import 'package:imobiliaria/app/data/broker/repositories/broker_properties_repository.dart';
import 'package:imobiliaria/app/domain/broker/entities/broker_property_entity.dart';
import 'package:legend_core/legend_core.dart';

class GetAdminPropertiesUseCase {
  GetAdminPropertiesUseCase({required this.repository});

  final BrokerPropertiesRepository repository;

  Future<DualResponse<Failure, BrokerPropertiesResultEntity>> call({
    required String status,
    required String query,
    bool featured = false,
  }) {
    return repository.getAdminProperties(
      status: status,
      query: query,
      featured: featured,
    );
  }
}
