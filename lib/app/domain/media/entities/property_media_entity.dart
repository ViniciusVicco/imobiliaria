class PropertyMediaEntity {
  const PropertyMediaEntity({
    required this.id,
    required this.propertyId,
    required this.url,
    required this.publicUrl,
    required this.storageKey,
    required this.type,
    required this.status,
    required this.mimeType,
    required this.sizeBytes,
    required this.sortOrder,
    this.pendingDeleteAt,
    this.deletedAt,
  });

  final String id;
  final String propertyId;
  final String url;
  final String publicUrl;
  final String storageKey;
  final String type;
  final String status;
  final String mimeType;
  final int sizeBytes;
  final int sortOrder;
  final String? pendingDeleteAt;
  final String? deletedAt;

  bool get isImage => type == 'image';
  bool get isActive => status == 'active';
}

class PropertyImageUploadEntity {
  const PropertyImageUploadEntity({
    required this.fileName,
    required this.mimeType,
    required this.contentBase64,
  });

  final String fileName;
  final String mimeType;
  final String contentBase64;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'fileName': fileName,
      'mimeType': mimeType,
      'contentBase64': contentBase64,
    };
  }
}
