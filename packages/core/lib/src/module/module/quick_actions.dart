import 'package:legend_core/src/module/module/module.dart';
import 'package:legend_core/src/module/module/module_injector.dart';

mixin QuickActionsMixin<M extends Module, T extends QuickActions<M>> {
  T get actions;
}

abstract class QuickActions<M extends Module> {
  ModuleInjector get injector => Module.get<M>().injector;
}


