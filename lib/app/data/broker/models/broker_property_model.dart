import 'package:imobiliaria/app/domain/broker/entities/broker_property_entity.dart';
import 'package:imobiliaria/app/data/media/models/property_media_model.dart';

class BrokerPropertyModel extends BrokerPropertyEntity {
  const BrokerPropertyModel({
    required super.id,
    required super.title,
    required super.description,
    required super.segment,
    required super.propertyType,
    required super.city,
    required super.neighborhood,
    required super.subNeighborhood,
    required super.coverUrl,
    required super.imageUrls,
    required super.videoUrl,
    required super.tags,
    required super.areaM2,
    required super.bedrooms,
    required super.bathrooms,
    required super.garageSpaces,
    required super.propertyAgeYears,
    required super.price,
    required super.status,
    required super.isFeatured,
    required super.updatedAt,
    super.media,
    super.broker,
  });

  factory BrokerPropertyModel.fromJson(Map<String, dynamic> json) {
    final brokerJson = json['broker'] as Map<String, dynamic>?;
    final media = json['media'] as List<dynamic>? ?? const <dynamic>[];
    final mediaItems = media
        .cast<Map<String, dynamic>>()
        .map(PropertyMediaModel.fromJson)
        .toList();
    final imageUrlsFromMedia = mediaItems
        .where((item) => item.type == 'image')
        .map((item) => item.url)
        .toList();
    final rawCoverUrl = json['coverUrl'] as String? ?? '';
    final fallbackCoverUrl = mediaItems
        .where((item) => item.type == 'image' && item.status == 'active')
        .map((item) => item.publicUrl.isNotEmpty ? item.publicUrl : item.url)
        .where((url) => url.trim().isNotEmpty)
        .firstOrNull;

    return BrokerPropertyModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      segment: json['segment'] as String? ?? 'residential',
      propertyType: json['propertyType'] as String? ?? '',
      city: json['city'] as String? ?? 'Palmas',
      neighborhood: json['neighborhood'] as String? ?? '',
      subNeighborhood: json['subNeighborhood'] as String? ?? '',
      coverUrl: rawCoverUrl.trim().isNotEmpty
          ? rawCoverUrl
          : fallbackCoverUrl ?? '',
      imageUrls: (json['imageUrls'] as List<dynamic>? ?? imageUrlsFromMedia)
          .map((url) => url.toString())
          .toList(),
      videoUrl: json['videoUrl'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>? ?? const <dynamic>[])
          .map((tag) => tag.toString())
          .toList(),
      areaM2: json['areaM2'] as int? ?? 0,
      bedrooms: json['bedrooms'] as int? ?? 0,
      bathrooms: json['bathrooms'] as int? ?? 0,
      garageSpaces: json['garageSpaces'] as int? ?? 0,
      propertyAgeYears: json['propertyAgeYears'] as int? ?? 0,
      price: json['price'] as int? ?? 0,
      status: json['status'] as String? ?? 'published',
      isFeatured: json['isFeatured'] as bool? ?? false,
      updatedAt: json['updatedAt'] as String? ?? '',
      media: mediaItems,
      broker: brokerJson == null
          ? null
          : BrokerPropertyBrokerModel.fromJson(brokerJson),
    );
  }
}

class BrokerPropertyBrokerModel extends BrokerPropertyBrokerEntity {
  const BrokerPropertyBrokerModel({
    required super.id,
    required super.name,
    required super.phone,
  });

  factory BrokerPropertyBrokerModel.fromJson(Map<String, dynamic> json) {
    return BrokerPropertyBrokerModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }
}

class BrokerPropertiesPaginationModel extends BrokerPropertiesPaginationEntity {
  const BrokerPropertiesPaginationModel({
    required super.page,
    required super.pageSize,
    required super.total,
    required super.totalPages,
  });

  factory BrokerPropertiesPaginationModel.fromJson(Map<String, dynamic> json) {
    return BrokerPropertiesPaginationModel(
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 24,
      total: json['total'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
    );
  }
}

class BrokerPropertiesResultModel extends BrokerPropertiesResultEntity {
  const BrokerPropertiesResultModel({
    required super.items,
    required super.pagination,
    super.statusCounts,
  });

  factory BrokerPropertiesResultModel.fromJson(Map<String, dynamic> json) {
    final items = json['items'] as List<dynamic>? ?? const <dynamic>[];
    final pagination =
        json['pagination'] as Map<String, dynamic>? ??
        const <String, dynamic>{};
    final statusCounts =
        json['statusCounts'] as Map<String, dynamic>? ??
        const <String, dynamic>{};

    return BrokerPropertiesResultModel(
      items: items
          .cast<Map<String, dynamic>>()
          .map(BrokerPropertyModel.fromJson)
          .toList(),
      pagination: BrokerPropertiesPaginationModel.fromJson(pagination),
      statusCounts: statusCounts.map(
        (key, value) => MapEntry(key, value is int ? value : 0),
      ),
    );
  }
}
