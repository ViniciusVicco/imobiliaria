import 'package:flutter/material.dart';

class PropertyPhoto extends StatelessWidget {
  const PropertyPhoto({super.key, required this.url, this.fit = BoxFit.cover});
  final String url;
  final BoxFit fit;
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xff111c31),
      child: url.isEmpty
          ? const Center(
              child: Icon(Icons.image_not_supported_outlined, size: 40),
            )
          : Image.network(
              url,
              fit: fit,
              width: double.infinity,
              height: double.infinity,
              semanticLabel: 'Foto do imóvel',
              errorBuilder: (_, error, stack) => const Center(
                child: Icon(Icons.image_not_supported_outlined, size: 40),
              ),
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : const Center(child: CircularProgressIndicator()),
            ),
    );
  }
}
