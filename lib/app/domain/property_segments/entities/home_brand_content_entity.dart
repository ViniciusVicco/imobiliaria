class HomeBrandContentEntity {
  const HomeBrandContentEntity({
    required this.mission,
    required this.about,
    required this.contact,
    required this.videoProvider,
    required this.videoTitle,
    required this.videoThumbnailUrl,
    required this.videoUrl,
  });

  final String mission;
  final String about;
  final HomeContactEntity contact;
  final String videoProvider;
  final String videoTitle;
  final String videoThumbnailUrl;
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
