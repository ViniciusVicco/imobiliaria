import 'package:flutter/cupertino.dart';

class AppNavigator extends ValueNotifier {
  ValueNotifier<List<String>> activeRoutes = ValueNotifier([]);
  final GlobalKey<NavigatorState> navigatorKey;

  AppNavigator(this.navigatorKey) : super(0);

  Future<T?> pushNamed<T extends Object?>(String routeName,
      {Object? arguments}) {
    addRoute(routeName);
    return navigatorKey.currentState!
        .pushNamed<T>(routeName, arguments: arguments);
  }

  void pop<T extends Object?>([T? result]) {
    removeRoute();
    navigatorKey.currentState!.pop<T>(result);
  }

  bool canPop() {
    return navigatorKey.currentState!.canPop();
  }

  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
      String routeName,
      {TO? result,
      Object? arguments}) {
    removeRoute();
    addRoute(routeName);
    return navigatorKey.currentState!
        .pushReplacementNamed(routeName, arguments: arguments);
  }

  Future<T?> popAndPushNamed<T extends Object?, TO extends Object?>(
      String routeName,
      {TO? result,
      Object? arguments}) {
    if (navigatorKey.currentState != null) {
      removeRoute();
      return navigatorKey.currentState!
          .popAndPushNamed(routeName, arguments: arguments);
    } else {
      throw Exception("O navigator estÃ¡ nulo");
    }
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
    } else {
      throw Exception("O navigator estÃ¡ nulo");
    }
  }

  void popUntil(String newRoute) {
    if (navigatorKey.currentState != null) {
      return navigatorKey.currentState?.popUntil(
        (route) {
          if (route.settings.name == newRoute) {
            removeRoute();
            return true;
          } else {
            return false;
          }
        },
      );
    } else {
      throw Exception("Navigator Key can't be null, core error");
    }
  }

  void removeRoute() {
    if (activeRoutes.value.isNotEmpty) {
      activeRoutes.value.removeLast();
      activeRoutes.notifyListeners();
    }
  }

  void addRoute(String routeName) {
    activeRoutes.value.add(routeName);
    activeRoutes.notifyListeners();
  }
}

