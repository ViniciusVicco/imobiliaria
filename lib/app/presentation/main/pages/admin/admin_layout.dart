import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:imobiliaria/app/presentation/main/main_module.dart';
import 'package:imobiliaria/app/presentation/main/main_routes.dart';
import 'package:legend_core/legend_core.dart';

class AdminLayout extends StatelessWidget {
  const AdminLayout({
    super.key,
    required this.title,
    required this.currentRoute,
    required this.child,
    this.notificationCount = 0,
  });

  final String title;
  final String currentRoute;
  final Widget child;
  final int notificationCount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 820;
          if (isWide) {
            return Row(
              children: <Widget>[
                SizedBox(
                  width: 260,
                  child: _AdminSidebar(
                    currentRoute: currentRoute,
                    notificationCount: notificationCount,
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: child),
              ],
            );
          }

          return Column(
            children: <Widget>[
              _AdminTopTabs(
                currentRoute: currentRoute,
                notificationCount: notificationCount,
              ),
              const Divider(height: 1),
              Expanded(child: child),
            ],
          );
        },
      ),
    );
  }
}

class _AdminSidebar extends StatelessWidget {
  const _AdminSidebar({
    required this.currentRoute,
    required this.notificationCount,
  });

  final String currentRoute;
  final int notificationCount;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: DSColors.surfaceContainer,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DSSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Admin',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: DSSpacing.lg),
              _AdminNavButton(
                label: 'Gerenciar corretores',
                icon: Icons.groups_outlined,
                route: MainRoutes.adminUsers,
                currentRoute: currentRoute,
              ),
              const SizedBox(height: DSSpacing.sm),
              _AdminNavButton(
                label: notificationCount > 0
                    ? 'Pendencias ($notificationCount)'
                    : 'Pendencias',
                icon: Icons.notifications_active_outlined,
                route: MainRoutes.adminReview,
                currentRoute: currentRoute,
              ),
              const SizedBox(height: DSSpacing.sm),
              _AdminNavButton(
                label: 'Gerenciar imoveis',
                icon: Icons.home_work_outlined,
                route: MainRoutes.adminProperties,
                currentRoute: currentRoute,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminTopTabs extends StatelessWidget {
  const _AdminTopTabs({
    required this.currentRoute,
    required this.notificationCount,
  });

  final String currentRoute;
  final int notificationCount;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(DSSpacing.sm),
      child: Row(
        children: <Widget>[
          _AdminNavButton(
            label: 'Gerenciar corretores',
            icon: Icons.groups_outlined,
            route: MainRoutes.adminUsers,
            currentRoute: currentRoute,
          ),
          const SizedBox(width: DSSpacing.sm),
          _AdminNavButton(
            label: notificationCount > 0
                ? 'Pendencias ($notificationCount)'
                : 'Pendencias',
            icon: Icons.notifications_active_outlined,
            route: MainRoutes.adminReview,
            currentRoute: currentRoute,
          ),
          _AdminNavButton(
            label: 'Gerenciar imoveis',
            icon: Icons.home_work_outlined,
            route: MainRoutes.adminProperties,
            currentRoute: currentRoute,
          ),
        ],
      ),
    );
  }
}

class _AdminNavButton extends StatelessWidget {
  const _AdminNavButton({
    required this.label,
    required this.icon,
    required this.route,
    required this.currentRoute,
  });

  final String label;
  final IconData icon;
  final String route;
  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    final isSelected = route == currentRoute;
    return FilledButton.tonalIcon(
      onPressed: isSelected
          ? null
          : () => Module.get<MainModule>().navigator.pushNamed(route),
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
