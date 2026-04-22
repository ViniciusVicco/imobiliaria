import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:legend_core/legend_core.dart';

typedef RouteBuilder = Widget Function(BuildContext context, dynamic arguments);

class ModuleRouteData {
  final Object? extra;
  final String fullPath;
  final String path;
  final Map<String, String> pathParameters;
  final Map<String, String> queryParameters;

  const ModuleRouteData({
    required this.extra,
    required this.fullPath,
    required this.path,
    required this.pathParameters,
    required this.queryParameters,
  });
}

abstract class Module extends Object {
  Module() {
    _moduleNavigator = Navigator(
      key: navigatorKey,
      onGenerateRoute: onGenerateRoute,
      observers: const [],
    );
    navigator = AppNavigator(navigatorKey);
    privateDependencyManager = GetIt.asNewInstance();
  }

  late final Navigator _moduleNavigator;
  final navigatorKey = GlobalKey<NavigatorState>();
  RouteBuilder? Function(RouteSettings)? onRouteNotFound;

  void start() {
    if (_isStarted) {
      debugPrint('\n--- $runtimeType - Is already started ---\n');
    } else {
      injector.register();
      _isStarted = true;
      debugPrint('\n/// $runtimeType - Started ///\n');
      didStart();
    }
  }

  Future<void> dispose() async {
    await privateDependencyManager.reset();
    _isStarted = false;
    debugPrint('\n/// $runtimeType - Disposed ///\n');
    onDispose();
  }

  Future<void> didStart() async {}
  void onDispose() {}

  void stop() {
    _isStarted = false;
    _isStopped = true;
  }

  bool _isStarted = false;
  bool _isStopped = false;

  bool get isStarted => _isStarted;
  bool get isStopped => _isStopped;

  String get initialRoute;

  Map<String, RouteBuilder> get routes;

  ModuleInjector get injector;

  RouteBuilder? getRoute(String name) => routes[name];

  RouteBuilder? resolveRouteBuilder(String? routeName) {
    if (routeName == null || routeName.isEmpty) return null;
    final uri = Uri.tryParse(routeName) ?? Uri(path: routeName);
    final path = _normalizePath(uri.path);
    final resolved = _resolveRoute(path);
    return resolved.$1;
  }

  late final AppNavigator navigator;

  @visibleForTesting
  late final GetIt privateDependencyManager;

  static Module get<T extends Module>() =>
      GetIt.I.get<Module>(instanceName: T.toString());

  Widget widget(
    BuildContext context, {
    RouteBuilder? Function(RouteSettings)? onRouteNotFound,
  }) {
    this.onRouteNotFound = onRouteNotFound;
    if (!isStarted) start();
    return Builder(builder: (context) => _moduleNavigator);
  }

  Route<T?>? onGenerateRoute<T>(RouteSettings settings) {
    final routeName = settings.name ?? '/';
    final uri = Uri.tryParse(routeName) ?? Uri(path: routeName);
    final requestedPath = _normalizePath(uri.path);

    RouteBuilder? routeBuilder;
    Map<String, String> pathParameters = const {};

    if (requestedPath == '/') {
      final resolved = _resolveRoute(initialRoute);
      routeBuilder = resolved.$1;
      pathParameters = resolved.$2;
    } else {
      final resolved = _resolveRoute(requestedPath);
      routeBuilder = resolved.$1;
      pathParameters = resolved.$2;

      if (routeBuilder == null && onRouteNotFound != null) {
        routeBuilder = onRouteNotFound!(settings);
      }
    }

    routeBuilder ??= getFallBackRoute(settings);

    final routeArguments = _composeRouteArguments(
      settings.arguments,
      routeName,
      requestedPath,
      pathParameters,
      uri.queryParameters,
    );

    return createRoute<T>(
      settings: settings,
      builder: (_) => Builder(
        builder: (context) => routeBuilder!(context, routeArguments),
      ),
    );
  }

  @protected
  Route<T?> createRoute<T>({
    required RouteSettings settings,
    required WidgetBuilder builder,
  }) {
    return MaterialPageRoute<T>(settings: settings, builder: builder);
  }

  RouteBuilder getFallBackRoute(RouteSettings settings) {
    return (context, _) => Scaffold(
      appBar: AppBar(title: const Text('Route not found ')),
      body: Center(
        child: SizedBox(
          width: 300,
          child: Text(
            'The route \'${settings.name}\' was not found in the module $runtimeType.\nDid your forget to register it in your module ?\nAre you using the correct [Module] to navigate?',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  (RouteBuilder?, Map<String, String>) _resolveRoute(String routePath) {
    final directMatch = getRoute(routePath);
    if (directMatch != null) {
      return (directMatch, const {});
    }

    for (final entry in routes.entries) {
      final pattern = entry.key;
      if (!_isPathPattern(pattern)) continue;
      final pathParameters = _extractPathParameters(pattern, routePath);
      if (pathParameters != null) {
        return (entry.value, pathParameters);
      }
    }

    return (null, const {});
  }

  String _normalizePath(String path) {
    if (path.isEmpty) return '/';
    if (path == '/') return path;
    if (path.endsWith('/')) return path.substring(0, path.length - 1);
    return path;
  }

  bool _isPathPattern(String path) => path.contains(':');

  Map<String, String>? _extractPathParameters(String pattern, String path) {
    final patternPath = _normalizePath(pattern);
    final targetPath = _normalizePath(path);

    final patternSegments =
        patternPath.split('/').where((segment) => segment.isNotEmpty).toList();
    final pathSegments =
        targetPath.split('/').where((segment) => segment.isNotEmpty).toList();

    if (patternSegments.length != pathSegments.length) return null;

    final pathParameters = <String, String>{};
    for (var index = 0; index < patternSegments.length; index++) {
      final patternSegment = patternSegments[index];
      final pathSegment = pathSegments[index];

      if (patternSegment.startsWith(':')) {
        final key = patternSegment.substring(1);
        if (key.isEmpty) return null;
        pathParameters[key] = pathSegment;
        continue;
      }

      if (patternSegment != pathSegment) return null;
    }

    return pathParameters;
  }

  Object? _composeRouteArguments(
    Object? routeArguments,
    String fullPath,
    String path,
    Map<String, String> pathParameters,
    Map<String, String> queryParameters,
  ) {
    if (pathParameters.isEmpty && queryParameters.isEmpty) return routeArguments;

    return ModuleRouteData(
      extra: routeArguments,
      fullPath: fullPath,
      path: path,
      pathParameters: Map.unmodifiable(pathParameters),
      queryParameters: Map.unmodifiable(queryParameters),
    );
  }
}
