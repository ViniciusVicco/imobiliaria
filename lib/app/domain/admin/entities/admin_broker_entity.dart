class AdminBrokerEntity {
  const AdminBrokerEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.totalProperties,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final int totalProperties;
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
