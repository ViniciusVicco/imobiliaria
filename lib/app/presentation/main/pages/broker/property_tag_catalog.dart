import 'package:legend_core/legend_core.dart';

class PropertyTagCatalog {
  PropertyTagCatalog(this._client);
  final RestClient _client;
  Future<List<PropertyTag>> load({required bool admin}) async {
    final result = await _client.get<Map<String, dynamic>>(
      admin ? '/admin/property-tags' : '/broker/property-tags',
    );
    return (result.data?['items'] as List<dynamic>? ?? [])
        .map((e) => PropertyTag.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> save(PropertyTag tag, {required bool isNew}) async {
    final data = {
      'label': tag.label,
      'description': tag.description,
      'isActive': tag.isActive,
      'sortOrder': tag.sortOrder,
    };
    if (isNew) {
      await _client.post(
        '/admin/property-tags',
        data: {'slug': tag.slug, ...data},
      );
    } else {
      await _client.patch(
        '/admin/property-tags/${Uri.encodeComponent(tag.slug)}',
        data: data,
      );
    }
  }
}

class PropertyTag {
  const PropertyTag({
    required this.slug,
    required this.label,
    this.description = '',
    this.isActive = true,
    this.sortOrder = 0,
  });
  final String slug, label, description;
  final bool isActive;
  final int sortOrder;
  factory PropertyTag.fromJson(Map<String, dynamic> json) => PropertyTag(
    slug: json['slug'] as String,
    label: json['label'] as String,
    description: json['description'] as String? ?? '',
    isActive: json['isActive'] as bool? ?? true,
    sortOrder: json['sortOrder'] as int? ?? 0,
  );
}
