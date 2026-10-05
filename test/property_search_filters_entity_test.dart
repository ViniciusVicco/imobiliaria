import 'package:flutter_test/flutter_test.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/property_search_filters_entity.dart';

void main() {
  group('PropertySearchFiltersEntity', () {
    test(
      'serializes the unfiltered stock without segment or property type',
      () {
        const filters = PropertySearchFiltersEntity();

        expect(filters.toQueryParameters(), <String, String>{'city': 'Palmas'});
      },
    );

    test('parses and serializes a filtered stock URL deterministically', () {
      final filters = PropertySearchFiltersEntity.fromQueryParameters(
        const <String, String>{
          'city': 'Palmas',
          'segment': 'residential',
          'propertyType': 'apartment',
          'blockOrNeighborhood': '706 Sul',
          'bedroomsMin': '2',
          'priceMax': '900000',
        },
      );

      expect(filters.segment, PropertySegment.residential);
      expect(filters.propertyType, ResidentialPropertyType.apartment);
      expect(filters.bedroomsMin, 2);
      expect(filters.priceMax, 900000);
      expect(filters.toQueryParameters(), <String, String>{
        'blockOrNeighborhood': '706 Sul',
        'city': 'Palmas',
        'segment': 'residential',
        'propertyType': 'apartment',
        'bedroomsMin': '2',
        'priceMax': '900000',
      });
    });

    test('invalid or missing type falls back to all types', () {
      final filters = PropertySearchFiltersEntity.fromQueryParameters(
        const <String, String>{
          'segment': 'commercial',
          'propertyType': 'apartment',
        },
      );

      expect(filters.segment, PropertySegment.commercial);
      expect(filters.propertyType, AnyPropertyType.any);
    });

    test('tag without segment is represented as tag-only shortcut', () {
      final filters = PropertySearchFiltersEntity.fromQueryParameters(
        const <String, String>{'tag': 'na-planta'},
      );

      expect(filters.tagOnly, isTrue);
      expect(filters.toQueryParameters(), <String, String>{
        'city': 'Palmas',
        'tag': 'na-planta',
      });
    });
  });
}
