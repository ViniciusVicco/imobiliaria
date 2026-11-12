import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'property_image_picker_types.dart';

Future<PickedPropertyImage> _read(XFile file) async {
  final bytes = await file.readAsBytes();
  final lower = file.name.toLowerCase();
  final mime =
      file.mimeType ??
      (lower.endsWith('.png')
          ? 'image/png'
          : lower.endsWith('.webp')
          ? 'image/webp'
          : 'image/jpeg');
  return PickedPropertyImage(
    fileName: file.name,
    mimeType: mime,
    contentBase64: base64Encode(bytes),
  );
}

Future<PickedPropertyImage?> pickPropertyImageImpl() async {
  final file = await ImagePicker().pickImage(source: ImageSource.gallery);
  return file == null ? null : _read(file);
}

Future<List<PickedPropertyImage>> pickPropertyImagesImpl({
  bool camera = false,
}) async {
  final picker = ImagePicker();
  final files = camera
      ? <XFile>[
          if (await picker.pickImage(source: ImageSource.camera)
              case final XFile file)
            file,
        ]
      : await picker.pickMultiImage();
  return Future.wait(files.map(_read));
}
