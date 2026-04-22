import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:imobiliaria/app/presentation/main/main_module.dart';
import 'package:imobiliaria/app/presentation/main/main_routes.dart';
import 'package:imobiliaria/app/presentation/main/pages/property_segments/property_segments_home_controller.dart';
import 'package:legend_core/legend_core.dart';

class PropertySegmentsHomePage
    extends StatelessController<MainModule, PropertySegmentsHomeController> {
  PropertySegmentsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final columns = context.isDesktopLayout ? 3 : 1;

    return Scaffold(
      appBar: AppBar(title: const Text('Property Showcase')),
      body: ValueListenableBuilder<AppStateEnum>(
        valueListenable: controller.store.state,
        builder: (context, state, _) {
          final isLoading = state == AppStateEnum.isLoading;

          final errorMessage =
              state == AppStateEnum.hasError ? controller.store.consumeErrorMessage() : null;

          if (errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(errorMessage)),
              );
            });
          }

          return Stack(
            children: <Widget>[
              DSPageLayoutContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Choose a segment',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: DSSpacing.md),
                    GridView.count(
                      crossAxisCount: columns,
                      mainAxisSpacing: DSSpacing.md,
                      crossAxisSpacing: DSSpacing.md,
                      shrinkWrap: true,
                      childAspectRatio: context.isDesktopLayout ? 3.2 : 2.8,
                      children: <Widget>[
                        _SegmentButton(
                          title: 'Commercial Spaces',
                          subtitle: 'Offices and business suites',
                          enabled: !isLoading,
                          onTap: () => controller.onSegmentPressed(
                            targetRoute: MainRoutes.commercial,
                          ),
                        ),
                        _SegmentButton(
                          title: 'Residential Homes',
                          subtitle: 'Houses, apartments and condos',
                          enabled: !isLoading,
                          onTap: () => controller.onSegmentPressed(
                            targetRoute: MainRoutes.residential,
                          ),
                        ),
                        _SegmentButton(
                          title: 'Investment Assets',
                          subtitle: 'Opportunities for portfolio growth',
                          enabled: !isLoading,
                          onTap: () => controller.onSegmentPressed(
                            targetRoute: MainRoutes.investments,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0x22000000),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.enabled,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: DSRadius.md,
      child: Opacity(
        opacity: enabled ? 1 : 0.55,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF3F3F3),
            borderRadius: DSRadius.md,
          ),
          padding: const EdgeInsets.all(DSSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: DSSpacing.xs),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
