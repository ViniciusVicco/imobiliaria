import 'package:imobiliaria/app/data/broker/repositories/broker_properties_repository.dart';
import 'package:imobiliaria/app/domain/broker/entities/broker_property_entity.dart';
import 'package:legend_core/legend_core.dart';

class RejectAdminPropertyUseCase {
  RejectAdminPropertyUseCase({required this.repository});
  final BrokerPropertiesRepository repository;
  Future<DualResponse<Failure, BrokerPropertyEntity>> call({
    required String id,
    String? note,
  }) => repository.rejectAdminProperty(id: id, note: note);
}
