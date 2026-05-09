import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/home_brand_content_entity.dart';

class PropertyVideoSection extends StatelessWidget {
  const PropertyVideoSection({
    super.key,
    required this.content,
    required this.onPressed,
  });

  final HomeBrandContentEntity? content;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final videoUrl = content?.videoUrl ?? '';
    final videoTitle = content?.videoTitle ?? 'Video da Seletta';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: DSColors.surfaceContainer,
        borderRadius: DSRadius.lg,
        border: Border.all(color: DSColors.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(videoTitle, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: DSSpacing.sm),
            Text(
              'Conheca nossa forma de apresentar oportunidades e acompanhar cada decisao.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: DSColors.onSurfaceVariant),
            ),
            const SizedBox(height: DSSpacing.md),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: DSRadius.md,
                child: ColoredBox(
                  color: DSColors.surfaceContainerHigh,
                  child: DSYoutubeEmbed(
                    url: videoUrl,
                    title: videoTitle,
                    fallback: _VideoFallback(
                      thumbnailUrl: content?.videoThumbnailUrl ?? '',
                      onPressed: onPressed,
                      enabled: videoUrl.isNotEmpty,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoFallback extends StatelessWidget {
  const _VideoFallback({
    required this.thumbnailUrl,
    required this.onPressed,
    required this.enabled,
  });

  final String thumbnailUrl;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        if (thumbnailUrl.isNotEmpty)
          CachedNetworkImage(
            imageUrl: thumbnailUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                const ColoredBox(color: DSColors.surfaceContainerHigh),
            errorWidget: (context, url, error) =>
                const ColoredBox(color: DSColors.surfaceContainerHigh),
          )
        else
          const ColoredBox(color: DSColors.surfaceContainerHigh),
        ColoredBox(color: DSColors.surface.withValues(alpha: 0.34)),
        Center(
          child: FilledButton.icon(
            onPressed: enabled ? onPressed : null,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Assistir no YouTube'),
          ),
        ),
      ],
    );
  }
}
