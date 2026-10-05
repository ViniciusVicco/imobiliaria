import 'package:flutter/material.dart';
import 'package:legend_core/legend_core.dart';

/// Connects the existing module routes to browser URLs and platform back events.
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key, required this.module});
  final Module module;
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with WidgetsBindingObserver {
  late final String _initialRoute =
      WidgetsBinding.instance.platformDispatcher.defaultRouteName;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<bool> didPopRoute() async {
    final nav = widget.module.navigator;
    if (!nav.canPop()) return false;
    nav.pop();
    return true;
  }

  @override
  Future<bool> didPushRouteInformation(
    RouteInformation routeInformation,
  ) async {
    widget.module.navigator.pushReplacementNamed(
      routeInformation.uri.toString(),
    );
    return true;
  }

  @override
  Widget build(BuildContext context) => Navigator(
    key: widget.module.navigatorKey,
    initialRoute: _initialRoute,
    reportsRouteUpdateToEngine: true,
    onGenerateInitialRoutes: (_, route) => [
      widget.module.onGenerateRoute(RouteSettings(name: route))!,
    ],
    onGenerateRoute: widget.module.onGenerateRoute,
  );
}
