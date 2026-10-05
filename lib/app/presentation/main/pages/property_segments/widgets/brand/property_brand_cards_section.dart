import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/brand_institutional_content.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/home_brand_content_entity.dart';

class PropertyBrandCardsSection extends StatelessWidget {
  const PropertyBrandCardsSection({
    super.key,
    required this.contactKey,
    required this.aboutKey,
    required this.missionKey,
    required this.content,
  });

  final GlobalKey contactKey;
  final GlobalKey aboutKey;
  final GlobalKey missionKey;
  final HomeBrandContentEntity? content;

  @override
  Widget build(BuildContext context) {
    final contact = content?.contact;
    final values = content?.values ?? BrandInstitutionalContent.values;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Sobre nós',
          key: aboutKey,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: DSSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            final cards = <Widget>[
              DSInfoCard(
                key: missionKey,
                title: 'Missão',
                body: content?.mission ?? BrandInstitutionalContent.mission,
              ),
              DSInfoCard(
                title: 'Visão',
                body: content?.vision ?? BrandInstitutionalContent.vision,
              ),
            ];
            if (constraints.maxWidth < 860) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  cards.first,
                  const SizedBox(height: DSSpacing.md),
                  cards.last,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: cards.first),
                const SizedBox(width: DSSpacing.md),
                Expanded(child: cards.last),
              ],
            );
          },
        ),
        const SizedBox(height: DSSpacing.md),
        DSInfoCard(
          title: 'Valores',
          body: [
            for (var index = 0; index < values.length; index++)
              '${index + 1}. ${values[index]}',
          ].join('\n\n'),
        ),
        const SizedBox(height: DSSpacing.md),
        DSInfoCard(
          key: contactKey,
          title: 'Contatos',
          body:
              '${contact?.phone ?? ''}\n${contact?.whatsapp ?? ''}\n${contact?.email ?? ''}',
        ),
      ],
    );
  }
}
