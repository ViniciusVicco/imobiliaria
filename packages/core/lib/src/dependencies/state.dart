import 'package:legend_core/src/dependencies/controller.dart';
import 'package:legend_core/src/dependencies/store.dart';
import 'package:legend_core/src/module/module/module.dart';
import 'package:flutter/material.dart';

abstract class StatelessController<M extends Module, C extends Controller>
    extends StatelessWidget {
  StatelessController({super.key}) {
    controller = Module.get<M>().injector.get<C>();
  }

  late final C controller;
}

abstract class StateController<
  M extends Module,
  T extends StatefulWidget,
  C extends Controller
>
    extends State<T> {
  StateController() {
    controller = Module.get<M>().injector.get<C>();
  }

  late final C controller;
}

abstract class StateStore<
  M extends Module,
  T extends StatefulWidget,
  S extends Store
>
    extends State<T> {
  StateStore() {
    store = Module.get<M>().injector.get<S>();
  }

  late final S store;
}

abstract class StatePage<
  M extends Module,
  T extends StatefulWidget,
  C extends Controller,
  S extends Store
>
    extends State<T> {
  StatePage() {
    controller = Module.get<M>().injector.get<C>();
    store = Module.get<M>().injector.get<S>();
  }

  final enteredAt = DateTime.now();
  bool logScreenTime = true;

  @override
  void initState() {
    super.initState();
    //TODO: Track all screens
  }

  @override
  void dispose() {
    super.dispose();
  }

  late final C controller;
  late final S store;
}


