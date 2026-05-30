class SearchPropertyEntity {
  const SearchPropertyEntity({
    required this.id,
    required this.title,
    required this.segment,
    required this.propertyType,
    required this.city,
    required this.neighborhood,
    required this.subNeighborhood,
    required this.coverUrl,
    required this.areaM2,
    required this.bathrooms,
    required this.garageSpaces,
    required this.propertyAgeYears,
    required this.price,
    this.bedrooms,
  });

  final String id;
  final String title;
  final String segment;
  final String propertyType;
  final String city;
  final String neighborhood;
  final String subNeighborhood;
  final String coverUrl;
  final int areaM2;
  final int? bedrooms;
  final int bathrooms;
  final int garageSpaces;
  final int propertyAgeYears;
  final int price;
}

class PropertySearchPaginationEntity {
  const PropertySearchPaginationEntity({
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

class PropertySearchResultEntity {
  const PropertySearchResultEntity({
    required this.items,
    required this.pagination,
  });

  final List<SearchPropertyEntity> items;
  final PropertySearchPaginationEntity pagination;
}
