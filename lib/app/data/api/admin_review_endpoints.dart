import 'package:imobiliaria/app/data/api/broker_properties_endpoints.dart';

mixin class AdminReviewEndpoints {
  String get adminProperties => '/admin/properties';
  String get adminReviewProperties => '/admin/properties/review';
  String adminPropertyRevisions(String id) => '$adminProperties/$id/revisions';
  String adminApproveProperty(String id) => '$adminProperties/$id/approve';
  String adminRejectProperty(String id) => '$adminProperties/$id/reject';
  String get adminNotifications => '/admin/notifications';
  String adminNotificationRead(String id) => '$adminNotifications/$id/read';
}
