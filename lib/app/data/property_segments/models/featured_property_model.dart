import 'package:imobiliaria/app/domain/property_segments/entities/featured_property_entity.dart';

class FeaturedPropertyModel extends FeaturedPropertyEntity {
  const FeaturedPropertyModel({
    required super.id,
    required super.title,
    required super.segment,
    required super.propertyType,
    required super.city,
    required super.neighborhood,
    required super.coverUrl,
    required super.areaM2,
    required super.bathrooms,
    required super.garageSpaces,
    required super.propertyAgeYears,
    required super.price,
    super.bedrooms,
  });

  factory FeaturedPropertyModel.fromJson(Map<String, dynamic> json) {
    return FeaturedPropertyModel(
      id: json['id'] as String,
      title: json['title'] as String,
      segment: json['segment'] as String,
      propertyType: json['propertyType'] as String,
      city: json['city'] as String,
      neighborhood: json['neighborhood'] as String,
      coverUrl: json['coverUrl'] as String,
      areaM2: json['areaM2'] as int,
      bedrooms: json['bedrooms'] as int?,
      bathrooms: json['bathrooms'] as int,
      garageSpaces: json['garageSpaces'] as int,
      propertyAgeYears: json['propertyAgeYears'] as int,
      price: json['price'] as int,
    );
  }
}
