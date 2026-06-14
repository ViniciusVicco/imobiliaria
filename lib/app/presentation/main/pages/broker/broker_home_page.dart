import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:imobiliaria/app/presentation/main/main_module.dart';
import 'package:imobiliaria/app/presentation/main/main_routes.dart';
import 'package:legend_core/legend_core.dart';

class BrokerHomePage extends StatelessWidget {
  const BrokerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Corretor')),
      body: DSPageLayoutContainer(
        padding: const EdgeInsets.all(DSSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Area do corretor',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: DSSpacing.sm),
            Text(
              'Gerencie seus anuncios, vendas e imoveis removidos.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: DSColors.onSurfaceVariant),
            ),
            const SizedBox(height: DSSpacing.lg),
            FilledButton.icon(
              onPressed: () => Module.get<MainModule>().navigator.pushNamed(
                MainRoutes.brokerProperties,
              ),
              icon: const Icon(Icons.home_work_outlined),
              label: const Text('Meus imoveis'),
            ),
          ],
        ),
      ),
    );
  }
}
