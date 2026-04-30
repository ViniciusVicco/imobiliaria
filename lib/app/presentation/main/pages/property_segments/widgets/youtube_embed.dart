import 'package:flutter/widgets.dart';

import 'youtube_embed_stub.dart'
    if (dart.library.html) 'youtube_embed_web.dart'
    as platform;

class YoutubeEmbed extends StatelessWidget {
  const YoutubeEmbed({
    super.key,
    required this.embedUrl,
    required this.title,
    required this.fallback,
  });

  final String embedUrl;
  final String title;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    return platform.buildYoutubeEmbed(
      embedUrl: embedUrl,
      title: title,
      fallback: fallback,
    );
  }
}
