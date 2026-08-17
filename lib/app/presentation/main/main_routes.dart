abstract final class MainRoutes {
  static const String home = '/home';
  static const String commercial = '/commercial';
  static const String residential = '/residential';
  static const String investments = '/investments';
  static const String announceProperty = '/announce-property';
  static const String stock = '/estoque';
  static const String search = '/search';
  static const String login = '/login';
  static const String broker = '/broker';
  static const String brokerProperties = '/broker/properties';
  static const String brokerPropertyNew = '/broker/properties/new';
  static const String brokerPropertyEdit = '/broker/properties/:id/edit';
  static const String admin = '/admin';
  static const String adminUsers = '/admin/users';
  static const String adminProperties = '/admin/properties';
  static const String adminPropertyNew = '/admin/properties/new';
  static const String adminPropertyEdit = '/admin/properties/:id/edit';

  static String brokerPropertyEditPath(String id) {
    return '/broker/properties/$id/edit';
  }

  static String adminPropertyEditPath(String id) {
    return '/admin/properties/$id/edit';
  }
}
