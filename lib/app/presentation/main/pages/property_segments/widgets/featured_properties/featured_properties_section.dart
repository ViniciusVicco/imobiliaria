import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/featured_property_entity.dart';
import 'package:imobiliaria/app/presentation/main/widgets/property_card_image.dart';

class FeaturedPropertiesSection extends StatefulWidget {
  const FeaturedPropertiesSection({
    super.key,
    required this.properties,
    required this.onMoreInfoPressed,
  });

  final List<FeaturedPropertyEntity> properties;
  final ValueChanged<FeaturedPropertyEntity> onMoreInfoPressed;

  @override
  State<FeaturedPropertiesSection> createState() =>
      _FeaturedPropertiesSectionState();
}

class _FeaturedPropertiesSectionState extends State<FeaturedPropertiesSection> {
  static const _collapsedLimit = 6;
  static const _expandedLimit = 9;
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final visibleLimit = _isExpanded ? _expandedLimit : _collapsedLimit;
    final visibleProperties = widget.properties.take(visibleLimit).toList();
    final canExpand = widget.properties.length > _collapsedLimit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Destaques', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: DSSpacing.md),
        if (widget.properties.isEmpty)
          const _FeaturedPropertiesEmptyState()
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1040
                  ? 3
                  : constraints.maxWidth >= 700
                  ? 2
                  : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: visibleProperties.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: DSSpacing.md,
                  crossAxisSpacing: DSSpacing.md,
                  mainAxisExtent: 492,
                ),
                itemBuilder: (context, index) {
                  final property = visibleProperties[index];
                  return _FeaturedPropertyCard(
                    property: property,
                    onMoreInfoPressed: () =>
                        widget.onMoreInfoPressed(property),
                  );
                },
              );
            },
          ),
        if (canExpand && !_isExpanded) ...<Widget>[
          const SizedBox(height: DSSpacing.md),
          Center(
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _isExpanded = true),
              icon: const Icon(Icons.expand_more),
              label: const Text('Ver mais'),
            ),
          ),
        ],
      ],
    );
  }
}

class _FeaturedPropertyCard extends StatelessWidget {
  const _FeaturedPropertyCard({
    required this.property,
    required this.onMoreInfoPressed,
  });

  final FeaturedPropertyEntity property;
  final VoidCallback onMoreInfoPressed;

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
            PropertyCardImage(
              coverUrl: property.coverUrl,
              tags: property.tags,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(DSSpacing.md),
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
                    _PropertyLocationText(property: property),
                    const SizedBox(height: DSSpacing.md),
                    _PropertyFacts(property: property),
                    const Spacer(),
                    Text(
                      _formatPrice(property.price),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: DSColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: DSSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: onMoreInfoPressed,
                        icon: const Icon(BootstrapIcons.whatsapp),
                        label: const Text('Quero mais informacoes'),
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

  String _formatPrice(int price) {
    final text = price.toString();
    final buffer = StringBuffer();
    for (var index = 0; index < text.length; index++) {
      final positionFromEnd = text.length - index;
      buffer.write(text[index]);
      if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }
    return 'R\$ ${buffer.toString()}';
  }
}

class _FeaturedPropertiesEmptyState extends StatelessWidget {
  const _FeaturedPropertiesEmptyState();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: DSColors.surfaceContainer,
        borderRadius: DSRadius.md,
        border: Border.all(color: DSColors.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.lg),
        child: Row(
          children: <Widget>[
            const Icon(Icons.tune, color: DSColors.primary),
            const SizedBox(width: DSSpacing.sm),
            Expanded(
              child: Text(
                'Nenhum destaque encontrado nessa faixa de valor.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: DSColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PropertyLocationText extends StatelessWidget {
  const _PropertyLocationText({required this.property});

  final FeaturedPropertyEntity property;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Icon(
          Icons.location_on_outlined,
          size: 17,
          color: DSColors.onSurfaceVariant,
        ),
        const SizedBox(width: DSSpacing.xxs),
        Expanded(
          child: Text(
            _formatPropertyLocation(property),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: DSColors.onSurfaceVariant,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _PropertyFacts extends StatelessWidget {
  const _PropertyFacts({required this.property});

  final FeaturedPropertyEntity property;

  @override
  Widget build(BuildContext context) {
    final facts = <_PropertyFact>[
      _PropertyFact(
        icon: Icons.square_foot_outlined,
        label: '${property.areaM2} m2',
      ),
      if (property.bedrooms != null)
        _PropertyFact(
          icon: Icons.bed_outlined,
          label: '${property.bedrooms} quartos',
        ),
      _PropertyFact(
        icon: Icons.bathtub_outlined,
        label: '${property.bathrooms} banheiros',
      ),
      _PropertyFact(
        icon: Icons.directions_car_outlined,
        label: '${property.garageSpaces} vagas',
      ),
      _PropertyFact(
        icon: Icons.calendar_month_outlined,
        label: _formatPropertyAge(property),
      ),
    ];

    return Wrap(
      spacing: DSSpacing.md,
      runSpacing: DSSpacing.sm,
      children: facts
          .map((fact) => _PropertyFactItem(icon: fact.icon, label: fact.label))
          .toList(),
    );
  }

  String _formatPropertyAge(FeaturedPropertyEntity property) {
    if (property.propertyAgeYears <= 1) return 'Lancamento';
    return '${property.propertyAgeYears} anos';
  }
}

class _PropertyFact {
  const _PropertyFact({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class _PropertyFactItem extends StatelessWidget {
  const _PropertyFactItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 16, color: DSColors.onSurfaceVariant),
        const SizedBox(width: DSSpacing.xxs),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: DSColors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

String _formatPropertyLocation(FeaturedPropertyEntity property) {
  final locationParts = <String>[
    if (property.subNeighborhood.trim().isNotEmpty)
      property.subNeighborhood.trim(),
    property.neighborhood.trim(),
    property.city.trim(),
  ].where((part) => part.isNotEmpty).toList();

  return locationParts.join(' - ');
}
