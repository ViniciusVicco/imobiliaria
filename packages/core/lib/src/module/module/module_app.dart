import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'module.dart';

class ModuleApp extends StatefulWidget {
  const ModuleApp({
    super.key,
    required this.mainModuleBuilder,
    required this.childModuleBuilders,
    required this.app,
  });

  final Module Function() mainModuleBuilder;
  final List<Module Function()> childModuleBuilders;
  final Widget Function(Widget home) app;

  static ModuleAppState? of(BuildContext context) {
    return context.findAncestorStateOfType();
  }

  @override
  State<ModuleApp> createState() => ModuleAppState();
}

class ModuleAppState extends State<ModuleApp> {
  final List<String> _registeredModuleKeys = <String>[];
  late Module _mainModule;
  late List<Module> _childModules;
  late Widget _mainModuleWidget;

  @override
  void initState() {
    _initModules();
    super.initState();
  }

  void _initModules() {
    _mainModule = widget.mainModuleBuilder();
    _childModules = widget.childModuleBuilders
        .map((builder) => builder())
        .toList();

    _registerModule(_mainModule);

    for (final module in _childModules) {
      _registerModule(module);
    }

    _mainModule.start();
    _mainModuleWidget = _mainModule.widget(
      context,
      onRouteNotFound: searchRouteInOtherModules,
    );
  }

  void _registerModule(Module module) {
    final moduleKey = module.runtimeType.toString();
    if (GetIt.I.isRegistered<Module>(instanceName: moduleKey)) {
      GetIt.I.unregister<Module>(instanceName: moduleKey);
    }
    GetIt.I.registerSingleton<Module>(module, instanceName: moduleKey);
    _registeredModuleKeys.add(moduleKey);
  }

  Future<void> _disposeModules() async {
    for (final module in _childModules.reversed) {
      await module.dispose();
    }
    await _mainModule.dispose();
  }

  Future<void> _unregisterModulesFromGlobal() async {
    for (final moduleKey in _registeredModuleKeys.reversed) {
      if (GetIt.I.isRegistered<Module>(instanceName: moduleKey)) {
        await GetIt.I.unregister<Module>(instanceName: moduleKey);
      }
    }
    _registeredModuleKeys.clear();
  }

  Future<void> wipeModulesAndRestartRoutes() async {
    if (!mounted) return;
    setState(() {
      _mainModuleWidget = const ColoredBox(
        color: Colors.white,
        child: Center(child: CircularProgressIndicator()),
      );
    });

    await _disposeModules();
    await _unregisterModulesFromGlobal();

    _initModules();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> disposeChildModules() => wipeModulesAndRestartRoutes();

  @override
  Widget build(BuildContext context) {
    return widget.app(_mainModuleWidget);
  }

  RouteBuilder? searchRouteInOtherModules(RouteSettings settings) {
    final routeName = settings.name;
    if (routeName == null) return null;

    RouteBuilder? routeBuilder;

    int index = 0;
    while (routeBuilder == null && index < _childModules.length) {
      routeBuilder = _childModules.elementAt(index).getRoute(routeName);
      if (routeBuilder != null) {
        _childModules.elementAt(index).start();
      }
      index++;
    }

    return routeBuilder;
  }

  @override
  void dispose() {
    _disposeModules();
    _unregisterModulesFromGlobal();
    super.dispose();
  }
}

