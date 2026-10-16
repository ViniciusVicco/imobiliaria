import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imobiliaria/app/data/property_segments/models/property_detail_model.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/featured_property_entity.dart';
import 'package:imobiliaria/app/presentation/main/pages/property_resume/property_resume_actions.dart';
import 'package:imobiliaria/app/presentation/main/pages/property_resume/widgets/property_detail_content.dart';
import 'package:imobiliaria/app/presentation/main/pages/property_resume/widgets/property_gallery.dart';
import 'package:imobiliaria/app/presentation/main/pages/property_resume/widgets/property_photo.dart';
import 'package:imobiliaria/app/presentation/main/pages/property_segments/widgets/featured_properties/featured_properties_section.dart';
import 'package:imobiliaria/app/presentation/main/pages/widgets/property/property_card_image.dart';

Map<String, dynamic> detailJson({int photos = 0}) => {
  'id': 'property-123',
  'title':
      'Casa com piscina e espaço gourmet na região sul de Palmas com acabamento especial',
  'description': 'Descrição completa do imóvel.',
  'neighborhood': 'Plano Diretor Sul',
  'subNeighborhood': '1601 Sul',
  'city': 'Palmas',
  'price': 820000,
  'coverUrl': photos == 0 ? '' : 'https://example.com/0.jpg',
  'media': List.generate(
    photos,
    (i) => {
      'url': 'https://example.com/$i.jpg',
      'type': 'image',
      'sortOrder': i,
    },
  ),
  'facts': {
    'privateAreaM2': 130,
    'totalAreaM2': 252,
    'bedrooms': 3,
    'bathrooms': 2,
    'garageSpaces': 2,
    'propertyAgeYears': 1,
  },
  'brokerContact': {'name': 'Ricardo Almeida', 'whatsapp': '63999999999'},
};

void main() {
  testWidgets(
    'sharing falls back to clipboard only when unavailable, not cancelled',
    (tester) async {
      const channel = MethodChannel('dev.fluttercommunity.plus/share');
      var status = 'dev.fluttercommunity.plus/share/unavailable';
      String? shared;
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        call,
      ) async {
        shared = (call.arguments as Map)['text'] as String;
        return status;
      });
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String;
          }
          return null;
        },
      );
      addTearDown(() {
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        );
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        );
      });
      const url = 'https://example.com/imovel/property-123';
      expect(
        await sharePropertyUrl(url, const Rect.fromLTWH(1, 1, 48, 48)),
        'Link copiado.',
      );
      expect(shared, url);
      expect(copied, url);
      copied = null;
      status = '';
      expect(
        await sharePropertyUrl(url, const Rect.fromLTWH(1, 1, 48, 48)),
        isNull,
      );
      expect(copied, isNull);
    },
  );
  test(
    'detail orders cover first, removes duplicate cover, ignores videos',
    () {
      final json = detailJson(photos: 4);
      json['coverUrl'] = 'https://example.com/2.jpg';
      (json['media'] as List).add({'url': 'video.mp4', 'type': 'video'});
      final property = PropertyDetailModel.fromJson(json);
      expect(property.images.length, 4);
      expect(property.images.first, 'https://example.com/2.jpg');
      expect(property.facts['privateAreaM2'], 130);
      expect(property.avatarUrl, isEmpty);
    },
  );

  test(
    'WhatsApp preserves accents and punctuation and normalizes Brazilian number',
    () {
      const title = 'Casa & área gourmet #1';
      final visit = propertyWhatsappUri('(63) 99999-9999', title, visit: true)!;
      expect(visit.path, '/5563999999999');
      expect(
        visit.queryParameters['text'],
        'Gostei da propriedade $title e gostaria de agendar uma visita',
      );
      final contact = propertyWhatsappUri(
        '+55 63 99999-9999',
        title,
        visit: false,
      )!;
      expect(
        contact.queryParameters['text'],
        'Gostei da propriedade $title e gostaria de mais informações',
      );
      expect(propertyWhatsappUri('', title, visit: false), isNull);
      expect(propertyWhatsappUri('123', title, visit: false), isNull);
    },
  );

  for (final width in [360.0, 390.0, 768.0, 1024.0, 1440.0]) {
    for (final scale in [1.0, 1.6]) {
      testWidgets('detail layout at $width px and text scale $scale', (
        tester,
      ) async {
        tester.view.reset();
        tester.view.physicalSize = Size(width, 1100);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          MaterialApp(
            theme: DSTheme.dark,
            home: Scaffold(
              body: MediaQuery(
                data: MediaQueryData(
                  size: Size(width, 1100),
                  textScaler: TextScaler.linear(scale),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: PropertyDetailContent(
                      property: PropertyDetailModel.fromJson(detailJson()),
                      desktop: width >= 1024,
                      onVisit: () {},
                      onContact: () {},
                      onShare: (_) {},
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final gallery = tester.getTopLeft(find.byType(PropertyGallery));
        final specs = tester.getTopLeft(find.byType(PropertySpecsCard));
        if (width < 1024) {
          expect(specs.dy, greaterThan(gallery.dy));
        } else {
          expect(specs.dx, greaterThan(gallery.dx));
        }
      });
    }
  }

  for (final count in [0, 1, 2, 3, 4, 5, 12]) {
    testWidgets('gallery supports $count images and opens full viewer', (
      tester,
    ) async {
      final images = List.generate(count, (_) => '');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 600,
              child: PropertyGallery(images: images, desktop: true),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      if (count > 0) {
        await tester.tap(find.byType(PropertyPhoto).first);
        await tester.pumpAndSettle();
        expect(find.byType(PropertyPhotoViewer), findsOneWidget);
        if (count > 1) {
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
          await tester.pumpAndSettle();
          expect(find.text('2 / $count'), findsOneWidget);
        }
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(find.byType(PropertyPhotoViewer), findsNothing);
      }
    });
  }

  testWidgets(
    'Home card opens exact ID from image, title, facts and whitespace; WhatsApp stays independent',
    (tester) async {
      tester.view.physicalSize = const Size(390, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final opened = <String>[];
      final contacts = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: FeaturedPropertiesSection(
                properties: const [
                  FeaturedPropertyEntity(
                    id: 'exact-id',
                    title: 'Casa teste',
                    segment: 'residential',
                    propertyType: 'Casa',
                    city: 'Palmas',
                    neighborhood: 'Sul',
                    subNeighborhood: '',
                    coverUrl: '',
                    areaM2: 130,
                    bathrooms: 2,
                    garageSpaces: 2,
                    propertyAgeYears: 3,
                    price: 820000,
                  ),
                ],
                onPropertyPressed: (p) => opened.add(p.id),
                onMoreInfoPressed: (p) => contacts.add(p.id),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(PropertyCardImage));
      await tester.tap(find.text('Casa teste'));
      await tester.tap(find.text('130 m2'));
      final card = tester.getRect(find.byType(InkWell).first);
      await tester.tapAt(Offset(card.left + 4, card.bottom - 4));
      expect(opened, ['exact-id', 'exact-id', 'exact-id', 'exact-id']);
      await tester.tap(find.text('Quero mais informacoes'));
      expect(contacts, ['exact-id']);
      expect(opened.length, 4);
      final ink = tester.widget<InkWell>(find.byType(InkWell).first);
      expect(ink.canRequestFocus, isTrue);
      expect(tester.takeException(), isNull);
    },
  );
}
