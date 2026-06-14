mixin class BrokerPropertiesEndpoints {
  String get brokerProperties => '/broker/properties';
  String brokerProperty(String id) => '$brokerProperties/$id';
  String brokerPropertyStatus(String id) => '$brokerProperties/$id/status';

  String get adminProperties => '/admin/properties';
  String adminProperty(String id) => '$adminProperties/$id';
  String adminPropertyStatus(String id) => '$adminProperties/$id/status';
}
