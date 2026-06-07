import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:imobiliaria/app/presentation/main/main_routes.dart';
import 'package:imobiliaria/app/presentation/main/pages/admin/admin_layout.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Painel administrativo',
      currentRoute: MainRoutes.admin,
      child: DSPageLayoutContainer(
        padding: const EdgeInsets.all(DSSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Painel administrativo',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: DSSpacing.sm),
            Text(
              'Bem-vindo a area administrativa da Seletta.',
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
                padding: const EdgeInsets.all(DSSpacing.lg),
                child: Text(
                  'Use o menu lateral para gerenciar corretores e acompanhar a operacao.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
