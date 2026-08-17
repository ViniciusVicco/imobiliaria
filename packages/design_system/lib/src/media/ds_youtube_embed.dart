import 'package:flutter/widgets.dart';

import 'ds_youtube_embed_stub.dart'
    if (dart.library.html) 'ds_youtube_embed_web.dart'
    as platform;

class DSYoutubeEmbed extends StatelessWidget {
  const DSYoutubeEmbed({
    super.key,
    required this.url,
    required this.title,
    required this.fallback,
  });

  final String url;
  final String title;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    return platform.buildYoutubeEmbed(
      embedUrl: _toYoutubeEmbedUrl(url),
      title: title,
      fallback: fallback,
    );
  }

  String _toYoutubeEmbedUrl(String url) {
    final videoId = _extractYoutubeVideoId(url);
    if (videoId == null) return '';
    return 'https://www.youtube.com/embed/$videoId?rel=0&modestbranding=1';
  }

  String? _extractYoutubeVideoId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    if (uri.host.contains('youtu.be') && uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.first;
    }

    if (uri.host.contains('youtube.com')) {
      final videoId = uri.queryParameters['v'];
      if (videoId != null && videoId.isNotEmpty) return videoId;

      final embedIndex = uri.pathSegments.indexOf('embed');
      if (embedIndex != -1 && uri.pathSegments.length > embedIndex + 1) {
        return uri.pathSegments[embedIndex + 1];
      }
    }

    return null;
  }
}
