import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../../broker/helpers/property_image_picker_types.dart';

/// Picks a photo from gallery and opens a 1:1 cropper.
/// Returns [PickedPropertyImage] on success, null if cancelled.
Future<PickedPropertyImage?> pickAndCropAvatar(BuildContext context) async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(source: ImageSource.gallery);
  if (picked == null) return null;

  // Capture context-dependent values before the async gap.
  // ignore: use_build_context_synchronously
  if (!context.mounted) return null;
  final webContext = context;

  final cropped = await ImageCropper().cropImage(
    sourcePath: picked.path,
    aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Enquadrar foto',
        toolbarColor: const Color(0xFF0D1B2A),
        toolbarWidgetColor: const Color(0xFFC9A84C),
        backgroundColor: const Color(0xFF0D1B2A),
        cropFrameColor: const Color(0xFFC9A84C),
        activeControlsWidgetColor: const Color(0xFFC9A84C),
        lockAspectRatio: true,
      ),
      IOSUiSettings(
        title: 'Enquadrar foto',
        aspectRatioLockEnabled: true,
        resetAspectRatioEnabled: false,
      ),
      WebUiSettings(
        context: webContext,
        presentStyle: WebPresentStyle.dialog,
        size: const CropperSize(width: 520, height: 520),
        viewwMode: WebViewMode.mode_1,
        initialAspectRatio: 1.0,
        movable: true,
        zoomable: true,
        checkCrossOrigin: false,
      ),
    ],
  );

  if (cropped == null) return null;

  final bytes = kIsWeb
      ? await cropped.readAsBytes()
      : await File(cropped.path).readAsBytes();

  final mimeType = _mimeFromPath(cropped.path);
  return PickedPropertyImage(
    fileName: 'avatar.${mimeType.split('/').last}',
    mimeType: mimeType,
    contentBase64: base64Encode(bytes),
  );
}

String _mimeFromPath(String path) {
  final ext = path.split('.').last.toLowerCase();
  return switch (ext) {
    'png' => 'image/png',
    'webp' => 'image/webp',
    _ => 'image/jpeg',
  };
}
