class AuthenticatedUserEntity {
  const AuthenticatedUserEntity({
    required this.uid,
    required this.email,
    required this.role,
    required this.isActive,
    this.name = '',
    this.phone,
  });

  final String uid;
  final String email;
  final UserRole role;
  final bool isActive;
  final String name;
  final String? phone;

  bool get isAdmin => role == UserRole.admin;
  bool get isBroker => role == UserRole.broker;
}

enum UserRole {
  admin('admin', 'Administrador'),
  broker('broker', 'Corretor');

  const UserRole(this.value, this.label);

  final String value;
  final String label;

  static UserRole? fromValue(String? value) {
    return switch (value) {
      'admin' => UserRole.admin,
      'broker' => UserRole.broker,
      _ => null,
    };
  }
}
