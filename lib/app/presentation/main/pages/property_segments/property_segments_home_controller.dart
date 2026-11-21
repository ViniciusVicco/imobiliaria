import 'package:imobiliaria/app/domain/property_segments/entities/featured_property_entity.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/property_search_filters_entity.dart';
import 'package:imobiliaria/app/domain/property_segments/usecases/build_property_search_query_use_case.dart';
import 'package:imobiliaria/app/domain/property_segments/usecases/get_featured_properties_use_case.dart';
import 'package:imobiliaria/app/domain/property_segments/usecases/get_home_brand_content_use_case.dart';
import 'package:imobiliaria/app/domain/property_segments/usecases/resolve_property_segment_route_use_case.dart';
import 'package:imobiliaria/app/presentation/main/main_routes.dart';
import 'package:imobiliaria/app/presentation/main/pages/property_segments/property_segments_home_store.dart';
import 'package:legend_core/legend_core.dart';
import 'package:imobiliaria/app/domain/outbound_links/external_link_service.dart';

class PropertySegmentsHomeController extends Controller {
  PropertySegmentsHomeController({
    required this.store,
    required this.resolveSegmentRoute,
    required this.buildPropertySearchQuery,
    required this.getFeaturedProperties,
    required this.getHomeBrandContent,
    required AppNavigator navigator,
    required ExternalLinkService externalLinks,
  }) : _navigator = navigator,
       _externalLinks = externalLinks;

  final PropertySegmentsHomeStore store;
  final ResolvePropertySegmentRouteUseCase resolveSegmentRoute;
  final BuildPropertySearchQueryUseCase buildPropertySearchQuery;
  final GetFeaturedPropertiesUseCase getFeaturedProperties;
  final GetHomeBrandContentUseCase getHomeBrandContent;
  final AppNavigator _navigator;
  final ExternalLinkService _externalLinks;

  Future<void> loadHome() async {
    store.setLoading();

    final featuredResult = await getFeaturedProperties.call();
    final brandResult = await getHomeBrandContent.call();
    featuredResult.getResult(
      onSuccess: (featuredProperties) {
        brandResult.getResult(
          onSuccess: (brandContent) {
            store.setHomeContent(
              featuredProperties: featuredProperties,
              brandContent: brandContent,
            );
          },
          onError: (error) => store.setError(error.message),
        );
      },
      onError: (error) => store.setError(error.message),
    );
  }

  void updateFilters(PropertySearchFiltersEntity filters) {
    store.setFilters(filters);
  }

  void updateSegment(PropertySegment segment) {
    store.setFilters(
      store.filters.copyWith(segment: segment, tag: '', tagOnly: false),
    );
  }

  Future<void> onSearchSubmitted() async {
    final result = await buildPropertySearchQuery.call(filters: store.filters);

    result.getResult(
      onSuccess: (uri) => _navigator.pushNamed(uri.toString()),
      onError: (error) => store.setError(error.message),
    );
  }

  void onStockPressed() {
    _navigator.pushNamed(MainRoutes.stock);
  }

  Future<void> onNewDevelopmentsPressed() async {
    store.setFilters(
      const PropertySearchFiltersEntity(tag: 'na-planta', tagOnly: true),
    );
    await onSearchSubmitted();
  }

  Future<void> onVideoPressed() async {
    final videoUrl = store.brandContent?.videoUrl;
    if (videoUrl == null || videoUrl.isEmpty) return;

    final wasOpened = await _externalLinks.open(videoUrl, source: 'home_video');
    if (!wasOpened) {
      store.setError('Nao foi possivel abrir o video da Seletta.');
    }
  }

  Future<void> onWhatsappPressed() async {
    await _openWhatsappWithMessage(
      'Olá, vi seus destaques do site e quero falar com a Seletta sobre imoveis em Palmas.',
      source: 'home_whatsapp',
    );
  }

  Future<void> onPropertyWhatsappPressed(
    FeaturedPropertyEntity property,
  ) async {
    await _openWhatsappWithMessage(
      'Vi uma oportunidade ${property.title} - ${property.id} e gostaria de saber mais',
      source: 'home_property_whatsapp',
      propertyId: property.id,
    );
  }

  Future<void> _openWhatsappWithMessage(
    String message, {
    required String source,
    String? propertyId,
  }) async {
    final rawWhatsapp = store.brandContent?.contact.whatsapp;
    final whatsappNumber = _normalizeBrazilianWhatsapp(rawWhatsapp);
    if (whatsappNumber == null) {
      store.setError('Nao foi possivel encontrar o WhatsApp da Seletta.');
      return;
    }

    final uri = Uri.https('wa.me', '/$whatsappNumber', <String, String>{
      'text': message,
    });
    final wasOpened = await _externalLinks.open(
      uri.toString(),
      source: source,
      propertyId: propertyId,
    );
    if (!wasOpened) {
      store.setError('Nao foi possivel abrir o WhatsApp da Seletta.');
    }
  }

  String? _normalizeBrazilianWhatsapp(String? rawWhatsapp) {
    final digits = rawWhatsapp?.replaceAll(RegExp(r'\D'), '');
    if (digits == null || digits.isEmpty) return null;
    if (digits.startsWith('55')) return digits;
    return '55$digits';
  }

  Future<void> onSegmentPressed({required String targetRoute}) async {
    store.setLoading();

    final result = await resolveSegmentRoute.call(targetRoute: targetRoute);

    result.getResult(
      onSuccess: (success) {
        if (success.canNavigate) {
          store.setSuccess();
          _navigator.pushNamed(success.route);
          return;
        }

        store.setError('Nao foi possivel abrir este segmento agora.');
      },
      onError: (error) {
        store.setError(error.message);
      },
    );
  }
}
