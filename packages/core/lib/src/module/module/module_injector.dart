import 'dart:async';

import 'package:flutter/material.dart';
import 'package:legend_core/legend_core.dart';

import 'module.dart';

abstract class ModuleInjector<M extends Module> {
  final _injectionsDispose = <void Function()>[];
  // ignore: invalid_use_of_visible_for_testing_member
  final _getit = Module.get<M>().privateDependencyManager;

  void core();
  void datasources();
  void repositories();
  void usecases();
  void stores();
  void controllers();

  void register() {
    stores();
    core();
    datasources();
    repositories();
    usecases();
    controllers();
  }

  void registerFactory<T extends Object>(
    T Function() factoryFunc, {
    String? instanceName,
  }) {
    if (isRegistered<T>(instanceName: instanceName)) return;
    _getit.registerFactory<T>(factoryFunc, instanceName: instanceName);
    _injectionsDispose.add(
      () => _unregisterInjectable<T>(instanceName: instanceName),
    );
  }

  void registerSingleton<T extends Object>(T instance, {String? instanceName}) {
    if (isRegistered<T>(instanceName: instanceName)) return;
    _getit.registerSingleton<T>(instance, instanceName: instanceName);
    _injectionsDispose.add(
      () => _unregisterInjectable<T>(instanceName: instanceName),
    );
  }

  void registerLazySingleton<T extends Object>(
    T Function() factoryFunc, {
    String? instanceName,
  }) {
    if (isRegistered<T>(instanceName: instanceName)) return;
    _getit.registerLazySingleton<T>(factoryFunc, instanceName: instanceName);
    _injectionsDispose.add(
      () => _unregisterInjectable<T>(instanceName: instanceName),
    );
  }

  FutureOr<dynamic> _unregisterInjectable<T extends Object>({
    String? instanceName,
  }) {
    return _getit.unregister<T>(instanceName: instanceName);
  }

  bool isRegistered<T extends Object>({String? instanceName}) {
    return _getit.isRegistered<T>(instanceName: instanceName);
  }

  int get internalInjectorHashCode => _getit.hashCode;

  T get<T extends Object>([String? instanceName]) {
    try {
      if (!Module.get<M>().isStarted) Module.get<M>().start();
      if (isRegistered<T>(instanceName: instanceName)) {
        return _getit.get<T>(instanceName: instanceName);
      }
      throw Exception();
    } catch (e) {
      final logMessage =
          '$T is not registered in $runtimeType.\nDid you forget to register it?\nDid you register it in a [ModuleInjector] of other [Module] than $M?';
      debugPrint(logMessage);
      throw Exception(logMessage);
    }
  }

  void test() {
    final storesToRecycle = [];
    for (var instance in _injectionsDispose) {
      if (instance is Store) {
        storesToRecycle.add(instance);
      }
      //Reinstanciar
      // ignore: unused_local_variable
      for (var element in storesToRecycle) {}
      //Remover sobrescrever o que tem no vetor
    }
  }
}
