mixin class AdminEndpoints {
  String get adminUsers => '/admin/users';
  String get adminBrokers => '/admin/brokers';
  String get brokersPropertySummary =>
      '/admin/reports/brokers-property-summary';
}
