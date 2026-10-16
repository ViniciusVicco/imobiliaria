import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../../broker/helpers/property_image_picker.dart';
import 'profile_avatar.dart';

/// Owns selection and local preview; persistence stays with the caller.
class ProfilePhotoEditor extends StatefulWidget {
  const ProfilePhotoEditor({
    super.key,
    required this.imageUrl,
    required this.onUpload,
    this.enabled = true,
    this.isUploading = false,
    this.size = 190,
    this.pickImage = pickPropertyImage,
  });

  final String imageUrl;
  final Future<bool> Function(PickedPropertyImage image) onUpload;
  final bool enabled;
  final bool isUploading;
  final double size;
  final Future<PickedPropertyImage?> Function() pickImage;

  @override
  State<ProfilePhotoEditor> createState() => _ProfilePhotoEditorState();
}

class _ProfilePhotoEditorState extends State<ProfilePhotoEditor> {
  Uint8List? _preview;
  String? _error;
  bool _selecting = false;
  bool _uploading = false;

  @override
  void didUpdateWidget(ProfilePhotoEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    // An external profile refresh must not retain another photo's preview.
    // The URL returned by our in-flight upload belongs to the local preview.
    if (oldWidget.imageUrl != widget.imageUrl && !_uploading) {
      _preview = null;
      _error = null;
    }
  }

  Future<void> _selectPhoto() async {
    if (_selecting || _uploading || widget.isUploading || !widget.enabled) {
      return;
    }
    final previous = _preview;
    setState(() {
      _selecting = true;
      _error = null;
    });
    try {
      final image = await widget.pickImage();
      if (!mounted || image == null) return;
      final bytes = base64Decode(image.contentBase64);
      setState(() {
        _preview = bytes;
        _uploading = true;
      });
      final saved = await widget.onUpload(image);
      if (!mounted) return;
      // Let the parent publish the confirmed URL before ending the upload.
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
      if (!saved) {
        setState(() {
          _preview = previous;
          _error = 'Não foi possível salvar a foto. Tente novamente.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _preview = previous;
          _error = 'Não foi possível atualizar a foto. Tente novamente.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _selecting = false;
          _uploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final busy = _uploading || widget.isUploading;
    final canSelect = widget.enabled && !_selecting && !busy;
    final label = busy
        ? 'Enviando foto...'
        : _preview != null || widget.imageUrl.isNotEmpty
        ? 'Alterar foto'
        : 'Adicionar foto';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          label: '$label de perfil',
          enabled: canSelect,
          child: InkWell(
            onTap: canSelect ? _selectPhoto : null,
            customBorder: const CircleBorder(),
            child: SizedBox.square(
              dimension: widget.size,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ProfileAvatar(
                    imageUrl: widget.imageUrl,
                    previewBytes: _preview,
                    size: widget.size,
                  ),
                  if (busy)
                    const ClipOval(
                      child: ColoredBox(
                        color: Color(0x66000000),
                        child: Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                    )
                  else
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            Icons.photo_camera_outlined,
                            color: colors.onPrimary,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: canSelect ? _selectPhoto : null,
          child: Text(label),
        ),
        Text(
          'Escolha uma imagem JPG, PNG ou WebP.\nA foto é salva automaticamente.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (_error != null)
          Semantics(
            liveRegion: true,
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.error),
            ),
          ),
      ],
    );
  }
}
