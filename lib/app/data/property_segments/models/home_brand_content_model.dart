import 'package:imobiliaria/app/domain/property_segments/entities/home_brand_content_entity.dart';

class HomeBrandContentModel extends HomeBrandContentEntity {
  const HomeBrandContentModel({
    required super.mission,
    required super.about,
    required super.contact,
    required super.videoUrl,
  });

  factory HomeBrandContentModel.fromJson(Map<String, dynamic> json) {
    final contact = json['contact'] as Map<String, dynamic>;
    return HomeBrandContentModel(
      mission: json['mission'] as String,
      about: json['about'] as String,
      contact: HomeContactModel.fromJson(contact),
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
