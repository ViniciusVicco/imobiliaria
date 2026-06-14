import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:imobiliaria/app/presentation/authentication/authentication_module.dart';
import 'package:imobiliaria/app/presentation/main/main_module.dart';
import 'package:legend_core/legend_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ModuleApp(
      mainModuleBuilder: MainModule.new,
      childModuleBuilders: <Module Function()>[AuthenticationModule.new],
      app: (home) => MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: DSResponsiveAppBuilder.build,
        theme: DSTheme.dark,
        home: home,
      ),
    ),
  );
}
