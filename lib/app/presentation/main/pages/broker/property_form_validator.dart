import 'package:imobiliaria/app/domain/broker/entities/broker_property_entity.dart';

class PropertyFormValidationResult {
  const PropertyFormValidationResult({
    required this.isValid,
    required this.messages,
    required this.changedFieldsCount,
  });

  final bool isValid;
  final List<String> messages;
  final int changedFieldsCount;

  String get summary => messages.join('\n');
}

class PropertyFormValidator {
  const PropertyFormValidator();

  PropertyFormValidationResult validateDraft({
    required BrokerPropertyEntity original,
    required BrokerPropertyFormEntity form,
    required List<String> activeImageUrls,
  }) {
    final changedFieldsCount = _changedFieldsCount(
      original: original,
      form: form,
      activeImageUrls: activeImageUrls,
    );

    if (changedFieldsCount < 3) {
      return PropertyFormValidationResult(
        isValid: false,
        changedFieldsCount: changedFieldsCount,
        messages: const <String>[
          'Altere pelo menos 3 informacoes para salvar o rascunho.',
        ],
      );
    }

    return PropertyFormValidationResult(
      isValid: true,
      changedFieldsCount: changedFieldsCount,
      messages: const <String>[],
    );
  }

  PropertyFormValidationResult validatePublish({
    required BrokerPropertyEntity property,
    required BrokerPropertyFormEntity form,
  }) {
    final messages = <String>[];
    final activeImages = property.media
        .where((media) => media.isImage && media.status == 'active')
        .toList();
    final coverUrl = property.coverUrl.trim();
    final hasActiveCover = activeImages.any(
      (media) =>
          media.url.trim() == coverUrl || media.publicUrl.trim() == coverUrl,
    );

    if (form.title.trim().isEmpty) messages.add('Preencha o titulo.');
    if (form.propertyType.trim().isEmpty) {
      messages.add('Preencha o tipo do imovel.');
    }
    if (form.city.trim().isEmpty) messages.add('Preencha a cidade.');
    if (form.neighborhood.trim().isEmpty) messages.add('Preencha o bairro.');
    if (form.areaM2 <= 0) {
      messages.add('Informe a metragem maior que zero.');
    }
    if (form.price <= 0) {
      messages.add('Informe o valor do imovel maior que zero.');
    }
    if (activeImages.length < 4 || activeImages.length > 12) {
      messages.add('Envie entre 4 e 12 fotos ativas.');
    }
    if (coverUrl.isEmpty || !hasActiveCover) {
      messages.add('Defina uma foto de capa ativa.');
    }

    return PropertyFormValidationResult(
      isValid: messages.isEmpty,
      messages: messages,
      changedFieldsCount: _changedFieldsCount(
        original: property,
        form: form,
        activeImageUrls: activeImages.map((media) => media.url).toList(),
      ),
    );
  }

  int _changedFieldsCount({
    required BrokerPropertyEntity original,
    required BrokerPropertyFormEntity form,
    required List<String> activeImageUrls,
  }) {
    final changedFields = <String>{};

    void countIf(String field, bool condition) {
      if (condition) changedFields.add(field);
    }

    countIf(
      'title',
      _normalized(form.title) != _normalized(original.title),
    );
    countIf(
      'description',
      _normalized(form.description) != _normalized(original.description),
    );
    countIf('segment', form.segment != original.segment);
    countIf(
      'propertyType',
      _normalized(form.propertyType) != _normalized(original.propertyType),
    );
    countIf('city', _normalized(form.city) != _normalized(original.city));
    countIf(
      'neighborhood',
      _normalized(form.neighborhood) != _normalized(original.neighborhood),
    );
    countIf(
      'subNeighborhood',
      _normalized(form.subNeighborhood) !=
          _normalized(original.subNeighborhood),
    );
    countIf('coverUrl', _normalized(form.coverUrl) != _normalized(original.coverUrl));
    countIf('videoUrl', _normalized(form.videoUrl) != _normalized(original.videoUrl));
    countIf('areaM2', form.areaM2 != original.areaM2);
    countIf('bedrooms', form.bedrooms != original.bedrooms);
    countIf('bathrooms', form.bathrooms != original.bathrooms);
    countIf('garageSpaces', form.garageSpaces != original.garageSpaces);
    countIf(
      'propertyAgeYears',
      form.propertyAgeYears != original.propertyAgeYears,
    );
    countIf('price', form.price != original.price);
    countIf('isFeatured', form.isFeatured != original.isFeatured);
    countIf(
      'isNewDevelopment',
      form.isNewDevelopment != original.tags.contains('na-planta'),
    );
    countIf(
      'brokerId',
      _normalized(form.brokerId ?? '') != _normalized(original.broker?.id ?? ''),
    );
    countIf(
      'tagSlugs',
      _normalizedList(form.tagSlugs).join(',') !=
          _normalizedList(original.tags).join(','),
    );

    final originalActiveImageCount = original.media
        .where((media) => media.isImage && media.status == 'active')
        .length;
    countIf('images', activeImageUrls.length != originalActiveImageCount);

    changedFields.addAll(_meaningfulDraftContentFields(
      form: form,
      activeImageUrls: activeImageUrls,
    ));

    return changedFields.length;
  }

  Set<String> _meaningfulDraftContentFields({
    required BrokerPropertyFormEntity form,
    required List<String> activeImageUrls,
  }) {
    final fields = <String>{};
    if (_normalized(form.title).isNotEmpty &&
        _normalized(form.title) != 'novo imovel') {
      fields.add('title');
    }
    if (_normalized(form.description).isNotEmpty) fields.add('description');
    if (_normalized(form.neighborhood).isNotEmpty &&
        _normalized(form.neighborhood) != 'a definir') {
      fields.add('neighborhood');
    }
    if (form.areaM2 > 0) fields.add('areaM2');
    if (form.price > 0) fields.add('price');
    if (activeImageUrls.isNotEmpty) fields.add('images');
    if (_normalized(form.coverUrl).isNotEmpty) fields.add('coverUrl');
    if (_normalized(form.videoUrl).isNotEmpty) fields.add('videoUrl');
    if (form.tagSlugs.isNotEmpty) fields.add('tagSlugs');
    if (form.isFeatured) fields.add('isFeatured');
    if (_normalized(form.brokerId ?? '').isNotEmpty) fields.add('brokerId');
    return fields;
  }

  String _normalized(String value) => value.trim().toLowerCase();

  List<String> _normalizedList(List<String> values) {
    return values.map(_normalized).where((value) => value.isNotEmpty).toList()
      ..sort();
  }
}
