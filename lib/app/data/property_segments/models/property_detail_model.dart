import 'package:imobiliaria/app/domain/property_segments/entities/property_detail_entity.dart';

abstract final class PropertyDetailModel {
  static PropertyDetailEntity fromJson(Map<String, dynamic> json) {
    final broker = json['brokerContact'] as Map<String, dynamic>? ?? {};
    final media =
        (json['media'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>()
            .where((m) => m['type'] == 'image')
            .toList()
          ..sort(
            (a, b) => ((a['sortOrder'] as num?) ?? 0).compareTo(
              (b['sortOrder'] as num?) ?? 0,
            ),
          );
    final cover = json['coverUrl'] as String? ?? '';
    final images = <String>{
      if (cover.isNotEmpty) cover,
      ...media
          .map((m) => m['url'] as String? ?? '')
          .where((url) => url.isNotEmpty),
    };
    return PropertyDetailEntity(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      location: ['subNeighborhood', 'neighborhood', 'city']
          .map((key) => (json[key] as String? ?? '').trim())
          .where((s) => s.isNotEmpty)
          .join(' - '),
      images: images.toList(),
      price: (json['price'] as num).toInt(),
      facts: (json['facts'] as Map<String, dynamic>? ?? {}).map(
        (key, value) => MapEntry(key, value as num?),
      ),
      brokerName: broker['name'] as String? ?? 'Seletta',
      whatsapp: broker['whatsapp'] as String? ?? '',
      avatarUrl: broker['avatarUrl'] as String? ?? '',
    );
  }
}
