import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:imobiliaria/app/presentation/main/widgets/property_tag_chips.dart';

class PropertyCardImage extends StatelessWidget {
  const PropertyCardImage({
    super.key,
    required this.coverUrl,
    required this.tags,
  });

  final String coverUrl;
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          CachedNetworkImage(
            imageUrl: coverUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                const ColoredBox(color: DSColors.surfaceContainerHigh),
            errorWidget: (context, url, error) => const ColoredBox(
              color: DSColors.surfaceContainerHigh,
              child: Icon(Icons.home_work_outlined),
            ),
          ),
          const _ImageBottomScrim(),
          Positioned(
            right: DSSpacing.sm,
            bottom: DSSpacing.sm,
            left: DSSpacing.sm,
            child: Align(
              alignment: Alignment.bottomRight,
              child: PropertyTagChips.overlay(tags: tags),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageBottomScrim extends StatelessWidget {
  const _ImageBottomScrim();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0x00000000),
            Color(0x52000000),
          ],
        ),
      ),
    );
  }
}
