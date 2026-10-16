import 'package:imobiliaria/app/domain/media/entities/property_media_entity.dart';

class PropertyMediaModel extends PropertyMediaEntity {
  const PropertyMediaModel({
    required super.id,
    required super.propertyId,
    required super.url,
    required super.publicUrl,
    required super.storageKey,
    required super.type,
    required super.status,
    required super.mimeType,
    required super.sizeBytes,
    required super.sortOrder,
    super.pendingDeleteAt,
    super.deletedAt,
  });

  factory PropertyMediaModel.fromJson(Map<String, dynamic> json) {
    return PropertyMediaModel(
      id: json['id'] as String? ?? '',
      propertyId: json['propertyId'] as String? ?? '',
      url: json['url'] as String? ?? '',
      publicUrl: json['publicUrl'] as String? ?? json['url'] as String? ?? '',
      storageKey: json['storageKey'] as String? ?? '',
      type: json['type'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      mimeType: json['mimeType'] as String? ?? '',
      sizeBytes: json['sizeBytes'] as int? ?? 0,
      sortOrder: json['sortOrder'] as int? ?? 0,
      pendingDeleteAt: json['pendingDeleteAt'] as String?,
      deletedAt: json['deletedAt'] as String?,
    );
  }
}
