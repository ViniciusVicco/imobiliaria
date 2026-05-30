import 'package:imobiliaria/app/domain/property_segments/entities/search_property_entity.dart';

class SearchPropertyModel extends SearchPropertyEntity {
  const SearchPropertyModel({
    required super.id,
    required super.title,
    required super.segment,
    required super.propertyType,
    required super.city,
    required super.neighborhood,
    required super.subNeighborhood,
    required super.coverUrl,
    required super.areaM2,
    required super.bathrooms,
    required super.garageSpaces,
    required super.propertyAgeYears,
    required super.price,
    super.tags,
    super.bedrooms,
  });

  factory SearchPropertyModel.fromJson(Map<String, dynamic> json) {
    return SearchPropertyModel(
      id: json['id'] as String,
      title: json['title'] as String,
      segment: json['segment'] as String,
      propertyType: json['propertyType'] as String,
      city: json['city'] as String,
      neighborhood: json['neighborhood'] as String,
      subNeighborhood: json['subNeighborhood'] as String? ?? '',
      coverUrl: json['coverUrl'] as String,
      areaM2: json['areaM2'] as int? ?? 0,
      bedrooms: json['bedrooms'] as int?,
      bathrooms: json['bathrooms'] as int? ?? 0,
      garageSpaces: json['garageSpaces'] as int? ?? 0,
      propertyAgeYears: json['propertyAgeYears'] as int? ?? 0,
      price: json['price'] as int? ?? 0,
      tags: (json['tags'] as List<dynamic>? ?? const <dynamic>[])
          .map((tag) => tag.toString())
          .toList(),
    );
  }
}

class PropertySearchPaginationModel extends PropertySearchPaginationEntity {
  const PropertySearchPaginationModel({
    required super.page,
    required super.pageSize,
    required super.total,
    required super.totalPages,
  });

  factory PropertySearchPaginationModel.fromJson(Map<String, dynamic> json) {
    return PropertySearchPaginationModel(
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 24,
      total: json['total'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
    );
  }
}

class PropertySearchResultModel extends PropertySearchResultEntity {
  const PropertySearchResultModel({
    required super.items,
    required super.pagination,
  });

  factory PropertySearchResultModel.fromJson(Map<String, dynamic> json) {
    final items = json['items'] as List<dynamic>? ?? const <dynamic>[];
    final pagination =
        json['pagination'] as Map<String, dynamic>? ?? const <String, dynamic>{};

    return PropertySearchResultModel(
      items: items
          .cast<Map<String, dynamic>>()
          .map(SearchPropertyModel.fromJson)
          .toList(),
      pagination: PropertySearchPaginationModel.fromJson(pagination),
    );
  }
}
