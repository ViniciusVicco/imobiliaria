class AdminNotificationEntity {
  const AdminNotificationEntity({
    required this.id,
    required this.propertyId,
    required this.title,
    required this.message,
    required this.isRead,
    required this.emailStatus,
    required this.createdAt,
  });

  final String id;
  final String propertyId;
  final String title;
  final String message;
  final bool isRead;
  final String emailStatus;
  final String createdAt;
}

class AdminNotificationsEntity {
  const AdminNotificationsEntity({
    required this.items,
    required this.unreadCount,
  });

  final List<AdminNotificationEntity> items;
  final int unreadCount;
}
