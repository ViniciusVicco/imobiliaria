import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

Uri? propertyWhatsappUri(String phone, String title, {required bool visit}) {
  var number = phone.replaceAll(RegExp(r'\D'), '');
  if (number.length == 10 || number.length == 11) number = '55$number';
  if (number.length < 12 || number.length > 15 || number.startsWith('0')) {
    return null;
  }
  return Uri.https('wa.me', '/$number', {
    'text':
        'Gostei da propriedade $title e gostaria de ${visit ? 'agendar uma visita' : 'mais informações'}',
  });
}

Future<String?> openPropertyWhatsapp(
  String phone,
  String title, {
  required bool visit,
}) async {
  final uri = propertyWhatsappUri(phone, title, visit: visit);
  if (uri == null) return 'Contato indisponível.';
  try {
    if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return null;
  } catch (_) {
    /* Report launch failures to the page. */
  }
  return 'Não foi possível abrir o WhatsApp. Tente novamente.';
}

Future<String?> shareProperty(String path, Rect origin) async {
  const publicSite = String.fromEnvironment('PUBLIC_SITE_URL');
  final base = kIsWeb ? Uri.base : Uri.tryParse(publicSite);
  if (base == null ||
      !base.hasAuthority ||
      !['https', 'http'].contains(base.scheme)) {
    return 'Link público indisponível neste aplicativo.';
  }
  final url = kIsWeb ? Uri.base.toString() : base.resolve(path).toString();
  return sharePropertyUrl(url, origin);
}

Future<String?> sharePropertyUrl(String url, Rect origin) async {
  try {
    final result = await SharePlus.instance.share(
      ShareParams(
        text: url,
        sharePositionOrigin: origin,
        downloadFallbackEnabled: false,
      ),
    );
    if (result.status != ShareResultStatus.unavailable) return null;
  } catch (_) {
    /* Unsupported platforms fall back to the clipboard. */
  }
  try {
    await Clipboard.setData(ClipboardData(text: url));
    return 'Link copiado.';
  } catch (_) {
    return 'Não foi possível copiar o link.';
  }
}
