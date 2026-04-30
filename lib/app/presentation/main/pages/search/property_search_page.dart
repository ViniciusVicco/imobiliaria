import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:legend_core/legend_core.dart';

class PropertySearchPage extends StatelessWidget {
  const PropertySearchPage({super.key, this.routeData});

  final ModuleRouteData? routeData;

  @override
  Widget build(BuildContext context) {
    final queryParameters =
        routeData?.queryParameters ?? const <String, String>{};
    final entries = queryParameters.entries.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Busca de imoveis')),
      body: DSPageLayoutContainer(
        padding: const EdgeInsets.all(DSSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Resultados da busca',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: DSSpacing.sm),
            Text(
              'Esta pagina ja recebe os filtros da Home. O grid otimizado entra na proxima evolucao da busca.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: DSColors.onSurfaceVariant),
            ),
            const SizedBox(height: DSSpacing.lg),
            DecoratedBox(
              decoration: BoxDecoration(
                color: DSColors.surfaceContainer,
                borderRadius: DSRadius.md,
                border: Border.all(color: DSColors.outline),
              ),
              child: Padding(
                padding: const EdgeInsets.all(DSSpacing.md),
                child: entries.isEmpty
                    ? const Text('Nenhum filtro informado.')
                    : Wrap(
                        spacing: DSSpacing.sm,
                        runSpacing: DSSpacing.sm,
                        children: entries
                            .map(
                              (entry) => Chip(
                                label: Text('${entry.key}: ${entry.value}'),
                              ),
                            )
                            .toList(),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
