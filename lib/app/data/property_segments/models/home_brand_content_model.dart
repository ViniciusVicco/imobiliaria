import 'package:imobiliaria/app/domain/property_segments/entities/brand_institutional_content.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/home_brand_content_entity.dart';

class HomeBrandContentModel extends HomeBrandContentEntity {
  const HomeBrandContentModel({
    required super.mission,
    required super.about,
    super.vision,
    super.values,
    required super.contact,
    required super.videoProvider,
    required super.videoTitle,
    required super.videoThumbnailUrl,
    required super.videoUrl,
  });

  factory HomeBrandContentModel.fromJson(Map<String, dynamic> json) {
    final contact = json['contact'] as Map<String, dynamic>;
    return HomeBrandContentModel(
      mission: json['mission'] as String,
      about: json['about'] as String,
      vision: json['vision'] as String? ?? BrandInstitutionalContent.vision,
      values:
          (json['values'] as List<dynamic>?)?.cast<String>() ??
          BrandInstitutionalContent.values,
      contact: HomeContactModel.fromJson(contact),
      videoProvider: json['videoProvider'] as String? ?? 'youtube',
      videoTitle: json['videoTitle'] as String? ?? 'Video da Seletta',
      videoThumbnailUrl: json['videoThumbnailUrl'] as String? ?? '',
      videoUrl: json['videoUrl'] as String,
    );
  }
}

class HomeContactModel extends HomeContactEntity {
  const HomeContactModel({
    required super.phone,
    required super.email,
    required super.whatsapp,
  });

  factory HomeContactModel.fromJson(Map<String, dynamic> json) {
    return HomeContactModel(
      phone: json['phone'] as String,
      email: json['email'] as String,
      whatsapp: json['whatsapp'] as String,
    );
  }
}
