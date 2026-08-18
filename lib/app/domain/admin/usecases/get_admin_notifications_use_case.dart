import 'package:imobiliaria/app/data/admin/repositories/admin_notifications_repository.dart';
import 'package:imobiliaria/app/domain/admin/entities/admin_notification_entity.dart';
import 'package:legend_core/legend_core.dart';

class GetAdminNotificationsUseCase {
  GetAdminNotificationsUseCase({required this.repository});
  final AdminNotificationsRepository repository;
  Future<DualResponse<Failure, AdminNotificationsEntity>> call() =>
      repository.getNotifications();
}
