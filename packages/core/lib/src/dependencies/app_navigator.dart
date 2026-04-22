import 'package:flutter/cupertino.dart';

class AppNavigator extends ValueNotifier<int> {
  final ValueNotifier<List<String>> activeRoutes = ValueNotifier<List<String>>([]);
  final GlobalKey<NavigatorState> navigatorKey;

  AppNavigator(this.navigatorKey) : super(0);

  Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    addRoute(routeName);
    return navigatorKey.currentState!.pushNamed<T>(routeName, arguments: arguments);
  }

  void pop<T extends Object?>([T? result]) {
    removeRoute();
    navigatorKey.currentState!.pop<T>(result);
  }

  bool canPop() {
    return navigatorKey.currentState!.canPop();
  }

  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) {
    removeRoute();
    addRoute(routeName);
    return navigatorKey.currentState!.pushReplacementNamed(routeName, arguments: arguments);
  }

  Future<T?> popAndPushNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) {
    if (navigatorKey.currentState != null) {
      removeRoute();
      return navigatorKey.currentState!.popAndPushNamed(routeName, arguments: arguments);
    }

    throw Exception('O navigator esta nulo');
  }

  Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String newRouteName,
    RoutePredicate predicate, {
    Object? arguments,
  }) {
    if (navigatorKey.currentState != null) {
      return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(
        newRouteName,
        predicate,
        arguments: arguments,
      );
    }

    throw Exception('O navigator esta nulo');
  }

  void popUntil(String newRoute) {
    if (navigatorKey.currentState != null) {
      return navigatorKey.currentState?.popUntil((route) {
        if (route.settings.name == newRoute) {
          removeRoute();
          return true;
        }
        return false;
      });
    }

    throw Exception("Navigator Key can't be null, core error");
  }

  void removeRoute() {
    if (activeRoutes.value.isEmpty) return;
    final updatedRoutes = List<String>.from(activeRoutes.value)..removeLast();
    activeRoutes.value = updatedRoutes;
    notifyListeners();
  }

  void addRoute(String routeName) {
    final updatedRoutes = List<String>.from(activeRoutes.value)..add(routeName);
    activeRoutes.value = updatedRoutes;
    notifyListeners();
  }
}
