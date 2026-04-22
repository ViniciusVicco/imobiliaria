# Arquitetura e Entrega Incremental (Spec-Driven Development)

## 1) Objetivo do produto
Plataforma web responsiva (desktop e mobile web) para vitrine de imoveis com 3 frentes:

- Comprar
- Alugar
- Anunciar

Escopo de negocio: imoveis de diferentes tipos (terrenos, apartamentos, casas e alto padrao).

## 2) Pilares obrigatorios
1. Responsividade real: mesma base de codigo com comportamento consistente em celular e desktop.
2. Fluxo arquitetural obrigatorio: `widget -> controller -> useCase -> repository -> datasource`.

Regra de ouro:
- Widget nunca chama API direto.
- `try/catch`, mapeamento de erro e tratamento ficam em `repository`.

## 3) Decisoes arquiteturais concluidas
- O app usa `ModuleApp` + `MainModule` como shell principal de navegacao.
- O design/layout responsivo foi centralizado no `packages/design_system`.
- O core modular (`packages/core`) continua como base de DI, modulo e ciclo de vida.
- O fluxo de dominio foi padronizado em `data/domain/presentation` dentro de `lib/app`.
- Rotas principais em ingles, alinhadas com URL web.

## 4) Padrao oficial de pastas
### 4.1) Packages
- `packages/core`: fundacao arquitetural (Module, ModuleInjector, AppNavigator, contracts).
- `packages/design_system`: layout responsivo, breakpoints, tokens de UI e componentes de layout.

### 4.2) App (`lib/app`)
- `data/`
- `domain/`
- `presentation/`

Detalhamento:
- `lib/app/data/<feature>/datasources/`
- `lib/app/data/<feature>/repositories/`
- `lib/app/data/<feature>/models/`
- `lib/app/data/<feature>/failures/`
- `lib/app/domain/<feature>/entities/`
- `lib/app/domain/<feature>/usecases/`
- `lib/app/presentation/<module>/pages/`
- `lib/app/presentation/<module>/<module>_module.dart`
- `lib/app/presentation/<module>/<module>_injector.dart`
- `lib/app/presentation/<module>/<module>_routes.dart`

## 5) Contratos por camada
### Widget/Page
- Renderiza estado.
- Dispara acao para `controller`.
- Nao conhece `dio/http`.

### Controller
- Coordena interacao de tela.
- Chama `usecase`.
- Atualiza `store` com loading/sucesso/erro.
- Pode disparar navegacao via `AppNavigator` injetado.

### UseCase
- Encapsula regra de negocio da acao.
- Chama apenas `repository`.

### Repository
- Ponto unico de tratamento tecnico:
  - `try/catch`
  - mapeamento de excecoes
  - transformacao para `Failure`/`DualResponse`
- Nao renderiza UI.

### DataSource
- Apenas acesso externo (REST, cache, storage).
- Sem regra de negocio de tela.

## 6) Roteamento web e modulos (estado atual)
- Rotas principais do modulo: `/home`, `/commercial`, `/residential`, `/investments`.
- Home renderiza grid com 3 botoes e navega pelos 3 segmentos.
- Navegacao segue fluxo de negocio (botao -> controller -> usecase -> repository -> datasource -> route).

Regra para novos modulos:
- Declarar rotas em `<module>_routes.dart`.
- Declarar mapa de rotas em `<module>_module.dart`.
- Nunca navegar direto de widget para datasource/API.

## 7) Injeção e ciclo de vida (GetIt)
Regra critica confirmada:
- Nao instanciar injector em campo `final` com acesso precoce a `Module.get<T>()`.
- O injector deve ser resolvido sob demanda no getter `injector` do modulo.

Exemplo correto:
```dart
@override
ModuleInjector<MainModule> get injector => MainInjector();
```

Motivo:
- Evita erro de modulo ainda nao registrado no `GetIt` global durante bootstrap.

## 8) Responsividade (design_system)
Padrao de uso:
- `MaterialApp(builder: DSResponsiveAppBuilder.build, ...)`
- `DSPageLayoutContainer` para largura maxima e padding consistente.
- `context.isDesktopLayout`/`context.isMobileLayout` para decisao de grid/coluna.
- Tokens de espacamento e radius via `DSSpacing` e `DSRadius`.

## 9) Dependencias por responsabilidade
### 9.1) App principal
- `legend_core`
- `design_system`
- Dependencias nao visuais e de app (`go_router`, `flutter_bloc`, `equatable`, `intl`, `url_launcher`, `shared_preferences`, etc.).

### 9.2) Design system
- Dependencias de layout/design: `responsive_framework`, `flutter_svg`, `cached_network_image`, `cupertino_icons`.

## 10) Backlog spec-driven (proximas fases)
- Spec 1: Home vitrine com dados reais e filtros iniciais.
- Spec 2: Fluxo Comprar.
- Spec 3: Fluxo Alugar.
- Spec 4: Fluxo Anunciar.
- Spec 5: Observabilidade, performance web e testes.

## 11) Template de spec
```md
# Spec X.Y - <titulo>

## Contexto
<problema de negocio e objetivo>

## Escopo
- Em escopo:
- Fora de escopo:

## Contratos de arquitetura
- Widget chama apenas Controller? [ ]
- Controller chama apenas UseCase? [ ]
- UseCase chama apenas Repository? [ ]
- Repository concentra try/catch e Failure? [ ]

## Requisitos funcionais
1. ...
2. ...

## Requisitos nao funcionais
1. Responsividade mobile/desktop
2. Acessibilidade minima
3. Performance alvo

## Criterios de aceite (Given/When/Then)
1. Dado ... Quando ... Entao ...

## Plano tecnico
- Camadas afetadas:
- Rotas afetadas:
- Riscos:

## Testes obrigatorios
- Unitario:
- Widget:
- Integracao:
```

## 12) Definition of Done por spec
- Fluxo arquitetural respeitado (`widget -> controller -> useCase -> repository -> datasource`).
- Nenhum acesso HTTP direto em widget/controller.
- Funciona em viewport mobile e desktop.
- Rotas web funcionando com URL amigavel.
- Erros mapeados em `Failure`.
- Criterios de aceite cobertos por testes.
