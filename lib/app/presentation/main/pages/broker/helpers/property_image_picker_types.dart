class PickedPropertyImage {
  const PickedPropertyImage({
    required this.fileName,
    required this.mimeType,
    required this.contentBase64,
  });

  final String fileName;
  final String mimeType;
  final String contentBase64;
}
