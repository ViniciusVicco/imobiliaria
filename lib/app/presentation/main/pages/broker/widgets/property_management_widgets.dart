import 'dart:typed_data';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:imobiliaria/app/domain/broker/entities/broker_property_entity.dart';
import 'package:imobiliaria/app/domain/media/entities/property_media_entity.dart';

typedef PropertySaveCallback =
    Future<bool> Function(BrokerPropertyFormEntity property);
typedef PropertyMediaFileLoader = Future<Uint8List?> Function(String mediaId);

class PropertyStatusTabs extends StatelessWidget {
  const PropertyStatusTabs({
    super.key,
    required this.selectedStatus,
    required this.onChanged,
  });

  final String selectedStatus;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: const <ButtonSegment<String>>[
        ButtonSegment<String>(
          value: 'published',
          icon: Icon(Icons.campaign_outlined),
          label: Text('Anunciados'),
        ),
        ButtonSegment<String>(
          value: 'pending_review',
          icon: Icon(Icons.hourglass_top),
          label: Text('Em revisao'),
        ),
        ButtonSegment<String>(
          value: 'sold',
          icon: Icon(Icons.handshake_outlined),
          label: Text('Vendas'),
        ),
        ButtonSegment<String>(
          value: 'inactive',
          icon: Icon(Icons.visibility_off_outlined),
          label: Text('Excluidos'),
        ),
      ],
      selected: <String>{selectedStatus},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}

class PropertyManagementGrid extends StatelessWidget {
  const PropertyManagementGrid({
    super.key,
    required this.properties,
    required this.onEdit,
    required this.onMarkSold,
    required this.onDeactivate,
    this.showBroker = false,
    this.onCreate,
    this.loadMediaFile,
  });

  final List<BrokerPropertyEntity> properties;
  final ValueChanged<BrokerPropertyEntity> onEdit;
  final ValueChanged<BrokerPropertyEntity> onMarkSold;
  final ValueChanged<BrokerPropertyEntity> onDeactivate;
  final bool showBroker;
  final VoidCallback? onCreate;
  final PropertyMediaFileLoader? loadMediaFile;

  @override
  Widget build(BuildContext context) {
    if (properties.isEmpty && onCreate == null) {
      return const Center(child: Text('Nenhum imovel encontrado.'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 1180
            ? 3
            : constraints.maxWidth >= 760
            ? 2
            : 1;

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: DSSpacing.md,
            mainAxisSpacing: DSSpacing.md,
            childAspectRatio: 0.82,
          ),
          itemCount: properties.length + (onCreate == null ? 0 : 1),
          itemBuilder: (context, index) {
            if (onCreate != null && index == 0) {
              return PropertyCreateCard(onPressed: onCreate!);
            }

            final propertyIndex = onCreate == null ? index : index - 1;
            final property = properties[propertyIndex];
            return PropertyManagementCard(
              property: property,
              onEdit: () => onEdit(property),
              onMarkSold: () => onMarkSold(property),
              onDeactivate: () => onDeactivate(property),
              showBroker: showBroker,
              loadMediaFile: loadMediaFile,
            );
          },
        );
      },
    );
  }
}

class PropertyCreateCard extends StatelessWidget {
  const PropertyCreateCard({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DSColors.surfaceContainer,
      borderRadius: DSRadius.md,
      child: InkWell(
        borderRadius: DSRadius.md,
        onTap: onPressed,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: DSRadius.md,
            border: Border.all(
              color: DSColors.outline,
              style: BorderStyle.solid,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.add_home_work_outlined,
                  size: 48,
                  color: DSColors.primary,
                ),
                const SizedBox(height: DSSpacing.sm),
                Text(
                  'Novo imovel',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PropertyManagementCard extends StatelessWidget {
  const PropertyManagementCard({
    super.key,
    required this.property,
    required this.onEdit,
    required this.onMarkSold,
    required this.onDeactivate,
    this.showBroker = false,
    this.loadMediaFile,
  });

  final BrokerPropertyEntity property;
  final VoidCallback onEdit;
  final VoidCallback onMarkSold;
  final VoidCallback onDeactivate;
  final bool showBroker;
  final PropertyMediaFileLoader? loadMediaFile;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 0,
    );
    final coverUrl = property.coverUrl.trim();
    final coverMedia = _coverMedia(property);

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
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  if (coverUrl.isEmpty)
                    const ColoredBox(
                      color: DSColors.surfaceContainerHighest,
                      child: Center(child: Icon(Icons.image_not_supported)),
                    )
                  else
                    PropertyManagementCoverImage(
                      mediaId: coverMedia?.id ?? '',
                      fallbackUrl: coverUrl,
                      fit: BoxFit.cover,
                      loadMediaFile: loadMediaFile,
                    ),
                  Positioned(
                    top: DSSpacing.sm,
                    right: DSSpacing.sm,
                    child: Wrap(
                      spacing: DSSpacing.xs,
                      children: <Widget>[
                        IconButton.filledTonal(
                          tooltip: 'Editar',
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton.filledTonal(
                          tooltip: 'Sinalizar venda',
                          onPressed: property.status == 'sold'
                              ? null
                              : onMarkSold,
                          icon: const Icon(Icons.handshake_outlined),
                        ),
                        IconButton.filledTonal(
                          tooltip: 'Remover',
                          onPressed: property.status == 'inactive'
                              ? null
                              : onDeactivate,
                          icon: const Icon(Icons.visibility_off_outlined),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(DSSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    property.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: DSSpacing.xs),
                  Text(
                    '${property.neighborhood}, ${property.city}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: DSColors.onSurfaceVariant,
                    ),
                  ),
                  if (showBroker && property.broker != null) ...<Widget>[
                    const SizedBox(height: DSSpacing.xs),
                    Text(
                      'Corretor: ${property.broker!.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: DSSpacing.sm),
                  Wrap(
                    spacing: DSSpacing.sm,
                    runSpacing: DSSpacing.xs,
                    children: <Widget>[
                      _PropertyFact(
                        icon: Icons.square_foot,
                        text: '${property.areaM2} m2',
                      ),
                      _PropertyFact(
                        icon: Icons.bathtub_outlined,
                        text: '${property.bathrooms} ban.',
                      ),
                      _PropertyFact(
                        icon: Icons.directions_car_outlined,
                        text: '${property.garageSpaces} vagas',
                      ),
                    ],
                  ),
                  const SizedBox(height: DSSpacing.sm),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          formatter.format(property.price),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      Chip(label: Text(_statusLabel(property.status))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PropertyMediaEntity? _coverMedia(BrokerPropertyEntity property) {
    final coverUrl = property.coverUrl.trim();
    for (final media in property.media) {
      if (!media.isImage || !media.isActive) continue;
      if (media.url.trim() == coverUrl || media.publicUrl.trim() == coverUrl) {
        return media;
      }
    }
    return null;
  }
}

class PropertyManagementCoverImage extends StatefulWidget {
  const PropertyManagementCoverImage({
    super.key,
    required this.mediaId,
    required this.fallbackUrl,
    required this.fit,
    this.loadMediaFile,
  });

  final String mediaId;
  final String fallbackUrl;
  final BoxFit fit;
  final PropertyMediaFileLoader? loadMediaFile;

  @override
  State<PropertyManagementCoverImage> createState() =>
      _PropertyManagementCoverImageState();
}

class _PropertyManagementCoverImageState
    extends State<PropertyManagementCoverImage> {
  Future<Uint8List?>? _fileFuture;

  @override
  void initState() {
    super.initState();
    _fileFuture = _loadFile();
  }

  @override
  void didUpdateWidget(covariant PropertyManagementCoverImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mediaId != widget.mediaId ||
        oldWidget.loadMediaFile != widget.loadMediaFile) {
      _fileFuture = _loadFile();
    }
  }

  Future<Uint8List?>? _loadFile() {
    final mediaId = widget.mediaId.trim();
    final loader = widget.loadMediaFile;
    if (mediaId.isEmpty || loader == null) return null;
    return loader(mediaId);
  }

  @override
  Widget build(BuildContext context) {
    final fileFuture = _fileFuture;
    if (fileFuture == null) return _NetworkCoverImage(widget: widget);

    return FutureBuilder<Uint8List?>(
      future: fileFuture,
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes != null && bytes.isNotEmpty) {
          return Image.memory(bytes, fit: widget.fit);
        }

        if (snapshot.connectionState != ConnectionState.done) {
          return const ColoredBox(
            color: DSColors.surfaceContainerHighest,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return _NetworkCoverImage(widget: widget);
      },
    );
  }
}

class _NetworkCoverImage extends StatelessWidget {
  const _NetworkCoverImage({required this.widget});

  final PropertyManagementCoverImage widget;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      widget.fallbackUrl,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        return const ColoredBox(
          color: DSColors.surfaceContainerHighest,
          child: Center(child: Icon(Icons.image_not_supported)),
        );
      },
    );
  }
}

class _PropertyFact extends StatelessWidget {
  const _PropertyFact({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 16, color: DSColors.primary),
        const SizedBox(width: DSSpacing.xs),
        Text(text, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class PropertyManagementErrorState extends StatelessWidget {
  const PropertyManagementErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.error_outline, color: DSColors.primary, size: 40),
          const SizedBox(height: DSSpacing.md),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: DSSpacing.md),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}

class PropertyFormDialog extends StatefulWidget {
  const PropertyFormDialog({
    super.key,
    required this.title,
    required this.initialValue,
    required this.onSave,
    this.allowBrokerId = false,
  });

  final String title;
  final BrokerPropertyFormEntity initialValue;
  final PropertySaveCallback onSave;
  final bool allowBrokerId;

  @override
  State<PropertyFormDialog> createState() => _PropertyFormDialogState();
}

class _PropertyFormDialogState extends State<PropertyFormDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _propertyTypeController;
  late final TextEditingController _cityController;
  late final TextEditingController _neighborhoodController;
  late final TextEditingController _subNeighborhoodController;
  late final TextEditingController _coverUrlController;
  late final TextEditingController _videoUrlController;
  late final TextEditingController _areaController;
  late final TextEditingController _priceController;
  late final TextEditingController _tagsController;
  late final TextEditingController _brokerIdController;
  late final List<TextEditingController> _imageUrlControllers;
  late String _segment;
  late double _bedrooms;
  late double _bathrooms;
  late double _garageSpaces;
  late double _propertyAgeYears;
  late bool _isFeatured;
  late bool _isNewDevelopment;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialValue;
    _titleController = TextEditingController(text: initial.title);
    _descriptionController = TextEditingController(text: initial.description);
    _propertyTypeController = TextEditingController(text: initial.propertyType);
    _cityController = TextEditingController(text: initial.city);
    _neighborhoodController = TextEditingController(text: initial.neighborhood);
    _subNeighborhoodController = TextEditingController(
      text: initial.subNeighborhood,
    );
    _coverUrlController = TextEditingController(text: initial.coverUrl);
    _videoUrlController = TextEditingController(text: initial.videoUrl);
    _areaController = TextEditingController(text: initial.areaM2.toString());
    _priceController = TextEditingController(text: initial.price.toString());
    _tagsController = TextEditingController(text: initial.tagSlugs.join(', '));
    _brokerIdController = TextEditingController(text: initial.brokerId ?? '');
    _imageUrlControllers = initial.imageUrls
        .map((url) => TextEditingController(text: url))
        .toList();
    while (_imageUrlControllers.length < 4) {
      _imageUrlControllers.add(TextEditingController());
    }
    _segment = initial.segment;
    _bedrooms = initial.bedrooms.toDouble();
    _bathrooms = initial.bathrooms.toDouble();
    _garageSpaces = initial.garageSpaces.toDouble();
    _propertyAgeYears = initial.propertyAgeYears.toDouble();
    _isFeatured = initial.isFeatured;
    _isNewDevelopment = initial.isNewDevelopment;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _propertyTypeController.dispose();
    _cityController.dispose();
    _neighborhoodController.dispose();
    _subNeighborhoodController.dispose();
    _coverUrlController.dispose();
    _videoUrlController.dispose();
    _areaController.dispose();
    _priceController.dispose();
    _tagsController.dispose();
    _brokerIdController.dispose();
    for (final controller in _imageUrlControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 720,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _field(_titleController, 'Titulo'),
              _field(_descriptionController, 'Descricao', maxLines: 3),
              Row(
                children: <Widget>[
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _segment,
                      decoration: const InputDecoration(labelText: 'Segmento'),
                      items: const <DropdownMenuItem<String>>[
                        DropdownMenuItem(
                          value: 'residential',
                          child: Text('Residencial'),
                        ),
                        DropdownMenuItem(
                          value: 'commercial',
                          child: Text('Comercial'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => _segment = value);
                      },
                    ),
                  ),
                  const SizedBox(width: DSSpacing.md),
                  Expanded(child: _field(_propertyTypeController, 'Tipo')),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(child: _field(_cityController, 'Cidade')),
                  const SizedBox(width: DSSpacing.md),
                  Expanded(child: _field(_neighborhoodController, 'Bairro')),
                ],
              ),
              _field(_subNeighborhoodController, 'Sub-bairro ou quadra'),
              _field(_coverUrlController, 'Foto de capa URL'),
              const SizedBox(height: DSSpacing.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Fotos',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              const SizedBox(height: DSSpacing.xs),
              for (var index = 0; index < _imageUrlControllers.length; index++)
                _field(_imageUrlControllers[index], 'Foto ${index + 1} URL'),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _imageUrlControllers.length >= 12
                      ? null
                      : () {
                          setState(() {
                            _imageUrlControllers.add(TextEditingController());
                          });
                        },
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: const Text('Adicionar foto'),
                ),
              ),
              _field(_videoUrlController, 'Video URL opcional'),
              Row(
                children: <Widget>[
                  Expanded(child: _field(_areaController, 'Metros quadrados')),
                  const SizedBox(width: DSSpacing.md),
                  Expanded(child: _field(_priceController, 'Valor em reais')),
                ],
              ),
              _slider(
                label: 'Quartos',
                value: _bedrooms,
                max: 5,
                onChanged: (value) => setState(() => _bedrooms = value),
              ),
              _slider(
                label: 'Banheiros',
                value: _bathrooms,
                max: 5,
                onChanged: (value) => setState(() => _bathrooms = value),
              ),
              _slider(
                label: 'Vagas',
                value: _garageSpaces,
                max: 5,
                onChanged: (value) => setState(() => _garageSpaces = value),
              ),
              CheckboxListTile(
                value: _isNewDevelopment,
                onChanged: (value) {
                  setState(() {
                    _isNewDevelopment = value ?? false;
                    if (_isNewDevelopment) _propertyAgeYears = 0;
                  });
                },
                title: const Text('Imovel na planta'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              _slider(
                label: 'Idade do imovel',
                value: _propertyAgeYears,
                max: 50,
                onChanged: _isNewDevelopment
                    ? null
                    : (value) => setState(() => _propertyAgeYears = value),
              ),
              CheckboxListTile(
                value: _isFeatured,
                onChanged: (value) {
                  setState(() => _isFeatured = value ?? false);
                },
                title: const Text('Destacar na vitrine'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              _field(_tagsController, 'Tags separadas por virgula'),
              if (widget.allowBrokerId)
                _field(_brokerIdController, 'ID do corretor responsavel'),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: _isSaving ? null : _submit,
          icon: _isSaving
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_outlined),
          label: const Text('Salvar'),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.sm),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _slider({
    required String label,
    required double value,
    required double max,
    required ValueChanged<double>? onChanged,
  }) {
    return Row(
      children: <Widget>[
        SizedBox(width: 150, child: Text('$label: ${value.round()}')),
        Expanded(
          child: Slider(
            value: value.clamp(0, max),
            min: 0,
            max: max,
            divisions: max.round(),
            label: value.round().toString(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    setState(() => _isSaving = true);
    final wasSaved = await widget.onSave(_buildForm());
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (wasSaved) {
      Navigator.of(context).pop(true);
    }
  }

  BrokerPropertyFormEntity _buildForm() {
    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    return BrokerPropertyFormEntity(
      title: _titleController.text,
      description: _descriptionController.text,
      segment: _segment,
      propertyType: _propertyTypeController.text,
      city: _cityController.text,
      neighborhood: _neighborhoodController.text,
      subNeighborhood: _subNeighborhoodController.text,
      coverUrl: _coverUrlController.text,
      imageUrls: _imageUrlControllers
          .map((controller) => controller.text)
          .toList(),
      videoUrl: _videoUrlController.text,
      areaM2: int.tryParse(_areaController.text.trim()) ?? 0,
      bedrooms: _bedrooms.round(),
      bathrooms: _bathrooms.round(),
      garageSpaces: _garageSpaces.round(),
      propertyAgeYears: _propertyAgeYears.round(),
      price: int.tryParse(_priceController.text.trim()) ?? 0,
      tagSlugs: tags,
      isFeatured: _isFeatured,
      isNewDevelopment: _isNewDevelopment,
      brokerId: _brokerIdController.text.trim(),
    );
  }
}

String _statusLabel(String status) {
  return switch (status) {
    'published' => 'Anunciado',
    'pending_review' => 'Em revisao',
    'sold' => 'Vendido',
    'inactive' => 'Excluido',
    'draft' => 'Rascunho',
    _ => status,
  };
}
