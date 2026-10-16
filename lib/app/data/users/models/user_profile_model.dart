import 'package:imobiliaria/app/domain/users/entities/user_profile_entity.dart';

class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.whatsapp,
    required super.creci,
    required super.about,
    required super.avatarUrl,
    required super.brokerCode,
    required super.role,
    required super.isActive,
    required super.createdAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      whatsapp: json['whatsapp'] as String? ?? '',
      creci: json['creci'] as String? ?? '',
      about: json['about'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      brokerCode: json['brokerCode'] as String? ?? '',
      role: json['role'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}
