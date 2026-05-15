import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

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
              'Placeholder protegido para os proximos fluxos de imoveis.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: DSColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
