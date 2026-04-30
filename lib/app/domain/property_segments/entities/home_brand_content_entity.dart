class HomeBrandContentEntity {
  const HomeBrandContentEntity({
    required this.mission,
    required this.about,
    required this.contact,
    required this.videoUrl,
  });

  final String mission;
  final String about;
  final HomeContactEntity contact;
  final String videoUrl;
}

class HomeContactEntity {
  const HomeContactEntity({
    required this.phone,
    required this.email,
    required this.whatsapp,
  });

  final String phone;
  final String email;
  final String whatsapp;
}
