//Aqui fica o modulo principal
import 'package:legend_core/legend_core.dart';

import 'pages/property_segments/property_segments_home_page.dart';
import 'pages/search/property_search_page.dart';
import 'pages/segment_details/segment_details_page.dart';
import 'main_routes.dart';
import 'main_injector.dart';

class MainModule extends Module {
  MainModule();

  @override
  String get initialRoute => MainRoutes.home;

  @override
  ModuleInjector<MainModule> get injector => PropertySegmentsModuleInjector();

  @override
  Map<String, RouteBuilder> get routes => <String, RouteBuilder>{
    MainRoutes.home: (context, arguments) => PropertySegmentsHomePage(),
    MainRoutes.search: (context, arguments) => PropertySearchPage(
      routeData: arguments is ModuleRouteData ? arguments : null,
    ),
    MainRoutes.commercial: (context, arguments) => const SegmentDetailsPage(
      title: 'Commercial Spaces',
      description:
          'Catalog for offices, coworking floors and commercial units.',
    ),
    MainRoutes.residential: (context, arguments) => const SegmentDetailsPage(
      title: 'Residential Homes',
      description:
          'Catalog for houses, apartments and family-oriented properties.',
    ),
    MainRoutes.investments: (context, arguments) => const SegmentDetailsPage(
      title: 'Investment Assets',
      description:
          'Catalog for investment opportunities and upcoming projects.',
    ),
    MainRoutes
        .announceProperty: (context, arguments) => const SegmentDetailsPage(
      title: 'Anunciar meu imovel',
      description:
          'Area para proprietarios cadastrarem anuncios, adicionarem fotos e receberem propostas.',
    ),
  };
}
