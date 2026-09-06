import 'dart:typed_data';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:imobiliaria/app/domain/admin/entities/admin_broker_entity.dart';
import 'package:imobiliaria/app/domain/broker/entities/broker_property_entity.dart';
import 'package:imobiliaria/app/domain/media/entities/property_media_entity.dart';
import 'package:imobiliaria/app/presentation/main/main_module.dart';
import 'package:imobiliaria/app/presentation/main/main_routes.dart';
import 'package:imobiliaria/app/presentation/main/pages/admin/admin_layout.dart';
import 'package:imobiliaria/app/presentation/main/pages/broker/helpers/property_image_picker.dart';
import 'package:imobiliaria/app/presentation/main/pages/broker/property_form_controller.dart';
import 'package:imobiliaria/app/presentation/main/widgets/auth/session_action.dart';
import 'package:imobiliaria/app/presentation/main/pages/broker/property_form_validator.dart';
import 'package:legend_core/legend_core.dart';

enum PropertyFormMode { broker, admin }

class PropertyFormPage extends StatefulWidget {
  const PropertyFormPage({
    super.key,
    this.routeData,
    this.mode = PropertyFormMode.broker,
  });

  final ModuleRouteData? routeData;
  final PropertyFormMode mode;

  @override
  State<PropertyFormPage> createState() => _PropertyFormPageState();
}

class _PropertyFormPageState
    extends
        StateController<MainModule, PropertyFormPage, PropertyFormController> {
  String get _propertyId => widget.routeData?.pathParameters['id'] ?? '';
  bool get _isAdmin => widget.mode == PropertyFormMode.admin;
  late final String _uploadSessionId =
      'property_${DateTime.now().microsecondsSinceEpoch}';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_propertyId.isEmpty) {
        controller.startNewProperty(isAdmin: _isAdmin);
        return;
      }
      controller.loadProperty(_propertyId, isAdmin: _isAdmin);
    });
  }

  @override
  Widget build(BuildContext context) {
    final page = Scaffold(
      appBar: AppBar(
        title: Text(_isAdmin ? 'Editar imovel' : 'Meu imovel'),
        actions: const <Widget>[SessionAction(compact: true)],
        leading: IconButton(
          onPressed: () => Module.get<MainModule>().navigator.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: ValueListenableBuilder<AppStateEnum>(
        valueListenable: controller.store.state,
        builder: (context, state, child) {
          if (state == AppStateEnum.isLoading &&
              controller.store.property == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state == AppStateEnum.hasError &&
              controller.store.property == null) {
            return Center(
              child: Text(
                controller.store.errorMessage ?? 'Nao foi possivel carregar.',
              ),
            );
          }

          final property = controller.store.property;
          if (property == null) return const SizedBox.shrink();

          return DSPageLayoutContainer(
            padding: const EdgeInsets.all(DSSpacing.md),
            child: _PropertyFormContent(
              key: ValueKey('${property.id}-${property.updatedAt}'),
              property: property,
              controller: controller,
              isBusy: state == AppStateEnum.isLoading,
              isAdmin: _isAdmin,
              uploadSessionId: _uploadSessionId,
            ),
          );
        },
      ),
    );

    if (!_isAdmin) return page;

    return AdminLayout(
      title: 'Editar imovel',
      currentRoute: MainRoutes.adminProperties,
      child: page.body ?? const SizedBox.shrink(),
    );
  }
}

class _PropertyFormContent extends StatefulWidget {
  const _PropertyFormContent({
    super.key,
    required this.property,
    required this.controller,
    required this.isBusy,
    required this.isAdmin,
    required this.uploadSessionId,
  });

  final BrokerPropertyEntity property;
  final PropertyFormController controller;
  final bool isBusy;
  final bool isAdmin;
  final String uploadSessionId;

  @override
  State<_PropertyFormContent> createState() => _PropertyFormContentState();
}

class _PropertyFormContentState extends State<_PropertyFormContent> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _propertyTypeController;
  late final TextEditingController _cityController;
  late final TextEditingController _neighborhoodController;
  late final TextEditingController _subNeighborhoodController;
  late final TextEditingController _areaController;
  late final TextEditingController _privateAreaController;
  late final TextEditingController _totalAreaController;
  late final TextEditingController _priceController;
  late final TextEditingController _videoController;
  late final TextEditingController _tagsController;
  late String _segment;
  late String? _brokerId;
  late double _bedrooms;
  late double _bathrooms;
  late double _garageSpaces;
  late double _propertyAgeYears;
  late bool _isFeatured;
  late bool _isNewDevelopment;
  final PropertyFormValidator _validator = const PropertyFormValidator();
  PropertyFormValidationResult? _validationResult;
  bool get _isNew => widget.property.id.isEmpty;
  bool get _shouldSaveForReview =>
      !widget.isAdmin &&
      (widget.property.status == 'published' ||
          widget.property.status == 'pending_review');

  @override
  void initState() {
    super.initState();
    final property = widget.property;
    _titleController = TextEditingController(text: property.title);
    _descriptionController = TextEditingController(text: property.description);
    _propertyTypeController = TextEditingController(
      text: property.propertyType,
    );
    _cityController = TextEditingController(text: property.city);
    _neighborhoodController = TextEditingController(
      text: property.neighborhood,
    );
    _subNeighborhoodController = TextEditingController(
      text: property.subNeighborhood,
    );
    _areaController = TextEditingController(text: property.areaM2.toString());
    _privateAreaController = TextEditingController(
      text: property.privateAreaM2.toString(),
    );
    _totalAreaController = TextEditingController(
      text: property.totalAreaM2.toString(),
    );
    _priceController = TextEditingController(text: property.price.toString());
    _videoController = TextEditingController(text: property.videoUrl);
    _tagsController = TextEditingController(text: property.tags.join(', '));
    _segment = property.segment;
    _brokerId = property.broker?.id;
    _bedrooms = property.bedrooms.toDouble();
    _bathrooms = property.bathrooms.toDouble();
    _garageSpaces = property.garageSpaces.toDouble();
    _propertyAgeYears = property.propertyAgeYears.toDouble();
    _isFeatured = property.isFeatured;
    _isNewDevelopment = property.tags.contains('na-planta');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _propertyTypeController.dispose();
    _cityController.dispose();
    _neighborhoodController.dispose();
    _subNeighborhoodController.dispose();
    _areaController.dispose();
    _privateAreaController.dispose();
    _totalAreaController.dispose();
    _priceController.dispose();
    _videoController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeImageCount = widget.property.media
        .where((media) => media.isImage && media.status == 'active')
        .length;
    final errorMessage = widget.controller.store.errorMessage;
    final validationResult = _validationResult;

    return ListView(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Wrap(
                spacing: DSSpacing.sm,
                runSpacing: DSSpacing.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  Text(
                    _isNew ? 'Novo imovel' : 'Editar imovel',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  _StatusChip(status: widget.property.status),
                ],
              ),
            ),
            if (!_isNew) ...<Widget>[
              FilledButton.icon(
                onPressed: widget.isBusy ? null : _saveDraft,
                icon: const Icon(Icons.save_outlined),
                label: Text(
                  widget.isAdmin
                      ? 'Salvar alteracoes'
                      : _shouldSaveForReview
                      ? 'Salvar e enviar para revisao'
                      : 'Salvar alteracoes',
                ),
              ),
              const SizedBox(width: DSSpacing.sm),
            ],
            FilledButton.icon(
              onPressed: widget.isBusy ? null : _finalize,
              icon: Icon(
                widget.isAdmin ? Icons.publish_outlined : Icons.outgoing_mail,
              ),
              label: Text(
                _isNew
                    ? widget.isAdmin
                          ? 'Criar e publicar'
                          : 'Criar e enviar para revisao'
                    : widget.isAdmin
                    ? 'Publicar'
                    : 'Enviar para revisao',
              ),
            ),
          ],
        ),
        if (validationResult != null && !validationResult.isValid) ...<Widget>[
          const SizedBox(height: DSSpacing.md),
          _FormValidationBanner(messages: validationResult.messages),
        ],
        if (errorMessage != null && errorMessage.isNotEmpty) ...<Widget>[
          const SizedBox(height: DSSpacing.md),
          _FormFeedbackBanner(message: errorMessage, isError: true),
        ],
        const SizedBox(height: DSSpacing.lg),
        _Section(
          title: 'Dados principais',
          child: Column(
            children: <Widget>[
              _field(_titleController, 'Titulo'),
              _field(_descriptionController, 'Descricao', maxLines: 4),
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
                        if (value != null) {
                          _updateFormState(() => _segment = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: DSSpacing.md),
                  Expanded(child: _field(_propertyTypeController, 'Tipo')),
                ],
              ),
            ],
          ),
        ),
        _Section(
          title: 'Localizacao',
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(child: _field(_cityController, 'Cidade')),
                  const SizedBox(width: DSSpacing.md),
                  Expanded(child: _field(_neighborhoodController, 'Bairro')),
                ],
              ),
              _field(_subNeighborhoodController, 'Sub-bairro ou quadra'),
            ],
          ),
        ),
        _Section(
          title: 'Caracteristicas e preco',
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: _field(
                      _areaController,
                      'Metros quadrados',
                      integersOnly: true,
                    ),
                  ),
                  const SizedBox(width: DSSpacing.md),
                  Expanded(
                    child: _field(
                      _privateAreaController,
                      'Área privativa (m²)',
                      integersOnly: true,
                    ),
                  ),
                  const SizedBox(width: DSSpacing.md),
                  Expanded(
                    child: _field(
                      _totalAreaController,
                      'Área total (m²)',
                      integersOnly: true,
                    ),
                  ),
                  const SizedBox(width: DSSpacing.md),
                  Expanded(
                    child: _field(
                      _priceController,
                      'Valor em reais',
                      integersOnly: true,
                    ),
                  ),
                ],
              ),
              _slider(
                label: 'Quartos',
                value: _bedrooms,
                max: 10,
                onChanged: (value) => _updateFormState(() => _bedrooms = value),
              ),
              _slider(
                label: 'Banheiros',
                value: _bathrooms,
                max: 10,
                onChanged: (value) =>
                    _updateFormState(() => _bathrooms = value),
              ),
              _slider(
                label: 'Vagas',
                value: _garageSpaces,
                max: 10,
                onChanged: (value) =>
                    _updateFormState(() => _garageSpaces = value),
              ),
              CheckboxListTile(
                value: _isNewDevelopment,
                onChanged: (value) {
                  _updateFormState(() {
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
                    : (value) =>
                          _updateFormState(() => _propertyAgeYears = value),
              ),
            ],
          ),
        ),
        if (widget.isAdmin)
          _Section(
            title: 'Corretor responsavel',
            child: _BrokerDropdown(
              brokers: widget.controller.store.brokers,
              value: _brokerId,
              onChanged: (value) => _updateFormState(() => _brokerId = value),
            ),
          ),
        _Section(
          title: 'Fotos e capa',
          child: _MediaSection(
            property: widget.property,
            controller: widget.controller,
            isBusy: widget.isBusy,
            onUpload: _uploadImages,
            onSetCover: _setCover,
            onDelete: _pendingDelete,
            onRestore: _restore,
          ),
        ),
        _Section(
          title: 'Video, tags e destaque',
          child: Column(
            children: <Widget>[
              _field(_videoController, 'Video YouTube opcional'),
              _field(_tagsController, 'Tags separadas por virgula'),
              CheckboxListTile(
                value: _isFeatured,
                onChanged: (value) {
                  _updateFormState(() => _isFeatured = value ?? false);
                },
                title: const Text('Destacar na vitrine'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
        ),
        _Section(
          title: 'Preview',
          child: _PropertyPreview(
            property: widget.property,
            controller: widget.controller,
            title: _titleController.text,
            city: _cityController.text,
            neighborhood: _neighborhoodController.text,
            price: int.tryParse(_priceController.text.trim()) ?? 0,
            areaM2: int.tryParse(_areaController.text.trim()) ?? 0,
            bedrooms: _bedrooms.round(),
            bathrooms: _bathrooms.round(),
            garageSpaces: _garageSpaces.round(),
          ),
        ),
        if (activeImageCount < 4)
          Padding(
            padding: const EdgeInsets.only(bottom: DSSpacing.md),
            child: Text(
              'Envie pelo menos 4 fotos para finalizar. Atual: $activeImageCount/12.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: DSColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        const SizedBox(height: DSSpacing.xl),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    bool integersOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.sm),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: integersOnly ? TextInputType.number : null,
        inputFormatters: integersOnly
            ? <TextInputFormatter>[
                TextInputFormatter.withFunction((oldValue, newValue) {
                  return RegExp(r'^\d*$').hasMatch(newValue.text)
                      ? newValue
                      : oldValue;
                }),
              ]
            : null,
        onChanged: (_) => _updateFormState(() {}),
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  void _updateFormState(VoidCallback update) {
    setState(() {
      _validationResult = null;
      update();
    });
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

  Future<void> _saveDraft() async {
    final form = _buildForm();
    final validationResult = _validator.validateDraft(
      original: widget.property,
      form: form,
      activeImageUrls: _activeImageUrls(),
    );

    if (!validationResult.isValid) {
      _setValidationResult(validationResult);
      _showMessage(validationResult.messages.first);
      return;
    }

    final wasSaved = await widget.controller.saveProperty(
      form,
      isAdmin: widget.isAdmin,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasSaved
              ? _saveSuccessMessage()
              : widget.controller.store.errorMessage ??
                    'Nao foi possivel salvar as alteracoes.',
        ),
      ),
    );
  }

  Future<void> _finalize() async {
    final form = _buildForm();
    final validationResult = _validator.validatePublish(
      property: widget.property,
      form: form,
    );

    if (!validationResult.isValid) {
      _setValidationResult(validationResult);
      _showMessage('Revise os campos obrigatorios antes de publicar.');
      return;
    }

    final wasSaved = await widget.controller.saveProperty(
      form,
      isAdmin: widget.isAdmin,
    );
    if (!wasSaved) {
      _showCurrentError('Nao foi possivel salvar antes de finalizar.');
      return;
    }

    var wasFinalized = wasSaved;
    if (!_isNew) {
      wasFinalized = await widget.controller.finalizeProperty(
        isAdmin: widget.isAdmin,
      );
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasFinalized
              ? widget.isAdmin
                    ? 'Imovel publicado.'
                    : 'Imovel enviado para revisao.'
              : widget.controller.store.errorMessage ??
                    'Nao foi possivel finalizar o imovel.',
        ),
      ),
    );

    if (_isNew && wasFinalized) {
      Module.get<MainModule>().navigator.pushReplacementNamed(
        widget.isAdmin
            ? MainRoutes.adminProperties
            : MainRoutes.brokerProperties,
      );
    }
  }

  String _saveSuccessMessage() {
    if (widget.isAdmin) return 'Alteracoes salvas.';
    if (widget.property.status == 'published') {
      return 'Alteracoes salvas e enviadas para revisao. O imovel nao fica publico ate confirmacao admin.';
    }
    if (widget.property.status == 'pending_review') {
      return 'Alteracoes salvas e mantidas em revisao.';
    }
    return 'Alteracoes salvas.';
  }

  void _showCurrentError(String fallbackMessage) {
    _showMessage(widget.controller.store.errorMessage ?? fallbackMessage);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _setValidationResult(PropertyFormValidationResult validationResult) {
    setState(() => _validationResult = validationResult);
  }

  Future<void> _uploadImages() async {
    final activeImageCount = widget.property.media
        .where((media) => media.isImage && media.status == 'active')
        .length;
    final remaining = 12 - activeImageCount;
    if (remaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Limite de 12 fotos atingido.')),
      );
      return;
    }

    final images = await pickPropertyImages();
    if (images.isEmpty) return;

    var uploaded = 0;
    for (final image in images.take(remaining)) {
      final upload = PropertyImageUploadEntity(
        fileName: image.fileName,
        mimeType: image.mimeType,
        contentBase64: image.contentBase64,
      );
      final wasUploaded = _isNew
          ? await widget.controller.uploadTemporaryImage(
              uploadSessionId: widget.uploadSessionId,
              image: upload,
            )
          : await widget.controller.uploadImage(upload);
      if (wasUploaded) uploaded++;
    }

    if (uploaded > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$uploaded imagem(ns) enviada(s).')),
      );
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
      coverUrl: widget.property.coverUrl,
      imageUrls: const <String>[],
      videoUrl: _videoController.text,
      areaM2: int.tryParse(_areaController.text.trim()) ?? 0,
      privateAreaM2: int.tryParse(_privateAreaController.text.trim()) ?? 0,
      totalAreaM2: int.tryParse(_totalAreaController.text.trim()) ?? 0,
      bedrooms: _bedrooms.round(),
      bathrooms: _bathrooms.round(),
      garageSpaces: _garageSpaces.round(),
      propertyAgeYears: _propertyAgeYears.round(),
      price: int.tryParse(_priceController.text.trim()) ?? 0,
      tagSlugs: tags,
      isFeatured: _isFeatured,
      isNewDevelopment: _isNewDevelopment,
      brokerId: widget.isAdmin ? _brokerId : null,
      mediaIds: _isNew
          ? widget.property.media
                .where((media) => media.isImage && media.status == 'active')
                .map((media) => media.id)
                .toList()
          : const <String>[],
      coverMediaId: _isNew ? _coverMediaId() : null,
      uploadSessionId: _isNew ? widget.uploadSessionId : null,
    );
  }

  List<String> _activeImageUrls() {
    return widget.property.media
        .where((media) => media.isImage && media.status == 'active')
        .map(
          (media) => media.publicUrl.trim().isNotEmpty
              ? media.publicUrl.trim()
              : media.url.trim(),
        )
        .where((url) => url.isNotEmpty)
        .toList();
  }

  String? _coverMediaId() {
    final coverUrl = widget.property.coverUrl.trim();
    if (coverUrl.isEmpty) return null;

    for (final media in widget.property.media) {
      if (!media.isImage || media.status != 'active') continue;
      if (media.url.trim() == coverUrl || media.publicUrl.trim() == coverUrl) {
        return media.id;
      }
    }

    return null;
  }

  Future<void> _setCover(String mediaId) async {
    if (_isNew) {
      widget.controller.setTemporaryCover(mediaId);
      return;
    }

    await widget.controller.setCover(mediaId);
  }

  Future<void> _pendingDelete(String mediaId) async {
    await widget.controller.pendingDelete(mediaId);
  }

  Future<void> _restore(String mediaId) async {
    await widget.controller.restore(mediaId);
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.lg),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: DSColors.surfaceContainer,
          border: Border.all(color: DSColors.outline),
          borderRadius: DSRadius.md,
        ),
        child: Padding(
          padding: const EdgeInsets.all(DSSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: DSSpacing.md),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _FormFeedbackBanner extends StatelessWidget {
  const _FormFeedbackBanner({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? DSColors.error : DSColors.primary;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        border: Border.all(color: color),
        borderRadius: DSRadius.sm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.sm),
        child: Row(
          children: <Widget>[
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: color,
            ),
            const SizedBox(width: DSSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormValidationBanner extends StatelessWidget {
  const _FormValidationBanner({required this.messages});

  final List<String> messages;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: DSColors.error.withOpacity(0.12),
        border: Border.all(color: DSColors.error),
        borderRadius: DSRadius.sm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.error_outline, color: DSColors.error),
                const SizedBox(width: DSSpacing.sm),
                Expanded(
                  child: Text(
                    'Revise antes de continuar',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: DSColors.error,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.xs),
            ...messages.map(
              (message) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('- ', style: TextStyle(color: DSColors.error)),
                    Expanded(
                      child: Text(
                        message,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: DSColors.error),
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(_label),
      avatar: Icon(_icon, size: 18),
      side: const BorderSide(color: DSColors.outline),
    );
  }

  String get _label {
    return switch (status) {
      'draft' => 'Rascunho',
      'pending_review' => 'Em revisao',
      'published' => 'Publicado',
      'inactive' => 'Inativo',
      'sold' => 'Vendido',
      _ => status,
    };
  }

  IconData get _icon {
    return switch (status) {
      'draft' => Icons.edit_note,
      'pending_review' => Icons.hourglass_top,
      'published' => Icons.public,
      'inactive' => Icons.visibility_off_outlined,
      'sold' => Icons.sell_outlined,
      _ => Icons.info_outline,
    };
  }
}

class _BrokerDropdown extends StatelessWidget {
  const _BrokerDropdown({
    required this.brokers,
    required this.value,
    required this.onChanged,
  });

  final List<AdminBrokerEntity> brokers;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final hasSelectedBroker = brokers.any((broker) => broker.id == value);
    return DropdownButtonFormField<String?>(
      value: hasSelectedBroker ? value : null,
      decoration: const InputDecoration(labelText: 'Corretor responsavel'),
      items: <DropdownMenuItem<String?>>[
        const DropdownMenuItem<String?>(
          value: null,
          child: Text('Sem corretor responsavel'),
        ),
        ...brokers.map(
          (broker) => DropdownMenuItem<String?>(
            value: broker.id,
            child: Text(broker.name),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class _PropertyPreview extends StatelessWidget {
  const _PropertyPreview({
    required this.property,
    required this.controller,
    required this.title,
    required this.city,
    required this.neighborhood,
    required this.price,
    required this.areaM2,
    required this.bedrooms,
    required this.bathrooms,
    required this.garageSpaces,
  });

  final BrokerPropertyEntity property;
  final PropertyFormController controller;
  final String title;
  final String city;
  final String neighborhood;
  final int price;
  final int areaM2;
  final int bedrooms;
  final int bathrooms;
  final int garageSpaces;

  @override
  Widget build(BuildContext context) {
    final imageUrl = _propertyPreviewImageUrl(property);
    final coverMedia = _propertyPreviewMedia(property);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        final image = AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: DSRadius.sm,
            child: _buildPreviewImage(coverMedia, imageUrl),
          ),
        );
        final details = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title.trim().isEmpty ? 'Titulo do imovel' : title.trim(),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: DSSpacing.xs),
            Text('${neighborhood.trim()}, ${city.trim()}'),
            const SizedBox(height: DSSpacing.sm),
            Text('R\$ $price'),
            const SizedBox(height: DSSpacing.sm),
            Wrap(
              spacing: DSSpacing.sm,
              runSpacing: DSSpacing.xs,
              children: <Widget>[
                Chip(label: Text('$areaM2 m2')),
                Chip(label: Text('$bedrooms quartos')),
                Chip(label: Text('$bathrooms banheiros')),
                Chip(label: Text('$garageSpaces vagas')),
              ],
            ),
          ],
        );

        if (!isWide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              image,
              const SizedBox(height: DSSpacing.md),
              details,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(width: 320, child: image),
            const SizedBox(width: DSSpacing.md),
            Expanded(child: details),
          ],
        );
      },
    );
  }

  Widget _buildPreviewImage(PropertyMediaEntity? coverMedia, String imageUrl) {
    if (coverMedia != null) {
      return _MediaFileImage(
        media: coverMedia,
        controller: controller,
        fit: BoxFit.cover,
        placeholderIcon: Icons.image_outlined,
        placeholderSize: 40,
        fallbackUrl: imageUrl,
      );
    }

    if (imageUrl.isEmpty) {
      return const _ImagePlaceholder(icon: Icons.image_outlined, size: 40);
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const _ImagePlaceholder(icon: Icons.image_outlined, size: 40);
      },
    );
  }

  String _propertyPreviewImageUrl(BrokerPropertyEntity property) {
    if (property.coverUrl.trim().isNotEmpty) return property.coverUrl.trim();

    final activeImages = property.media.where(
      (media) => media.isImage && media.status == 'active',
    );
    if (activeImages.isEmpty) return '';

    final firstImage = activeImages.first;
    if (firstImage.publicUrl.trim().isNotEmpty) {
      return firstImage.publicUrl.trim();
    }
    return firstImage.url.trim();
  }

  PropertyMediaEntity? _propertyPreviewMedia(BrokerPropertyEntity property) {
    final activeImages = property.media.where(
      (media) => media.isImage && media.status == 'active',
    );
    if (activeImages.isEmpty) return null;

    final coverUrl = property.coverUrl.trim();
    if (coverUrl.isEmpty) return activeImages.first;

    for (final media in activeImages) {
      if (media.publicUrl.trim() == coverUrl || media.url.trim() == coverUrl) {
        return media;
      }
    }

    return activeImages.first;
  }
}

class _MediaSection extends StatelessWidget {
  const _MediaSection({
    required this.property,
    required this.controller,
    required this.isBusy,
    required this.onUpload,
    required this.onSetCover,
    required this.onDelete,
    required this.onRestore,
  });

  final BrokerPropertyEntity property;
  final PropertyFormController controller;
  final bool isBusy;
  final VoidCallback onUpload;
  final ValueChanged<String> onSetCover;
  final ValueChanged<String> onDelete;
  final ValueChanged<String> onRestore;

  @override
  Widget build(BuildContext context) {
    final mediaItems = property.media.where((media) => media.isImage).toList();
    final activeCount = mediaItems
        .where((media) => media.status == 'active')
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Fotos ($activeCount/12)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            FilledButton.icon(
              onPressed: isBusy ? null : onUpload,
              icon: const Icon(Icons.upload_file_outlined),
              label: const Text('Enviar imagem'),
            ),
          ],
        ),
        const SizedBox(height: DSSpacing.md),
        if (mediaItems.isEmpty)
          const Text('Nenhuma imagem enviada ainda.')
        else
          Wrap(
            spacing: DSSpacing.md,
            runSpacing: DSSpacing.md,
            children: mediaItems.map((media) {
              final imageUrl = media.publicUrl.trim().isNotEmpty
                  ? media.publicUrl.trim()
                  : media.url.trim();
              final isCover =
                  imageUrl == property.coverUrl ||
                  media.url == property.coverUrl ||
                  media.publicUrl == property.coverUrl;
              return SizedBox(
                width: 220,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: DSColors.surfaceContainer,
                    border: Border.all(
                      color: isCover ? DSColors.primary : DSColors.outline,
                    ),
                    borderRadius: DSRadius.md,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(DSSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        AspectRatio(
                          aspectRatio: 4 / 3,
                          child: ClipRRect(
                            borderRadius: DSRadius.sm,
                            child: _MediaFileImage(
                              media: media,
                              controller: controller,
                              fit: BoxFit.cover,
                              placeholderIcon: Icons.image_not_supported,
                              fallbackUrl: imageUrl,
                            ),
                          ),
                        ),
                        const SizedBox(height: DSSpacing.sm),
                        Text(
                          media.status == 'pending_delete'
                              ? 'Remocao pendente'
                              : isCover
                              ? 'Capa atual'
                              : 'Imagem',
                        ),
                        const SizedBox(height: DSSpacing.sm),
                        if (media.status == 'pending_delete')
                          OutlinedButton.icon(
                            onPressed: isBusy
                                ? null
                                : () => onRestore(media.id),
                            icon: const Icon(Icons.restore_outlined),
                            label: const Text('Restaurar'),
                          )
                        else ...<Widget>[
                          OutlinedButton.icon(
                            onPressed: isBusy || isCover
                                ? null
                                : () => onSetCover(media.id),
                            icon: const Icon(Icons.star_outline),
                            label: const Text('Usar como capa'),
                          ),
                          const SizedBox(height: DSSpacing.xs),
                          OutlinedButton.icon(
                            onPressed: isBusy ? null : () => onDelete(media.id),
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Remover'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.icon, this.size});

  final IconData icon;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: DSColors.surfaceContainerHighest,
      child: Center(child: Icon(icon, size: size)),
    );
  }
}

class _MediaFileImage extends StatefulWidget {
  const _MediaFileImage({
    required this.media,
    required this.controller,
    required this.fit,
    required this.placeholderIcon,
    this.placeholderSize,
    this.fallbackUrl = '',
  });

  final PropertyMediaEntity media;
  final PropertyFormController controller;
  final BoxFit fit;
  final IconData placeholderIcon;
  final double? placeholderSize;
  final String fallbackUrl;

  @override
  State<_MediaFileImage> createState() => _MediaFileImageState();
}

class _MediaFileImageState extends State<_MediaFileImage> {
  late Future<Uint8List?> _fileFuture;

  @override
  void initState() {
    super.initState();
    _fileFuture = widget.controller.loadMediaFile(widget.media.id);
  }

  @override
  void didUpdateWidget(covariant _MediaFileImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.media.id != widget.media.id) {
      _fileFuture = widget.controller.loadMediaFile(widget.media.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _fileFuture,
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

        final fallbackUrl = widget.fallbackUrl.trim();
        if (fallbackUrl.isNotEmpty) {
          return Image.network(
            fallbackUrl,
            fit: widget.fit,
            errorBuilder: (context, error, stackTrace) {
              return _ImagePlaceholder(
                icon: widget.placeholderIcon,
                size: widget.placeholderSize,
              );
            },
          );
        }

        return _ImagePlaceholder(
          icon: widget.placeholderIcon,
          size: widget.placeholderSize,
        );
      },
    );
  }
}
