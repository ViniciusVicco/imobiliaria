import 'package:imobiliaria/app/domain/admin/entities/admin_broker_entity.dart';

class AdminBrokerModel extends AdminBrokerEntity {
  const AdminBrokerModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.totalProperties,
  });

  factory AdminBrokerModel.fromJson({
    required Map<String, dynamic> userJson,
    required Map<String, dynamic>? summaryJson,
  }) {
    return AdminBrokerModel(
      id: (userJson['id'] as String?) ?? '',
      name: (userJson['name'] as String?) ?? '',
      email: (userJson['email'] as String?) ?? '',
      phone: (userJson['phone'] as String?) ?? '',
      totalProperties: (summaryJson?['totalProperties'] as num?)?.toInt() ?? 0,
    );
  }
}
