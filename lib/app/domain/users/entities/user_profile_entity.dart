class UserProfileEntity {
  const UserProfileEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.whatsapp,
    required this.creci,
    required this.about,
    required this.avatarUrl,
    required this.brokerCode,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String whatsapp;
  final String creci;
  final String about;
  final String avatarUrl;
  final String brokerCode;
  final String role;
  final bool isActive;
  final String createdAt;

  UserProfileEntity copyWith({
    String? name,
    String? phone,
    String? whatsapp,
    String? creci,
    String? about,
    String? avatarUrl,
  }) {
    return UserProfileEntity(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      creci: creci ?? this.creci,
      about: about ?? this.about,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      brokerCode: brokerCode,
      role: role,
      isActive: isActive,
      createdAt: createdAt,
    );
  }
}

class UserProfileUpdateEntity {
  const UserProfileUpdateEntity({
    required this.name,
    required this.phone,
    required this.whatsapp,
    required this.creci,
    required this.about,
  });

  final String name;
  final String phone;
  final String whatsapp;
  final String creci;
  final String about;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name.trim(),
      'phone': phone.trim(),
      'whatsapp': whatsapp.trim(),
      'creci': creci.trim(),
      'about': about.trim(),
    };
  }
}
