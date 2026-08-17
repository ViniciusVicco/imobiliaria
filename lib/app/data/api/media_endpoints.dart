mixin class MediaEndpoints {
  String get temporaryPropertyImages => '/media/property-images/temp';

  String propertyImages(String propertyId) =>
      '/media/properties/$propertyId/images';

  String mediaCover(String mediaId) => '/media/$mediaId/cover';

  String mediaFile(String mediaId) => '/media/$mediaId/file';

  String mediaPendingDelete(String mediaId) => '/media/$mediaId/pending-delete';

  String mediaRestore(String mediaId) => '/media/$mediaId/restore';
}
