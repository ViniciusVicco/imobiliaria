class PropertySearchFiltersEntity {
  const PropertySearchFiltersEntity({
    this.query = '',
    this.blockOrNeighborhood = '',
    this.city = 'Palmas',
    this.segment = PropertySegment.all,
    this.propertyType = AnyPropertyType.any,
    this.tag = '',
    this.tagOnly = false,
    this.bedroomsMin,
    this.bathroomsMin,
    this.garageSpacesMin,
    this.priceMin,
    this.priceMax,
  });

  final String query;
  final String blockOrNeighborhood;
  final String city;
  final PropertySegment segment;
  final PropertyFilterOption propertyType;
  final String tag;
  final bool tagOnly;
  final int? bedroomsMin;
  final int? bathroomsMin;
  final int? garageSpacesMin;
  final int? priceMin;
  final int? priceMax;

  PropertySearchFiltersEntity copyWith({
    String? query,
    String? blockOrNeighborhood,
    String? city,
    PropertySegment? segment,
    PropertyFilterOption? propertyType,
    String? tag,
    bool? tagOnly,
    int? bedroomsMin,
    int? bathroomsMin,
    int? garageSpacesMin,
    int? priceMin,
    int? priceMax,
    bool clearBedrooms = false,
    bool clearBathrooms = false,
    bool clearGarageSpaces = false,
    bool clearPriceMin = false,
    bool clearPriceMax = false,
  }) {
    final nextSegment = segment ?? this.segment;
    final nextPropertyType =
        propertyType ??
        (segment == null ? this.propertyType : nextSegment.defaultPropertyType);

    return PropertySearchFiltersEntity(
      query: query ?? this.query,
      blockOrNeighborhood: blockOrNeighborhood ?? this.blockOrNeighborhood,
      city: city ?? this.city,
      segment: nextSegment,
      propertyType: nextPropertyType,
      tag: tag ?? this.tag,
      tagOnly: tagOnly ?? this.tagOnly,
      bedroomsMin: clearBedrooms ? null : bedroomsMin ?? this.bedroomsMin,
      bathroomsMin: clearBathrooms ? null : bathroomsMin ?? this.bathroomsMin,
      garageSpacesMin: clearGarageSpaces
          ? null
          : garageSpacesMin ?? this.garageSpacesMin,
      priceMin: clearPriceMin ? null : priceMin ?? this.priceMin,
      priceMax: clearPriceMax ? null : priceMax ?? this.priceMax,
    );
  }

  Map<String, String> toQueryParameters() {
    return <String, String>{
      if (query.trim().isNotEmpty) 'query': query.trim(),
      if (blockOrNeighborhood.trim().isNotEmpty)
        'blockOrNeighborhood': blockOrNeighborhood.trim(),
      'city': city.trim(),
      if (!tagOnly && segment.value.isNotEmpty) 'segment': segment.value,
      if (!tagOnly && propertyType.value.isNotEmpty)
        'propertyType': propertyType.value,
      if (tag.trim().isNotEmpty) 'tag': tag.trim(),
      if (bedroomsMin != null) 'bedroomsMin': bedroomsMin.toString(),
      if (bathroomsMin != null) 'bathroomsMin': bathroomsMin.toString(),
      if (garageSpacesMin != null)
        'garageSpacesMin': garageSpacesMin.toString(),
      if (priceMin != null) 'priceMin': priceMin.toString(),
      if (priceMax != null) 'priceMax': priceMax.toString(),
    };
  }

  factory PropertySearchFiltersEntity.fromQueryParameters(
    Map<String, String> queryParameters,
  ) {
    final segment = PropertySegment.fromValue(queryParameters['segment']);
    final propertyType = _propertyTypeFromValue(
      segment: segment,
      value: queryParameters['propertyType'],
    );

    return PropertySearchFiltersEntity(
      query: queryParameters['query'] ?? '',
      blockOrNeighborhood: queryParameters['blockOrNeighborhood'] ?? '',
      city: queryParameters['city']?.trim().isNotEmpty == true
          ? queryParameters['city']!.trim()
          : 'Palmas',
      segment: segment,
      propertyType: propertyType,
      tag: queryParameters['tag'] ?? '',
      tagOnly:
          (queryParameters['tag']?.trim().isNotEmpty ?? false) &&
          segment == PropertySegment.all &&
          propertyType == AnyPropertyType.any,
      bedroomsMin: int.tryParse(queryParameters['bedroomsMin'] ?? ''),
      bathroomsMin: int.tryParse(queryParameters['bathroomsMin'] ?? ''),
      garageSpacesMin: int.tryParse(queryParameters['garageSpacesMin'] ?? ''),
      priceMin: int.tryParse(queryParameters['priceMin'] ?? ''),
      priceMax: int.tryParse(queryParameters['priceMax'] ?? ''),
    );
  }
}

enum PropertySegment {
  all('', 'Todos os segmentos'),
  residential('residential', 'Residencial'),
  commercial('commercial', 'Comercial');

  const PropertySegment(this.value, this.label);

  final String value;
  final String label;

  List<PropertyFilterOption> get propertyTypes {
    return switch (this) {
      PropertySegment.all => AnyPropertyType.values,
      PropertySegment.residential => <PropertyFilterOption>[
        AnyPropertyType.any,
        ...ResidentialPropertyType.values,
      ],
      PropertySegment.commercial => <PropertyFilterOption>[
        AnyPropertyType.any,
        ...CommercialPropertyType.values,
      ],
    };
  }

  PropertyFilterOption get defaultPropertyType => propertyTypes.first;

  static PropertySegment fromValue(String? value) {
    return PropertySegment.values.firstWhere(
      (segment) => segment.value == value,
      orElse: () => PropertySegment.all,
    );
  }
}

abstract interface class PropertyFilterOption {
  String get value;
  String get label;
}

enum AnyPropertyType implements PropertyFilterOption {
  any('', 'Todos os tipos');

  const AnyPropertyType(this.value, this.label);

  @override
  final String value;

  @override
  final String label;
}

enum ResidentialPropertyType implements PropertyFilterOption {
  apartment('apartment', 'Apartamento'),
  house('house', 'Casa'),
  condominiumHouse('condominium-house', 'Casa em condominio'),
  townhouse('townhouse', 'Sobrado'),
  kitchenette('kitchenette', 'Kitnet'),
  studio('studio', 'Studio');

  const ResidentialPropertyType(this.value, this.label);

  @override
  final String value;

  @override
  final String label;
}

enum CommercialPropertyType implements PropertyFilterOption {
  commercialRoom('commercial-room', 'Sala comercial'),
  store('store', 'Loja'),
  warehouse('warehouse', 'Galpao'),
  commercialBuilding('commercial-building', 'Predio comercial'),
  businessPoint('business-point', 'Ponto comercial'),
  commercialLand('commercial-land', 'Terreno comercial'),
  coworking('coworking', 'Coworking'),
  clinicOffice('clinic-office', 'Consultorio');

  const CommercialPropertyType(this.value, this.label);

  @override
  final String value;

  @override
  final String label;
}

PropertyFilterOption _propertyTypeFromValue({
  required PropertySegment segment,
  required String? value,
}) {
  if (value == null || value.trim().isEmpty) return AnyPropertyType.any;

  return segment.propertyTypes.firstWhere(
    (option) => option.value == value,
    orElse: () => AnyPropertyType.any,
  );
}
