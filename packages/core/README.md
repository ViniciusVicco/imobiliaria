# legend_core

Arquitetura modular Flutter para:

- Injecao de dependencias por modulo (GetIt por instancia)
- Gerenciamento de ciclo de vida de modulos
- Roteamento entre modulos
- Estruturas base para `Controller`, `Store` e `State`

## Uso rapido

```yaml
dependencies:
  legend_core:
    path: packages/legend_core
```

```dart
import 'package:legend_core/legend_core.dart';
```

```dart
class MainModule extends Module {
  @override
  String get initialRoute => '/home';

  @override
  ModuleInjector<MainModule> get injector => MainInjector();

  @override
  Map<String, RouteBuilder> get routes => {
    '/home': (context, args) => const Placeholder(),
  };
}
```

