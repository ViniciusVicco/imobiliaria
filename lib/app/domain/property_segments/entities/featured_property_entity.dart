class FeaturedPropertyEntity {
  const FeaturedPropertyEntity({
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
    this.tags = const <String>[],
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
  final List<String> tags;
}
