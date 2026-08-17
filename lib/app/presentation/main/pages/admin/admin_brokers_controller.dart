import 'package:imobiliaria/app/domain/admin/usecases/create_admin_broker_use_case.dart';
import 'package:imobiliaria/app/domain/admin/usecases/get_admin_brokers_use_case.dart';
import 'package:imobiliaria/app/presentation/main/pages/admin/admin_brokers_store.dart';
import 'package:legend_core/legend_core.dart';

class AdminBrokersController extends Controller {
  AdminBrokersController({
    required this.store,
    required this.getAdminBrokers,
    required this.createAdminBroker,
  });

  final AdminBrokersStore store;
  final GetAdminBrokersUseCase getAdminBrokers;
  final CreateAdminBrokerUseCase createAdminBroker;

  Future<void> loadBrokers() async {
    store.setLoading();
    final result = await getAdminBrokers.call();

    result.getResult(
      onSuccess: store.setBrokers,
      onError: (error) => store.setError(error.message),
    );
  }

  Future<bool> createBroker({
    required String name,
    required String email,
    required String emailConfirmation,
    required String phone,
  }) async {
    if (name.trim().isEmpty ||
        email.trim().isEmpty ||
        emailConfirmation.trim().isEmpty) {
      store.setError('Informe nome, e-mail e confirmacao de e-mail.');
      return false;
    }

    if (email.trim().toLowerCase() !=
        emailConfirmation.trim().toLowerCase()) {
      store.setError('Confirme o mesmo e-mail do corretor.');
      return false;
    }

    store.setLoading();
    final result = await createAdminBroker.call(
      name: name,
      email: email,
      emailConfirmation: emailConfirmation,
      phone: phone,
    );

    var wasCreated = false;
    result.getResult(
      onSuccess: (_) {
        wasCreated = true;
      },
      onError: (error) => store.setError(error.message),
    );

    if (wasCreated) {
      await loadBrokers();
    }

    return wasCreated;
  }
}
