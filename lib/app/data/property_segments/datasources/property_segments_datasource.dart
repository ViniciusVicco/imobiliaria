import 'package:legend_core/legend_core.dart';

class PropertySegmentsDatasource {
  Future<DataSourceResponse<Map<String, dynamic>>> resolveSegmentRoute({
    required String targetRoute,
  }) async {
    return DataSourceResponse<Map<String, dynamic>>(
      data: <String, dynamic>{'canNavigate': true, 'route': targetRoute},
      hasSuccess: true,
    );
  }

  Future<DataSourceResponse<List<Map<String, dynamic>>>>
  getFeaturedProperties() async {
    return DataSourceResponse<List<Map<String, dynamic>>>(
      data: <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'prop_001',
          'title': 'Apartamento com varanda gourmet',
          'segment': 'residential',
          'propertyType': 'Apartamento',
          'city': 'Sao Paulo',
          'neighborhood': 'Pinheiros',
          'coverUrl':
              'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=1200&q=80',
          'areaM2': 82,
          'bedrooms': 2,
          'bathrooms': 2,
          'garageSpaces': 1,
          'propertyAgeYears': 4,
          'price': 850000,
        },
        <String, dynamic>{
          'id': 'prop_002',
          'title': 'Sala comercial pronta para receber clientes',
          'segment': 'commercial',
          'propertyType': 'Sala comercial',
          'city': 'Sao Paulo',
          'neighborhood': 'Vila Olimpia',
          'coverUrl':
              'https://images.unsplash.com/photo-1497366811353-6870744d04b2?auto=format&fit=crop&w=1200&q=80',
          'areaM2': 54,
          'bedrooms': null,
          'bathrooms': 2,
          'garageSpaces': 1,
          'propertyAgeYears': 7,
          'price': 620000,
        },
        <String, dynamic>{
          'id': 'prop_003',
          'title': 'Projeto na planta com lazer completo',
          'segment': 'investments',
          'propertyType': 'Oportunidades na planta',
          'city': 'Sao Paulo',
          'neighborhood': 'Mooca',
          'coverUrl':
              'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&w=1200&q=80',
          'areaM2': 68,
          'bedrooms': 2,
          'bathrooms': 2,
          'garageSpaces': 1,
          'propertyAgeYears': 0,
          'price': 560000,
        },
      ],
      hasSuccess: true,
    );
  }

  Future<DataSourceResponse<Map<String, dynamic>>> getHomeBrandContent() async {
    return DataSourceResponse<Map<String, dynamic>>(
      data: <String, dynamic>{
        'mission':
            'Conectar pessoas a imoveis com clareza, criterio e acompanhamento humano.',
        'about':
            'A Seletta atua na curadoria de oportunidades residenciais, comerciais e de investimento.',
        'contact': <String, dynamic>{
          'phone': '(11) 3000-0000',
          'email': 'contato@seletta.com.br',
          'whatsapp': '(11) 99999-0000',
        },
        'videoUrl':
            'https://www.youtube.com/watch?v=dQw4w9WgXcQ&list=RDdQw4w9WgXcQ&start_radio=1',
      },
      hasSuccess: true,
    );
  }
}
