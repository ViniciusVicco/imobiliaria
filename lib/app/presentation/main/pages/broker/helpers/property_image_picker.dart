import 'property_image_picker_stub.dart'
    if (dart.library.html) 'property_image_picker_web.dart';
import 'property_image_picker_types.dart';

export 'property_image_picker_types.dart';

Future<PickedPropertyImage?> pickPropertyImage() => pickPropertyImageImpl();

Future<List<PickedPropertyImage>> pickPropertyImages() =>
    pickPropertyImagesImpl();
