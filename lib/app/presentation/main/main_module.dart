//Aqui fica o modulo principal
import 'package:legend_core/legend_core.dart';
import 'package:imobiliaria/app/domain/users/entities/authenticated_user_entity.dart';

import 'pages/admin/admin_home_page.dart';
import 'pages/broker/broker_home_page.dart';
import 'pages/property_segments/property_segments_home_page.dart';
import 'pages/search/property_search_page.dart';
import 'pages/segment_details/segment_details_page.dart';
import 'widgets/auth/auth_guard_page.dart';
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
    MainRoutes.broker: (context, arguments) => const AuthGuardPage(
      requiredRole: UserRole.broker,
      requestedRoute: MainRoutes.broker,
      child: BrokerHomePage(),
    ),
    MainRoutes.brokerProperties: (context, arguments) => const AuthGuardPage(
      requiredRole: UserRole.broker,
      requestedRoute: MainRoutes.brokerProperties,
      child: BrokerHomePage(),
    ),
    MainRoutes.admin: (context, arguments) => const AuthGuardPage(
      requiredRole: UserRole.admin,
      requestedRoute: MainRoutes.admin,
      child: AdminHomePage(),
    ),
    MainRoutes.adminUsers: (context, arguments) => const AuthGuardPage(
      requiredRole: UserRole.admin,
      requestedRoute: MainRoutes.adminUsers,
      child: AdminHomePage(),
    ),
    MainRoutes.adminProperties: (context, arguments) => const AuthGuardPage(
      requiredRole: UserRole.admin,
      requestedRoute: MainRoutes.adminProperties,
      child: AdminHomePage(),
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
      title: 'Novidades na planta',
      description:
          'Rota temporaria para oportunidades com tag na planta. A busca publica usa /search?city=Palmas&tag=na-planta.',
    ),
    MainRoutes
        .announceProperty: (context, arguments) => const SegmentDetailsPage(
      title: 'Anunciar meu imovel',
      description:
          'Area para proprietarios cadastrarem anuncios, adicionarem fotos e receberem propostas.',
    ),
  };
}
