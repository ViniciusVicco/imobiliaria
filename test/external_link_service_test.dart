import 'package:flutter_test/flutter_test.dart';
import 'package:imobiliaria/app/domain/outbound_links/external_link_service.dart';

void main() {
  test('opens first, then records an accepted external click', () async {
    final calls = <String>[];
    final service = ExternalLinkService(
      launch: (uri) async {
        calls.add('open:$uri');
        return true;
      },
      record: (uri, source, propertyId) async {
        calls.add('record:$source:$propertyId');
      },
    );
    expect(
      await service.open('https://youtube.com/test', source: 'home_video'),
      isTrue,
    );
    expect(calls, ['open:https://youtube.com/test', 'record:home_video:null']);
  });

  test('rejects unsafe URLs and does not record failed launches', () async {
    var records = 0;
    final service = ExternalLinkService(
      launch: (_) async => false,
      record: (_, _, _) async {
        records++;
      },
    );
    expect(
      await service.open('javascript:alert(1)', source: 'home_video'),
      isFalse,
    );
    expect(
      await service.open('https://youtube.com/test', source: 'home_video'),
      isFalse,
    );
    expect(records, 0);
  });

  test('a recording failure does not change a successful launch', () async {
    final service = ExternalLinkService(
      launch: (_) async => true,
      record: (_, _, _) async => throw StateError('network unavailable'),
    );
    expect(
      await service.open(
        'https://instagram.com/test',
        source: 'header_instagram',
      ),
      isTrue,
    );
    await Future<void>.delayed(Duration.zero);
  });
}
