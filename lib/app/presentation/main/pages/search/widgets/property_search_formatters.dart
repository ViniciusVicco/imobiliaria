import 'package:imobiliaria/app/domain/property_segments/entities/search_property_entity.dart';

String formatPropertyLocation(SearchPropertyEntity property) {
  return <String>[
    if (property.subNeighborhood.trim().isNotEmpty)
      property.subNeighborhood.trim(),
    property.neighborhood.trim(),
    property.city.trim(),
  ].where((part) => part.isNotEmpty).join(' - ');
}

String formatPrice(int price) {
  final text = price.toString();
  final buffer = StringBuffer();
  for (var index = 0; index < text.length; index++) {
    final positionFromEnd = text.length - index;
    buffer.write(text[index]);
    if (positionFromEnd > 1 && positionFromEnd % 3 == 1) buffer.write('.');
  }
  return 'R\$ ${buffer.toString()}';
}

String tagLabel(String tag) {
  return switch (tag) {
    'na-planta' => 'Na planta',
    'recem-entregue' => 'Recem entregue',
    'alta-rentabilidade' => 'Alta rentabilidade',
    'entrada-reduzida' => 'Entrada reduzida',
    'exclusivo' => 'Exclusivo',
    'pronto-para-morar' => 'Pronto para morar',
    _ => tag,
  };
}
