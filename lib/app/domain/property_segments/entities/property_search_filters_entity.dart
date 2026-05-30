class PropertySearchFiltersEntity {
  const PropertySearchFiltersEntity({
    this.query = '',
    this.blockOrNeighborhood = '',
    this.city = 'Palmas',
    this.segment = PropertySegment.residential,
    this.propertyType = ResidentialPropertyType.apartment,
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
      if (!tagOnly) 'segment': segment.value,
      if (!tagOnly) 'propertyType': propertyType.value,
      if (tag.trim().isNotEmpty) 'tag': tag.trim(),
      if (bedroomsMin != null) 'bedroomsMin': bedroomsMin.toString(),
      if (bathroomsMin != null) 'bathroomsMin': bathroomsMin.toString(),
      if (garageSpacesMin != null)
        'garageSpacesMin': garageSpacesMin.toString(),
      if (priceMin != null) 'priceMin': priceMin.toString(),
      if (priceMax != null) 'priceMax': priceMax.toString(),
    };
  }
}

enum PropertySegment {
  residential('residential', 'Residencial'),
  commercial('commercial', 'Comercial');

  const PropertySegment(this.value, this.label);

  final String value;
  final String label;

  List<PropertyFilterOption> get propertyTypes {
    return switch (this) {
      PropertySegment.residential => ResidentialPropertyType.values,
      PropertySegment.commercial => CommercialPropertyType.values,
    };
  }

  PropertyFilterOption get defaultPropertyType => propertyTypes.first;
}

abstract interface class PropertyFilterOption {
  String get value;
  String get label;
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
