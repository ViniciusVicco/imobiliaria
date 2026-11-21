import 'dart:async';

typedef ExternalLauncher = Future<bool> Function(Uri uri);
typedef ClickRecorder =
    Future<void> Function(Uri uri, String source, String? propertyId);

class ExternalLinkService {
  const ExternalLinkService({required this.launch, required this.record});

  final ExternalLauncher launch;
  final ClickRecorder record;

  Future<bool> open(
    String url, {
    required String source,
    String? propertyId,
  }) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        !uri.hasAuthority ||
        uri.host.isEmpty) {
      return false;
    }
    try {
      final opened = await launch(uri);
      if (opened) {
        unawaited(
          Future.sync(
            () => record(uri, source, propertyId),
          ).catchError((Object _) {}),
        );
      }
      return opened;
    } catch (_) {
      return false;
    }
  }
}
