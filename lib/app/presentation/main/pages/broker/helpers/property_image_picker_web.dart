import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

import 'property_image_picker_types.dart';

Future<PickedPropertyImage?> pickPropertyImageImpl() async {
  final images = await pickPropertyImagesImpl();
  return images.isEmpty ? null : images.first;
}

Future<List<PickedPropertyImage>> pickPropertyImagesImpl() async {
  final input = html.FileUploadInputElement()
    ..accept = 'image/jpeg,image/png,image/webp'
    ..multiple = true;
  input.click();

  await input.onChange.first;
  final files = input.files ?? const <html.File>[];
  if (files.isEmpty) return const <PickedPropertyImage>[];

  final images = <PickedPropertyImage>[];
  for (final file in files) {
    final image = await _readFile(file);
    images.add(image);
  }

  return images;
}

Future<PickedPropertyImage> _readFile(html.File file) async {
  final reader = html.FileReader();
  reader.readAsArrayBuffer(file);
  await reader.onLoad.first;

  final result = reader.result;
  final bytes = result is ByteBuffer
      ? Uint8List.view(result)
      : result as List<int>;
  return PickedPropertyImage(
    fileName: file.name,
    mimeType: file.type,
    contentBase64: base64Encode(bytes),
  );
}
