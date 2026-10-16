import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/brand_institutional_content.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/home_brand_content_entity.dart';

import 'property_brand_reveal.dart';

class PropertyBrandCardsSection extends StatefulWidget {
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
  State<PropertyBrandCardsSection> createState() =>
      _PropertyBrandCardsSectionState();
}

class _PropertyBrandCardsSectionState extends State<PropertyBrandCardsSection> {
  final _revealBatch = BrandRevealBatch();

  String _textOrFallback(String? text, String fallback) =>
      text == null || text.trim().isEmpty ? fallback : text;

  Widget _reveal(String id, Widget child, {GlobalKey? anchor}) => SizedBox(
    key: anchor ?? ValueKey(id),
    child: PropertyBrandReveal(batch: _revealBatch, child: child),
  );

  @override
  Widget build(BuildContext context) {
    final content = widget.content;
    final about = content?.about.trim() ?? '';
    final suppliedValues = content?.values
        .where((value) => value.trim().isNotEmpty)
        .toList();
    final values = suppliedValues == null || suppliedValues.isEmpty
        ? BrandInstitutionalContent.values
        : suppliedValues;
    final contact = content?.contact;
    final contacts = <(String, String)>[
      ('Telefone', contact?.phone.trim() ?? ''),
      ('WhatsApp', contact?.whatsapp.trim() ?? ''),
      ('E-mail', contact?.email.trim() ?? ''),
    ].where((entry) => entry.$2.isNotEmpty).toList();
    final typography = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.xxl + DSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _reveal(
            'about',
            Container(
              padding: const EdgeInsets.symmetric(vertical: DSSpacing.xl),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: DSColors.primary)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NOSSA ESSÊNCIA',
                    style: typography.labelSmall?.copyWith(
                      color: DSColors.primary,
                    ),
                  ),
                  const SizedBox(height: DSSpacing.md),
                  Text('Sobre nós', style: typography.headlineMedium),
                  if (about.isNotEmpty) ...[
                    const SizedBox(height: DSSpacing.lg),
                    Text(about, style: typography.bodyLarge),
                  ],
                ],
              ),
            ),
            anchor: widget.aboutKey,
          ),
          _BrandGrid(
            children: [
              _reveal(
                'mission',
                _InstitutionalCard(
                  title: 'Missão',
                  icon: Icons.explore_outlined,
                  body: _textOrFallback(
                    content?.mission,
                    BrandInstitutionalContent.mission,
                  ),
                ),
                anchor: widget.missionKey,
              ),
              _reveal(
                'vision',
                _InstitutionalCard(
                  title: 'Visão',
                  icon: Icons.visibility_outlined,
                  body: _textOrFallback(
                    content?.vision,
                    BrandInstitutionalContent.vision,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.xl),
          _reveal(
            'values-heading',
            Text('Valores', style: typography.headlineMedium),
          ),
          const SizedBox(height: DSSpacing.lg),
          _BrandGrid(
            children: [
              for (var index = 0; index < values.length; index++)
                _reveal(
                  'value-$index',
                  _InstitutionalCard(
                    number: (index + 1).toString().padLeft(2, '0'),
                    body: values[index],
                  ),
                ),
            ],
          ),
          const SizedBox(height: DSSpacing.xl),
          // Keep the contact anchor mounted even while contact data is absent.
          _reveal(
            'contact',
            contacts.isEmpty
                ? const SizedBox.shrink()
                : Container(
                    padding: const EdgeInsets.all(DSSpacing.lg),
                    decoration: const BoxDecoration(
                      color: DSColors.surfaceContainer,
                      border: Border(top: BorderSide(color: DSColors.primary)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Contatos', style: typography.headlineSmall),
                        const SizedBox(height: DSSpacing.lg),
                        _BrandGrid(
                          children: [
                            for (final entry in contacts)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.$1,
                                    style: typography.labelSmall?.copyWith(
                                      color: DSColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: DSSpacing.sm),
                                  Text(entry.$2, style: typography.bodyLarge),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
            anchor: widget.contactKey,
          ),
        ],
      ),
    );
  }
}

class _BrandGrid extends StatelessWidget {
  const _BrandGrid({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth < 860
          ? constraints.maxWidth
          : (constraints.maxWidth - DSSpacing.lg) / 2;
      // Preserve the element tree when crossing the responsive breakpoint.
      return Wrap(
        spacing: DSSpacing.lg,
        runSpacing: DSSpacing.lg,
        children: [
          for (final child in children) SizedBox(width: width, child: child),
        ],
      );
    },
  );
}

class _InstitutionalCard extends StatelessWidget {
  const _InstitutionalCard({
    required this.body,
    this.title,
    this.icon,
    this.number,
  });
  final String body;
  final String? title;
  final IconData? icon;
  final String? number;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        color: DSColors.surfaceContainer,
        border: Border.all(color: DSColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) Icon(icon, color: DSColors.primary, size: 28),
          if (number != null)
            Text(
              number!,
              style: typography.headlineSmall?.copyWith(
                color: DSColors.primary,
              ),
            ),
          const SizedBox(height: DSSpacing.lg),
          if (title != null) ...[
            Text(title!, style: typography.headlineSmall),
            const SizedBox(height: DSSpacing.md),
          ],
          Text(body, style: typography.bodyMedium),
        ],
      ),
    );
  }
}
