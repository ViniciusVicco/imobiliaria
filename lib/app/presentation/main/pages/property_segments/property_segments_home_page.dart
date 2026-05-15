import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/featured_property_entity.dart';
import 'package:imobiliaria/app/domain/property_segments/entities/property_search_filters_entity.dart';
import 'package:imobiliaria/app/presentation/main/main_module.dart';
import 'package:imobiliaria/app/presentation/main/pages/property_segments/property_segments_home_controller.dart';
import 'package:imobiliaria/app/presentation/main/pages/property_segments/widgets/brand/property_brand_cards_section.dart';
import 'package:imobiliaria/app/presentation/main/pages/property_segments/widgets/featured_properties/featured_properties_section.dart';
import 'package:imobiliaria/app/presentation/main/pages/property_segments/widgets/navigation/property_segments_top_navigation.dart';
import 'package:imobiliaria/app/presentation/main/pages/property_segments/widgets/search/property_search_panel.dart';
import 'package:imobiliaria/app/presentation/main/pages/property_segments/widgets/video/property_video_section.dart';
import 'package:legend_core/legend_core.dart';

class PropertySegmentsHomePage extends StatefulWidget {
  const PropertySegmentsHomePage({super.key});

  @override
  State<PropertySegmentsHomePage> createState() =>
      _PropertySegmentsHomePageState();
}

class _PropertySegmentsHomePageState
    extends
        StateController<
          MainModule,
          PropertySegmentsHomePage,
          PropertySegmentsHomeController
        > {
  final _contactKey = GlobalKey();
  final _aboutKey = GlobalKey();
  final _missionKey = GlobalKey();
  late final TextEditingController _queryController;
  late final TextEditingController _blockOrNeighborhoodController;

  @override
  void initState() {
    super.initState();
    final filters = controller.store.filters;
    _queryController = TextEditingController(text: filters.query);
    _blockOrNeighborhoodController = TextEditingController(
      text: filters.blockOrNeighborhood,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadHome();
    });
  }

  @override
  void dispose() {
    _queryController.dispose();
    _blockOrNeighborhoodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => controller.onWhatsappPressed(),
        tooltip: 'Contato rapido pelo WhatsApp',
        icon: const Icon(BootstrapIcons.whatsapp),
        label: const Text('Contato rapido'),
      ),
      body: ValueListenableBuilder<AppStateEnum>(
        valueListenable: controller.store.state,
        builder: (context, state, child) {
          final isLoading = state == AppStateEnum.isLoading;
          final errorMessage = state == AppStateEnum.hasError
              ? controller.store.consumeErrorMessage()
              : null;

          if (errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(errorMessage)));
            });
          }

          final brandContent = controller.store.brandContent;
          final featuredProperties = controller.store.featuredProperties;
          final filteredFeaturedProperties = _filterFeaturedPropertiesByPrice(
            featuredProperties,
            controller.store.filters,
          );

          return Stack(
            children: <Widget>[
              CustomScrollView(
                slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: PropertySegmentsTopNavigation(
                      onNewDevelopmentsPressed: () =>
                          controller.onNewDevelopmentsPressed(),
                      onContactPressed: () => _scrollTo(_contactKey),
                      onAboutPressed: () => _scrollTo(_aboutKey),
                      onMissionPressed: () => _scrollTo(_missionKey),
                      onWhatsappPressed: () => controller.onWhatsappPressed(),
                      onLoginPressed: () => controller.onLoginPressed(),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: DSPageLayoutContainer(
                      padding: const EdgeInsets.fromLTRB(
                        DSSpacing.md,
                        DSSpacing.xl,
                        DSSpacing.md,
                        DSSpacing.lg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(height: DSSpacing.lg),
                          PropertySearchPanel(
                            filters: controller.store.filters,
                            properties: featuredProperties,
                            queryController: _queryController,
                            blockOrNeighborhoodController:
                                _blockOrNeighborhoodController,
                            onFiltersChanged: controller.updateFilters,
                            onSegmentChanged: controller.updateSegment,
                            onSubmit: () => controller.onSearchSubmitted(),
                          ),
                          const SizedBox(height: DSSpacing.xl),
                          FeaturedPropertiesSection(
                            properties: filteredFeaturedProperties,
                            onMoreInfoPressed: (property) =>
                                controller.onPropertyWhatsappPressed(property),
                          ),
                          const SizedBox(height: DSSpacing.xl),
                          PropertyVideoSection(
                            content: brandContent,
                            onPressed: () => controller.onVideoPressed(),
                          ),
                          const SizedBox(height: DSSpacing.xl),
                          PropertyBrandCardsSection(
                            contactKey: _contactKey,
                            aboutKey: _aboutKey,
                            missionKey: _missionKey,
                            content: brandContent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (isLoading)
                Positioned.fill(
                  child: ColoredBox(
                    color: DSColors.surface.withValues(alpha: 0.55),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _scrollTo(GlobalKey key) {
    final targetContext = key.currentContext;
    if (targetContext == null) return;
    Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }
}

List<FeaturedPropertyEntity> _filterFeaturedPropertiesByPrice(
  List<FeaturedPropertyEntity> properties,
  PropertySearchFiltersEntity filters,
) {
  return properties.where((property) {
    final price = property.price;
    final min = filters.priceMin;
    final max = filters.priceMax;

    if (min != null && price < min) return false;
    if (max != null && price > max) return false;
    return true;
  }).toList();
}
