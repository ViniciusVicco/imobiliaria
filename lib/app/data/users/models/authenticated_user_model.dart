import 'package:imobiliaria/app/domain/users/entities/authenticated_user_entity.dart';

class AuthenticatedUserModel extends AuthenticatedUserEntity {
  const AuthenticatedUserModel({
    required super.uid,
    required super.email,
    required super.role,
    required super.isActive,
    super.name,
    super.phone,
  });

  factory AuthenticatedUserModel.fromJson(Map<String, dynamic> json) {
    final role = UserRole.fromValue(json['role'] as String?);

    if (role == null) {
      throw const FormatException('Invalid user role.');
    }

    return AuthenticatedUserModel(
      uid: (json['id'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      role: role,
      isActive: (json['isActive'] as bool?) ?? false,
      name: (json['name'] as String?) ?? '',
      phone: json['phone'] as String?,
    );
  }
}
