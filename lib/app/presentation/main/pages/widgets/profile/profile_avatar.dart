import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Shared circular photo for profile editing and public broker presentation.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.imageUrl,
    this.previewBytes,
    this.size = 56,
    this.borderColor,
  });

  final String imageUrl;
  final Uint8List? previewBytes;
  final double size;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final fallback = ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(child: Icon(Icons.person_outline, size: size * .4)),
    );
    Widget failedImage(BuildContext context, Object error, StackTrace? stack) =>
        Tooltip(message: 'Não foi possível carregar a foto.', child: fallback);
    final photo = previewBytes != null
        ? Image.memory(
            previewBytes!,
            fit: BoxFit.cover,
            errorBuilder: failedImage,
          )
        : imageUrl.isEmpty
        ? fallback
        : Image.network(
            imageUrl,
            key: ValueKey(imageUrl),
            webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
            fit: BoxFit.cover,
            errorBuilder: failedImage,
            loadingBuilder: (context, child, progress) => progress == null
                ? child
                : Center(
                    child: SizedBox.square(
                      dimension: size * .3,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
          );

    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: borderColor == null ? null : Border.all(color: borderColor!),
        ),
        child: ClipOval(child: photo),
      ),
    );
  }
}
