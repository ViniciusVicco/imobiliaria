import 'dart:io';
import 'dart:ui' as ui;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/brand_institutional_content.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/home_brand_content_entity.dart';
import 'package:imobiliaria/app/presentation/main/pages/property_segments/widgets/brand/property_brand_cards_section.dart';
import 'package:imobiliaria/app/presentation/main/pages/property_segments/widgets/brand/property_brand_reveal.dart';

const _content = HomeBrandContentEntity(
  mission: 'Nossa missão',
  about:
      'Conheça a Seletta e nossa forma de cuidar de cada decisão imobiliária.',
  vision: 'Nossa visão',
  values: ['Transparência em cada decisão.', 'Conhecimento que orienta.'],
  contact: HomeContactEntity(
    phone: '123456',
    email: 'contato@seletta.com.br',
    whatsapp: '',
  ),
  videoProvider: '',
  videoTitle: '',
  videoThumbnailUrl: '',
  videoUrl: '',
);

class _Harness {
  final about = GlobalKey();
  final mission = GlobalKey();
  final contact = GlobalKey();
  final capture = GlobalKey();
  final scroll = ScrollController();

  Widget build({
    HomeBrandContentEntity? content = _content,
    bool reduced = false,
    double before = 0,
    double scale = 1,
  }) => MaterialApp(
    theme: DSTheme.dark,
    home: MediaQuery(
      data: MediaQueryData(
        disableAnimations: reduced,
        textScaler: TextScaler.linear(scale),
      ),
      child: Scaffold(
        body: CustomScrollView(
          controller: scroll,
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(height: before),
                  RepaintBoundary(
                    key: capture,
                    child: ColoredBox(
                      color: DSColors.surface,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: PropertyBrandCardsSection(
                          aboutKey: about,
                          missionKey: mission,
                          contactKey: contact,
                          content: content,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

double _opacity(WidgetTester tester, String text) {
  final reveal = find
      .ancestor(of: find.text(text), matching: find.byType(PropertyBrandReveal))
      .first;
  return tester
      .widget<Opacity>(
        find.descendant(of: reveal, matching: find.byType(Opacity)).first,
      )
      .opacity;
}

Future<void> _finishAnimations(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 250));
  await tester.pumpAndSettle();
}

void main() {
  if (const bool.fromEnvironment('FOOTER_SCREENSHOTS')) {
    setUpAll(() async {
      final icons = FontLoader('MaterialIcons');
      icons.addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icons.load();
      // Optional local fallback fonts keep preview captures readable without
      // introducing asset or network dependencies into normal widget tests.
      for (final entry in {
        'Manrope': const String.fromEnvironment('FOOTER_BODY_FONT'),
        'Noto Serif': const String.fromEnvironment('FOOTER_HEADING_FONT'),
      }.entries) {
        if (entry.value.isEmpty) continue;
        final loader = FontLoader(entry.key);
        loader.addFont(
          File(
            entry.value,
          ).readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
        );
        await loader.load();
      }
    });
  }
  testWidgets(
    'reveals on intersection and does not replay after scrolling or rebuilding',
    (tester) async {
      final harness = _Harness();
      addTearDown(harness.scroll.dispose);
      await tester.pumpWidget(harness.build(before: 900));
      expect(_opacity(tester, 'Sobre nós'), 0);
      harness.scroll.jumpTo(700);
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(_opacity(tester, 'Sobre nós'), greaterThan(0));
      expect(_opacity(tester, 'Sobre nós'), lessThan(1));
      await _finishAnimations(tester);
      harness.scroll.jumpTo(0);
      await tester.pumpWidget(harness.build(before: 900));
      expect(_opacity(tester, 'Sobre nós'), 1);
      harness.scroll.jumpTo(700);
      await tester.pump();
      expect(_opacity(tester, 'Sobre nós'), 1);
    },
  );

  testWidgets(
    'anchors reach their stationary destinations, including fast jumps',
    (tester) async {
      final harness = _Harness();
      addTearDown(harness.scroll.dispose);
      await tester.pumpWidget(harness.build(before: 900));
      for (final (key, title) in [
        (harness.about, 'Sobre nós'),
        (harness.mission, 'Missão'),
        (harness.contact, 'Contatos'),
      ]) {
        await Scrollable.ensureVisible(
          key.currentContext!,
          duration: Duration.zero,
        );
        await tester.pump();
        await _finishAnimations(tester);
        expect(_opacity(tester, title), 1);
        final bounds = tester.getRect(find.byKey(key));
        expect(bounds.bottom, greaterThan(0));
        expect(bounds.top, lessThan(600));
      }
    },
  );

  testWidgets('reduced motion immediately exposes even offscreen content', (
    tester,
  ) async {
    final harness = _Harness();
    addTearDown(harness.scroll.dispose);
    await tester.pumpWidget(harness.build(before: 900, reduced: true));
    expect(_opacity(tester, 'Missão'), 1);
    expect(_opacity(tester, 'Contatos'), 1);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets(
    'empty fields use fallbacks and asynchronously arriving contacts appear',
    (tester) async {
      final harness = _Harness();
      addTearDown(harness.scroll.dispose);
      const empty = HomeBrandContentEntity(
        mission: ' ',
        about: '',
        vision: '',
        values: [' '],
        contact: HomeContactEntity(phone: '', email: '', whatsapp: ''),
        videoProvider: '',
        videoTitle: '',
        videoThumbnailUrl: '',
        videoUrl: '',
      );
      await tester.pumpWidget(harness.build(content: empty));
      await _finishAnimations(tester);
      expect(find.text(BrandInstitutionalContent.mission), findsOneWidget);
      expect(find.text(BrandInstitutionalContent.vision), findsOneWidget);
      expect(find.text(BrandInstitutionalContent.values.first), findsOneWidget);
      expect(find.text('Contatos'), findsNothing);
      expect(harness.contact.currentContext, isNotNull);
      await tester.pumpWidget(harness.build());
      await Scrollable.ensureVisible(harness.contact.currentContext!);
      await tester.pump();
      await _finishAnimations(tester);
      expect(_opacity(tester, 'Contatos'), 1);
      expect(find.text(_content.about), findsOneWidget);
      expect(find.text('WhatsApp'), findsNothing);
    },
  );

  testWidgets(
    'disposing with pending stagger and changing motion preference is safe',
    (tester) async {
      final harness = _Harness();
      addTearDown(harness.scroll.dispose);
      await tester.pumpWidget(harness.build());
      await tester.pump(const Duration(milliseconds: 40));
      await tester.pumpWidget(harness.build(reduced: true));
      expect(_opacity(tester, 'Missão'), 1);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(harness.build());
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
    },
  );

  for (final width in [320.0, 860.0, 1440.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
        'layout fits ${width}px at text scale $scale and tall cards reveal',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = Size(width, 800);
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final harness = _Harness();
          addTearDown(harness.scroll.dispose);
          await tester.pumpWidget(harness.build(content: null, scale: scale));
          await Scrollable.ensureVisible(harness.mission.currentContext!);
          await tester.pump();
          await _finishAnimations(tester);
          expect(_opacity(tester, 'Missão'), 1);
          final missionRect = tester.getRect(find.byKey(harness.mission));
          final visionRect = tester.getRect(
            find.ancestor(
              of: find.text('Visão'),
              matching: find.byType(PropertyBrandReveal),
            ),
          );
          if (width - 32 >= 860) {
            expect(missionRect.top, visionRect.top);
          } else {
            expect(visionRect.top, greaterThanOrEqualTo(missionRect.bottom));
          }
          expect(tester.takeException(), isNull);

          if (const bool.fromEnvironment('FOOTER_SCREENSHOTS')) {
            await tester.pumpWidget(
              harness.build(
                content: HomeBrandContentEntity(
                  mission: BrandInstitutionalContent.mission,
                  about: _content.about,
                  contact: _content.contact,
                  videoProvider: '',
                  videoTitle: '',
                  videoThumbnailUrl: '',
                  videoUrl: '',
                ),
                scale: scale,
                reduced: true,
              ),
            );
            await tester.pumpAndSettle();
            final boundary =
                harness.capture.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            await tester.runAsync(() async {
              final image = await boundary.toImage();
              final bytes = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              final file = File(
                'build/footer-previews/footer-${width.toInt()}-${scale.toInt()}x.png',
              );
              await file.parent.create(recursive: true);
              await file.writeAsBytes(bytes!.buffer.asUint8List());
              image.dispose();
            });
          }
        },
      );
    }
  }

  testWidgets('resizing reveals new blocks without resetting visible blocks', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 800);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final harness = _Harness();
    addTearDown(harness.scroll.dispose);
    await tester.pumpWidget(harness.build());
    await _finishAnimations(tester);
    expect(_opacity(tester, 'Missão'), 1);
    tester.view.physicalSize = const Size(1440, 1600);
    await tester.pump();
    expect(_opacity(tester, 'Missão'), 1);
    await _finishAnimations(tester);
    expect(_opacity(tester, 'Contatos'), 1);
    expect(tester.takeException(), isNull);
  });
}
