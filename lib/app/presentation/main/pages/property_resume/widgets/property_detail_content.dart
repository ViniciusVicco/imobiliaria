import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/property_detail_entity.dart';
import 'property_gallery.dart';

const _gold = Color(0xffd4af37);

class PropertyDetailContent extends StatelessWidget {
  const PropertyDetailContent({
    super.key,
    required this.property,
    required this.desktop,
    required this.onVisit,
    required this.onContact,
    required this.onShare,
  });
  final PropertyDetailEntity property;
  final bool desktop;
  final VoidCallback onVisit, onContact;
  final ValueChanged<Rect> onShare;
  @override
  Widget build(BuildContext context) {
    final header = PropertyDetailHeader(property: property, desktop: desktop);
    final gallery = PropertyGallery(images: property.images, desktop: desktop);
    final specs = PropertySpecsCard(
      property: property,
      onVisit: onVisit,
      onContact: onContact,
      onShare: onShare,
    );
    final broker = PropertyBrokerCard(property: property, onContact: onContact);
    final description = PropertyDescriptionCard(
      description: property.description,
    );
    if (!desktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          const SizedBox(height: 24),
          gallery,
          const SizedBox(height: 24),
          specs,
          const SizedBox(height: 16),
          broker,
          if (property.description.trim().isNotEmpty) ...[
            const SizedBox(height: 24),
            description,
          ],
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              const SizedBox(height: 32),
              gallery,
              if (property.description.trim().isNotEmpty) ...[
                const SizedBox(height: 32),
                description,
              ],
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [specs, const SizedBox(height: 16), broker],
          ),
        ),
      ],
    );
  }
}

class PropertyDetailHeader extends StatelessWidget {
  const PropertyDetailHeader({
    super.key,
    required this.property,
    required this.desktop,
  });
  final PropertyDetailEntity property;
  final bool desktop;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        property.title.toUpperCase(),
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
          fontSize: desktop ? 38 : 28,
          height: 1.2,
          fontWeight: FontWeight.w600,
        ),
      ),
      if (property.location.isNotEmpty) ...[
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on_outlined, color: _gold, size: 18),
            const SizedBox(width: 6),
            Expanded(child: Text(property.location)),
          ],
        ),
      ],
    ],
  );
}

class PropertyDetailPanel extends StatelessWidget {
  const PropertyDetailPanel({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: const Color(0xff111c31),
      border: Border.all(color: const Color(0xff2d3748)),
    ),
    child: child,
  );
}

class PropertySpecsCard extends StatelessWidget {
  const PropertySpecsCard({
    super.key,
    required this.property,
    required this.onVisit,
    required this.onContact,
    required this.onShare,
  });
  final PropertyDetailEntity property;
  final VoidCallback onVisit, onContact;
  final ValueChanged<Rect> onShare;
  @override
  Widget build(BuildContext context) {
    final number = NumberFormat.decimalPattern('pt_BR');
    final facts = <(String, String, IconData)>[
      ('privateAreaM2', 'Área privativa', Icons.aspect_ratio),
      ('totalAreaM2', 'Área total', Icons.square_foot),
      ('bedrooms', 'Quartos', Icons.bed_outlined),
      ('bathrooms', 'Banheiros', Icons.bathtub_outlined),
      ('garageSpaces', 'Vagas', Icons.directions_car_outlined),
      ('propertyAgeYears', 'Idade do imóvel', Icons.calendar_month_outlined),
    ];
    return PropertyDetailPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Valor'),
                    const SizedBox(height: 8),
                    Text(
                      NumberFormat.currency(
                        locale: 'pt_BR',
                        symbol: 'R\$',
                        decimalDigits: 0,
                      ).format(property.price),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: _gold, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Builder(
                builder: (context) => IconButton(
                  tooltip: 'Compartilhar imóvel',
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () {
                    final box = context.findRenderObject()! as RenderBox;
                    onShare(box.localToGlobal(Offset.zero) & box.size);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          for (final fact in facts)
            PropertyFactRow(
              label: fact.$2,
              icon: fact.$3,
              value: property.facts[fact.$1] == null
                  ? 'Não informado'
                  : '${number.format(property.facts[fact.$1])}${fact.$1.endsWith('M2')
                        ? ' m²'
                        : fact.$1 == 'propertyAgeYears'
                        ? (property.facts[fact.$1] == 1 ? ' ano' : ' anos')
                        : ''}',
            ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onVisit,
            style: FilledButton.styleFrom(
              backgroundColor: _gold,
              foregroundColor: const Color(0xff030e22),
              shape: const RoundedRectangleBorder(),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            ),
            child: const Text('Agendar visita', textAlign: TextAlign.center),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: onContact,
            style: OutlinedButton.styleFrom(
              foregroundColor: _gold,
              side: const BorderSide(color: _gold),
              shape: const RoundedRectangleBorder(),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            ),
            child: const Text('Entrar em contato', textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}

class PropertyFactRow extends StatelessWidget {
  const PropertyFactRow({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label, value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: _gold),
        const SizedBox(width: 8),
        Expanded(flex: 3, child: Text(label)),
        const SizedBox(width: 12),
        Expanded(flex: 2, child: Text(value, textAlign: TextAlign.right)),
      ],
    ),
  );
}

class PropertyBrokerCard extends StatelessWidget {
  const PropertyBrokerCard({
    super.key,
    required this.property,
    required this.onContact,
  });
  final PropertyDetailEntity property;
  final VoidCallback onContact;
  @override
  Widget build(BuildContext context) => PropertyDetailPanel(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _gold),
          ),
          child: property.avatarUrl.isEmpty
              ? const Icon(Icons.person_outline)
              : Image.network(
                  property.avatarUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, error, stack) =>
                      const Icon(Icons.person_outline),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                property.brokerName.isEmpty ? 'Seletta' : property.brokerName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                property.brokerName == 'Seletta'
                    ? 'Atendimento Seletta'
                    : 'Corretor especializado',
                style: const TextStyle(color: _gold),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: onContact,
          tooltip: 'Entrar em contato pelo WhatsApp',
          color: _gold,
          icon: const Icon(BootstrapIcons.whatsapp),
        ),
      ],
    ),
  );
}

class PropertyDescriptionCard extends StatelessWidget {
  const PropertyDescriptionCard({super.key, required this.description});
  final String description;
  @override
  Widget build(BuildContext context) => PropertyDetailPanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sobre o imóvel',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: _gold),
        ),
        const SizedBox(height: 16),
        SelectableText(description, style: const TextStyle(height: 1.6)),
      ],
    ),
  );
}
