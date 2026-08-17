import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 860 ? 3 : 1;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: columns,
          mainAxisSpacing: DSSpacing.md,
          crossAxisSpacing: DSSpacing.md,
          childAspectRatio: columns == 1 ? 2.4 : 1.18,
          children: <Widget>[
            DSInfoCard(
              key: contactKey,
              title: 'Contatos',
              body:
                  '${contact?.phone ?? ''}\n${contact?.whatsapp ?? ''}\n${contact?.email ?? ''}',
            ),
            DSInfoCard(
              key: aboutKey,
              title: 'Sobre nos',
              body:
                  content?.about ??
                  'Curadoria imobiliaria para clientes que valorizam contexto, criterio e clareza.',
            ),
            DSInfoCard(
              key: missionKey,
              title: 'Missao',
              body:
                  content?.mission ??
                  'Conectar pessoas a imoveis com uma experiencia humana e objetiva.',
            ),
          ],
        );
      },
    );
  }
}
