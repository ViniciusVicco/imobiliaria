import 'package:imobiliaria/app/domain/media/entities/property_media_entity.dart';

class BrokerPropertyEntity {
  const BrokerPropertyEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.segment,
    required this.propertyType,
    required this.city,
    required this.neighborhood,
    required this.subNeighborhood,
    required this.coverUrl,
    required this.imageUrls,
    required this.videoUrl,
    required this.tags,
    required this.areaM2,
    required this.bedrooms,
    required this.bathrooms,
    required this.garageSpaces,
    required this.propertyAgeYears,
    required this.price,
    required this.status,
    required this.isFeatured,
    required this.updatedAt,
    this.media = const <PropertyMediaEntity>[],
    this.broker,
  });

  final String id;
  final String title;
  final String description;
  final String segment;
  final String propertyType;
  final String city;
  final String neighborhood;
  final String subNeighborhood;
  final String coverUrl;
  final List<String> imageUrls;
  final String videoUrl;
  final List<String> tags;
  final int areaM2;
  final int bedrooms;
  final int bathrooms;
  final int garageSpaces;
  final int propertyAgeYears;
  final int price;
  final String status;
  final bool isFeatured;
  final String updatedAt;
  final List<PropertyMediaEntity> media;
  final BrokerPropertyBrokerEntity? broker;

  BrokerPropertyFormEntity toForm() {
    return BrokerPropertyFormEntity(
      title: title,
      description: description,
      segment: segment,
      propertyType: propertyType,
      city: city,
      neighborhood: neighborhood,
      subNeighborhood: subNeighborhood,
      coverUrl: coverUrl,
      imageUrls: imageUrls,
      videoUrl: videoUrl,
      areaM2: areaM2,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      garageSpaces: garageSpaces,
      propertyAgeYears: propertyAgeYears,
      price: price,
      tagSlugs: tags,
      isFeatured: isFeatured,
      isNewDevelopment: tags.contains('na-planta') || propertyAgeYears == 0,
      brokerId: broker?.id,
    );
  }
}

class BrokerPropertyBrokerEntity {
  const BrokerPropertyBrokerEntity({
    required this.id,
    required this.name,
    required this.phone,
  });

  final String id;
  final String name;
  final String phone;
}

class BrokerPropertiesPaginationEntity {
  const BrokerPropertiesPaginationEntity({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
  });

  final int page;
  final int pageSize;
  final int total;
  final int totalPages;
}

class BrokerPropertiesResultEntity {
  const BrokerPropertiesResultEntity({
    required this.items,
    required this.pagination,
  });

  final List<BrokerPropertyEntity> items;
  final BrokerPropertiesPaginationEntity pagination;
}

class BrokerPropertyFormEntity {
  const BrokerPropertyFormEntity({
    required this.title,
    required this.description,
    required this.segment,
    required this.propertyType,
    required this.city,
    required this.neighborhood,
    required this.subNeighborhood,
    required this.coverUrl,
    required this.imageUrls,
    required this.videoUrl,
    required this.areaM2,
    required this.bedrooms,
    required this.bathrooms,
    required this.garageSpaces,
    required this.propertyAgeYears,
    required this.price,
    required this.tagSlugs,
    required this.isFeatured,
    required this.isNewDevelopment,
    this.brokerId,
  });

  factory BrokerPropertyFormEntity.empty() {
    return const BrokerPropertyFormEntity(
      title: '',
      description: '',
      segment: 'residential',
      propertyType: 'Apartamento',
      city: 'Palmas',
      neighborhood: '',
      subNeighborhood: '',
      coverUrl: '',
      imageUrls: <String>['', '', '', ''],
      videoUrl: '',
      areaM2: 1,
      bedrooms: 0,
      bathrooms: 1,
      garageSpaces: 0,
      propertyAgeYears: 0,
      price: 1,
      tagSlugs: <String>[],
      isFeatured: false,
      isNewDevelopment: false,
    );
  }

  final String title;
  final String description;
  final String segment;
  final String propertyType;
  final String city;
  final String neighborhood;
  final String subNeighborhood;
  final String coverUrl;
  final List<String> imageUrls;
  final String videoUrl;
  final int areaM2;
  final int bedrooms;
  final int bathrooms;
  final int garageSpaces;
  final int propertyAgeYears;
  final int price;
  final List<String> tagSlugs;
  final bool isFeatured;
  final bool isNewDevelopment;
  final String? brokerId;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title.trim(),
      'description': description.trim(),
      'segment': segment,
      'propertyType': propertyType.trim(),
      'city': city.trim().isEmpty ? 'Palmas' : city.trim(),
      'neighborhood': neighborhood.trim(),
      'subNeighborhood': subNeighborhood.trim(),
      'coverUrl': coverUrl.trim(),
      'imageUrls': imageUrls
          .map((url) => url.trim())
          .where((url) => url.isNotEmpty)
          .toList(),
      'videoUrl': videoUrl.trim(),
      'areaM2': areaM2,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'garageSpaces': garageSpaces,
      'propertyAgeYears': isNewDevelopment ? 0 : propertyAgeYears,
      'price': price,
      'tagSlugs': tagSlugs,
      'isFeatured': isFeatured,
      'isNewDevelopment': isNewDevelopment,
      if (brokerId != null && brokerId!.isNotEmpty) 'brokerId': brokerId,
    };
  }
}
