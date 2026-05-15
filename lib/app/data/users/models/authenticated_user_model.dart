import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  factory AuthenticatedUserModel.fromFirebase({
    required User firebaseUser,
    required DocumentSnapshot<Map<String, dynamic>> profile,
  }) {
    final data = profile.data() ?? const <String, dynamic>{};
    final role = UserRole.fromValue(data['role'] as String?);

    if (role == null) {
      throw const FormatException('Invalid user role.');
    }

    return AuthenticatedUserModel(
      uid: firebaseUser.uid,
      email: (data['email'] as String?) ?? firebaseUser.email ?? '',
      role: role,
      isActive: (data['isActive'] as bool?) ?? false,
      name: (data['name'] as String?) ?? firebaseUser.displayName ?? '',
      phone: data['phone'] as String?,
    );
  }
}
