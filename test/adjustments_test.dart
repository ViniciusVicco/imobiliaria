import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imobiliaria/app/data/property_segments/models/property_detail_model.dart';
import 'package:imobiliaria/app/presentation/main/pages/property_resume/widgets/property_detail_content.dart';
import 'package:imobiliaria/app/presentation/main/pages/property_segments/widgets/navigation/property_segments_top_navigation.dart';

void main() {
  for (final width in [390.0, 1440.0]) {
    testWidgets('social navigation is accessible at width $width', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(Size(width, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PropertySegmentsTopNavigation(
                onStockPressed: () {},
                onNewDevelopmentsPressed: () {},
                onContactPressed: () {},
                onAboutPressed: () {},
                onWhatsappPressed: () {},
                sessionAction: const SizedBox(),
              ),
            ),
          ),
        ),
      );
      expect(find.byTooltip('Instagram da Seletta'), findsOneWidget);
      expect(find.byTooltip('YouTube da Seletta'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('property Instagram is shown only when present', (tester) async {
    final json = <String, dynamic>{'id': '1', 'title': 'Casa', 'price': 1};
    Future<void> show(Map<String, dynamic> data) async {
      final property = PropertyDetailModel.fromJson(data);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PropertySpecsCard(
                property: property,
                onVisit: () {},
                onContact: () {},
                onShare: (_) {},
              ),
            ),
          ),
        ),
      );
    }

    await show(json);
    expect(find.text('Ver publicacao no Instagram'), findsNothing);
    await show({...json, 'instagramUrl': 'https://instagram.com/p/test/'});
    expect(find.text('Ver publicacao no Instagram'), findsOneWidget);
  });
}
