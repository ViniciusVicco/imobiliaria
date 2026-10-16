class AdminBrokerEntity {
  const AdminBrokerEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.totalProperties,
    this.whatsapp = '',
    this.creci = '',
    this.about = '',
    this.avatarUrl = '',
    this.brokerCode = '',
    this.role = 'broker',
  });

  final String role;
  final String id;
  final String name;
  final String email;
  final String phone;
  final int totalProperties;
  final String whatsapp, creci, about, avatarUrl, brokerCode;
}

class CreateBrokerEntity {
  const CreateBrokerEntity({
    required this.name,
    required this.email,
    required this.emailConfirmation,
    required this.phone,
  });

  final String name;
  final String email;
  final String emailConfirmation;
  final String phone;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name.trim(),
      'email': email.trim(),
      'emailConfirmation': emailConfirmation.trim(),
      'phone': phone.trim(),
    };
  }
}
