import 'package:imobiliaria/app/data/broker/repositories/broker_properties_repository.dart';
import 'package:imobiliaria/app/domain/broker/entities/broker_property_entity.dart';
import 'package:legend_core/legend_core.dart';

class CreateAdminPropertyUseCase {
  CreateAdminPropertyUseCase({required this.repository});

  final BrokerPropertiesRepository repository;

  Future<DualResponse<Failure, BrokerPropertyEntity>> call({
    required BrokerPropertyFormEntity property,
  }) {
    return repository.createAdminProperty(property);
  }
}
