import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

import 'property_image_picker_types.dart';

Future<PickedPropertyImage?> pickPropertyImageImpl() async {
  final images = await _pickImages(multiple: false);
  return images.isEmpty ? null : images.first;
}

Future<List<PickedPropertyImage>> pickPropertyImagesImpl() =>
    _pickImages(multiple: true);

Future<List<PickedPropertyImage>> _pickImages({required bool multiple}) async {
  final input = html.FileUploadInputElement()
    ..accept = 'image/jpeg,image/png,image/webp'
    ..multiple = multiple;
  final selected = Completer<void>();
  void complete(html.Event _) {
    if (!selected.isCompleted) selected.complete();
  }

  input.addEventListener('change', complete);
  input.addEventListener('cancel', complete);
  try {
    input.click();
    await selected.future;
    final files = input.files ?? const <html.File>[];
    return await Future.wait(files.map(_readFile));
  } finally {
    input.removeEventListener('change', complete);
    input.removeEventListener('cancel', complete);
    input.remove();
  }
}

Future<PickedPropertyImage> _readFile(html.File file) async {
  final reader = html.FileReader();
  reader.readAsArrayBuffer(file);
  await Future.any([
    reader.onLoad.first,
    reader.onError.first.then((_) => throw StateError('Falha ao ler imagem.')),
  ]);

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
