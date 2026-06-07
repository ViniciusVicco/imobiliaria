import 'package:imobiliaria/app/data/admin/repositories/admin_brokers_repository.dart';
import 'package:imobiliaria/app/domain/admin/entities/admin_broker_entity.dart';
import 'package:legend_core/legend_core.dart';

class GetAdminBrokersUseCase {
  GetAdminBrokersUseCase({required this.repository});

  final AdminBrokersRepository repository;

  Future<DualResponse<Failure, List<AdminBrokerEntity>>> call() {
    return repository.getBrokers();
  }
}
