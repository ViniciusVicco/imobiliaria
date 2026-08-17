import 'package:imobiliaria/app/data/admin/repositories/admin_brokers_repository.dart';
import 'package:imobiliaria/app/domain/admin/entities/admin_broker_entity.dart';
import 'package:legend_core/legend_core.dart';

class CreateAdminBrokerUseCase {
  CreateAdminBrokerUseCase({required this.repository});

  final AdminBrokersRepository repository;

  Future<DualResponse<Failure, AdminBrokerEntity>> call({
    required String name,
    required String email,
    required String emailConfirmation,
    required String phone,
  }) {
    return repository.createBroker(
      broker: CreateBrokerEntity(
        name: name,
        email: email,
        emailConfirmation: emailConfirmation,
        phone: phone,
      ),
    );
  }
}
