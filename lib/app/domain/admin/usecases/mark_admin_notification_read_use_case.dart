import 'package:imobiliaria/app/data/admin/repositories/admin_notifications_repository.dart';
import 'package:legend_core/legend_core.dart';

class MarkAdminNotificationReadUseCase {
  MarkAdminNotificationReadUseCase({required this.repository});
  final AdminNotificationsRepository repository;
  Future<DualResponse<Failure, bool>> call(String id) =>
      repository.markRead(id);
}
