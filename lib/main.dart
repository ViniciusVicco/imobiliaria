import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:imobiliaria/app/presentation/main/main_module.dart';
import 'package:legend_core/legend_core.dart';

void main() {
  runApp(
    ModuleApp(
      mainModuleBuilder: MainModule.new,
      childModuleBuilders: const <Module Function()>[],
      app: (home) => MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: DSResponsiveAppBuilder.build,
        home: home,
      ),
    ),
  );
}
