import 'brand_institutional_content.dart';

class HomeBrandContentEntity {
  const HomeBrandContentEntity({
    required this.mission,
    required this.about,
    this.vision = BrandInstitutionalContent.vision,
    this.values = BrandInstitutionalContent.values,
    required this.contact,
    required this.videoProvider,
    required this.videoTitle,
    required this.videoThumbnailUrl,
    required this.videoUrl,
  });

  final String mission;
  final String about;
  final String vision;
  final List<String> values;
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
