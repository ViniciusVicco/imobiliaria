class PropertyDetailEntity {
  const PropertyDetailEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.images,
    required this.price,
    required this.facts,
    required this.brokerName,
    required this.whatsapp,
    required this.avatarUrl,
  });
  final String id,
      title,
      description,
      location,
      brokerName,
      whatsapp,
      avatarUrl;
  final List<String> images;
  final int price;
  final Map<String, num?> facts;
}
