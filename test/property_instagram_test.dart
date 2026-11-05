import 'package:flutter_test/flutter_test.dart';
import 'package:imobiliaria/app/data/broker/models/broker_property_model.dart';

void main() {
  test('Instagram link survives loading and editing a property', () {
    const url = 'https://www.instagram.com/reel/imovel/';
    final property = BrokerPropertyModel.fromJson({
      'id': 'property',
      'instagramUrl': url,
    });

    final form = property.copyWith(title: 'Casa').toForm();
    expect(form.toJson()['instagramUrl'], url);
    expect(form.title, 'Casa');
    expect(
      property.copyWith(instagramUrl: '').toForm().toJson()['instagramUrl'],
      '',
    );
  });

  test('properties without an Instagram link remain editable', () {
    final property = BrokerPropertyModel.fromJson({'id': 'legacy-property'});
    expect(property.instagramUrl, '');
    expect(property.toForm().toJson()['instagramUrl'], '');
  });
}
