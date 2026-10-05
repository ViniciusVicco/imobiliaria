import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:legend_core/legend_core.dart';
import 'package:imobiliaria/app/presentation/main/main_navigation.dart';
import 'package:imobiliaria/app/presentation/main/main_routes.dart';

class _Routes extends Module {
  @override
  String get initialRoute => '/home';
  @override
  ModuleInjector get injector => throw UnimplementedError();
  @override
  Map<String, RouteBuilder> get routes => {
    '/home': (_, _) => const Scaffold(body: Text('home')),
    '/estoque': (_, _) => const Scaffold(body: Text('estoque')),
    MainRoutes.propertyResume: (_, args) => Scaffold(
      body: Text('property:${(args as ModuleRouteData).pathParameters['id']}'),
    ),
  };
}

void main() {
  testWidgets(
    'direct link loads exact ID; navigation and platform route changes work',
    (tester) async {
      tester.binding.platformDispatcher.defaultRouteNameTestValue =
          '/imovel/direct-id';
      addTearDown(
        tester.binding.platformDispatcher.clearDefaultRouteNameTestValue,
      );
      final module = _Routes();
      await tester.pumpWidget(
        MaterialApp(builder: (_, _) => MainNavigation(module: module)),
      );
      await tester.pumpAndSettle();
      expect(find.text('property:direct-id'), findsOneWidget);
      module.navigator.pushNamed('/estoque');
      await tester.pumpAndSettle();
      module.navigator.pushNamed(MainRoutes.propertyPath('clicked-id'));
      await tester.pumpAndSettle();
      expect(find.text('property:clicked-id'), findsOneWidget);
      module.navigator.pop();
      await tester.pumpAndSettle();
      expect(find.text('estoque'), findsOneWidget);
      final data = const JSONMethodCodec().encodeMethodCall(
        const MethodCall('pushRouteInformation', {
          'location': '/imovel/history-id',
          'state': null,
        }),
      );
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/navigation',
        data,
        (_) {},
      );
      await tester.pumpAndSettle();
      expect(find.text('property:history-id'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
