// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:ui_web' as ui;

import 'package:flutter/widgets.dart';

final Set<String> _registeredViewTypes = <String>{};

Widget buildYoutubeEmbed({
  required String embedUrl,
  required String title,
  required Widget fallback,
}) {
  if (embedUrl.isEmpty) return fallback;

  final viewType = 'youtube-embed-${embedUrl.hashCode}';
  if (_registeredViewTypes.add(viewType)) {
    ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      return html.IFrameElement()
        ..src = embedUrl
        ..title = title
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allow =
            'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share'
        ..allowFullscreen = true;
    });
  }

  return HtmlElementView(viewType: viewType);
}
