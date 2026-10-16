import 'package:imobiliaria/app/domain/admin/entities/admin_notification_entity.dart';

class AdminNotificationsModel extends AdminNotificationsEntity {
  const AdminNotificationsModel({
    required super.items,
    required super.unreadCount,
  });

  factory AdminNotificationsModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    return AdminNotificationsModel(
      unreadCount: json['unreadCount'] as int? ?? 0,
      items: rawItems.cast<Map<String, dynamic>>().map((item) {
        return AdminNotificationModel.fromJson(item);
      }).toList(),
    );
  }
}

class AdminNotificationModel extends AdminNotificationEntity {
  const AdminNotificationModel({
    required super.id,
    required super.propertyId,
    required super.title,
    required super.message,
    required super.isRead,
    required super.emailStatus,
    required super.createdAt,
  });

  factory AdminNotificationModel.fromJson(Map<String, dynamic> json) {
    return AdminNotificationModel(
      id: json['id'] as String? ?? '',
      propertyId: json['propertyId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      isRead: json['isRead'] as bool? ?? false,
      emailStatus: json['emailStatus'] as String? ?? 'pending',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}
