import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/search_property_entity.dart';
import 'property_search_formatters.dart';
import '../../widgets/property/property_card_image.dart';
import 'property_facts.dart';

class StockPropertyCard extends StatelessWidget {
  const StockPropertyCard({super.key, required this.property});

  final SearchPropertyEntity property;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: DSColors.surfaceContainer,
        borderRadius: DSRadius.md,
        border: Border.all(color: DSColors.outline),
      ),
      child: ClipRRect(
        borderRadius: DSRadius.md,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            PropertyCardImage(coverUrl: property.coverUrl, tags: property.tags),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(DSSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      property.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: DSSpacing.xs),
                    Text(
                      formatPropertyLocation(property),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: DSColors.onSurfaceVariant),
                    ),
                    const Spacer(),
                    PropertyFacts(property: property),
                    const SizedBox(height: DSSpacing.sm),
                    Text(
                      formatPrice(property.price),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: DSColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
