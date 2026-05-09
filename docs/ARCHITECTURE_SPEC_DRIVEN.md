# Arquitetura e Entrega Incremental (Spec-Driven Development)

## 1) Objetivo do produto
Plataforma responsiva para vitrine de imoveis, com quatro entradas iniciais:

- Residencial
- Comercial
- Investimentos
- Anunciar imovel

Escopo de negocio: imoveis de diferentes tipos, como apartamentos, casas, salas comerciais, lojas e oportunidades de investimento.

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
- Rotas principais em ingles, alinhadas com a estrategia web do modulo.

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
- Apenas acesso externo, cache, storage ou adaptacao de payload.
- Sem regra de negocio de tela.

## 6) Roteamento e modulos (estado atual)
- Rotas principais do modulo: `/home`, `/commercial`, `/residential`, `/investments`, `/announce-property`.
- Home renderiza grid com 4 cards de entrada e navega pelos segmentos.
- Navegacao segue fluxo de negocio: botao -> controller -> usecase -> repository -> datasource -> rota.
- A pagina de detalhe de segmento ainda e placeholder, ate as specs de catalogo e anuncio evoluirem.

Regra para novos modulos:
- Declarar rotas em `<module>_routes.dart`.
- Declarar mapa de rotas em `<module>_module.dart`.
- Nunca navegar direto de widget para datasource/API.

## 7) Injecao e ciclo de vida (GetIt)
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
- `context.isDesktopLayout`/`context.isMobileLayout` estao disponiveis para decisao de grid/coluna.
- Tokens de espacamento e radius via `DSSpacing` e `DSRadius`.

## 9) Organizacao de widgets e componentes
Regra de decisao:
- Alta repeticao, pouca logica e nenhuma dependencia de dominio: mover para `packages/design_system`.
- Logica de tela, entidades da feature, copy de negocio ou callbacks do controller: manter em `lib/app/presentation/<module>/pages/<feature>/widgets/`.
- Logica pura de transformacao/filtro fica como helper local da feature; se virar regra de negocio compartilhada, mover para domain/usecase.

### 9.1) Design system
- Nao depende de entities, controllers, usecases, rotas, injectors ou assets do app.
- Recebe dados por parametros primitivos, callbacks e widgets filhos.
- Pode conter infraestrutura visual reutilizavel, como cards base, grids responsivos, wrappers de media/embed e componentes de layout.
- Componentes publicos devem usar prefixo `DS` e ser exportados por `packages/design_system/lib/design_system.dart`.

### 9.2) Widgets de feature
- Podem conhecer entities, textos de negocio e decisoes especificas da tela.
- Devem ser agrupados por contexto de uso, por exemplo `widgets/search`, `widgets/video`, `widgets/navigation` e `widgets/featured_properties`.
- A page principal deve ficar como orquestradora: le estado, chama controller e compoe secoes.
- Widgets continuam respeitando o fluxo `widget -> controller -> useCase -> repository -> datasource`.

## 10) Dependencias por responsabilidade
### 10.1) App principal
- `legend_core`
- `design_system`
- Dependencias de produto devem ficar no app apenas quando houver uso real na feature.

### 10.2) Design system
- Dependencias de layout/design: `responsive_framework`, `flutter_svg`, `cached_network_image`, `cupertino_icons`.
- Dependencias de media/embed so entram aqui quando forem wrappers visuais reutilizaveis e nao carregarem regra de negocio do app.

### 10.3) Core
- Dependencias estruturais do core ficam em `packages/core`, como `dio` para requests cancelaveis e `logger` para mixins de log.

## 11) Backlog spec-driven (proximas fases)
- Spec 1: Home showcase com dados reais e filtros iniciais.
- Spec 2: Catalogo residencial.
- Spec 3: Catalogo comercial.
- Spec 4: Investimentos na planta.
- Spec 5: Fluxo Anunciar imovel.
- Spec 6: Observabilidade, performance web e testes.

## 12) Template de spec
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

## 13) Definition of Done por spec
- Fluxo arquitetural respeitado (`widget -> controller -> useCase -> repository -> datasource`).
- Nenhum acesso HTTP direto em widget/controller.
- Funciona em viewport mobile e desktop.
- Rotas nomeadas funcionando e alinhadas com a estrategia web do modulo.
- Erros mapeados em `Failure`.
- Criterios de aceite cobertos por testes.
