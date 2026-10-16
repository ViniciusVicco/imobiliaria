import 'package:imobiliaria/app/domain/admin/entities/admin_broker_entity.dart';

class AdminBrokerModel extends AdminBrokerEntity {
  const AdminBrokerModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.totalProperties,
    super.whatsapp,
    super.creci,
    super.about,
    super.avatarUrl,
    super.brokerCode,
    super.role,
  });

  factory AdminBrokerModel.fromJson({
    required Map<String, dynamic> userJson,
    required Map<String, dynamic>? summaryJson,
  }) {
    return AdminBrokerModel(
      role: userJson['role'] as String? ?? 'broker',
      id: (userJson['id'] as String?) ?? '',
      name: (userJson['name'] as String?) ?? '',
      email: (userJson['email'] as String?) ?? '',
      phone: (userJson['phone'] as String?) ?? '',
      whatsapp: userJson['whatsapp'] as String? ?? '',
      creci: userJson['creci'] as String? ?? '',
      about: userJson['about'] as String? ?? '',
      avatarUrl: userJson['avatarUrl'] as String? ?? '',
      brokerCode: userJson['brokerCode'] as String? ?? '',

      totalProperties: (summaryJson?['totalProperties'] as num?)?.toInt() ?? 0,
    );
  }
}
