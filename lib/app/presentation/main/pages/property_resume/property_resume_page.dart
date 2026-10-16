import 'widgets/property_detail_error.dart';
import 'package:flutter/material.dart';
import 'package:legend_core/legend_core.dart';
import '../../main_module.dart';
import '../../main_routes.dart';
import '../property_segments/widgets/navigation/property_segments_top_navigation.dart';
import 'property_resume_controller.dart';
import 'property_resume_actions.dart';
import 'widgets/property_detail_content.dart';

class PropertyResumePage extends StatefulWidget {
  const PropertyResumePage({super.key, this.routeData});
  final ModuleRouteData? routeData;
  @override
  State<PropertyResumePage> createState() => _PropertyResumePageState();
}

class _PropertyResumePageState
    extends
        StateController<
          MainModule,
          PropertyResumePage,
          PropertyResumeController
        > {
  String get _id => widget.routeData?.pathParameters['id'] ?? '';
  void _navigate(String path) =>
      Module.get<MainModule>().navigator.pushNamed(path);
  @override
  void initState() {
    super.initState();
    controller.load(_id);
  }

  @override
  void dispose() {
    controller.dispose();
    controller.store.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PropertyResumePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.routeData?.pathParameters['id'] != _id) controller.load(_id);
  }

  void _message(String? message) {
    if (mounted && message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _contact(bool visit) async {
    final property = controller.store.property;
    if (property == null) return;
    _message(
      await openPropertyWhatsapp(
        property.whatsapp,
        property.title,
        visit: visit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xff030e22),
    body: SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            PropertySegmentsTopNavigation(
              onStockPressed: () => _navigate(MainRoutes.stock),
              onNewDevelopmentsPressed: () =>
                  _navigate('/estoque?city=Palmas&tag=na-planta'),
              onContactPressed: () => _contact(false),
              onAboutPressed: () => _navigate(MainRoutes.home),
              onMissionPressed: () => _navigate(MainRoutes.home),
              onWhatsappPressed: () => _contact(false),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1440),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          final navigator = Module.get<MainModule>()
                              .navigator;
                          if (navigator.canPop()) {
                            navigator.pop();
                          } else {
                            _navigate(MainRoutes.stock);
                          }
                        },
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Voltar aos imóveis'),
                      ),
                      const SizedBox(height: 16),
                      ValueListenableBuilder<AppStateEnum>(
                        valueListenable: controller.store.state,
                        builder: (context, state, _) {
                          if (state == AppStateEnum.isLoading) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(64),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          if (state == AppStateEnum.hasError) {
                            return PropertyDetailError(
                              message: controller.store.error!,
                              unavailable: controller.store.unavailable,
                              onRetry: () => controller.load(_id),
                              onStock: () => _navigate(MainRoutes.stock),
                            );
                          }
                          final property = controller.store.property;
                          if (property == null) return const SizedBox.shrink();
                          return PropertyDetailContent(
                            property: property,
                            desktop: MediaQuery.sizeOf(context).width >= 1024,
                            onVisit: () => _contact(true),
                            onContact: () => _contact(false),
                            onShare: (origin) async => _message(
                              await shareProperty(
                                MainRoutes.propertyPath(_id),
                                origin,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
